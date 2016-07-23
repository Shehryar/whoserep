//
//  ChatSocketConnection.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/22/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import SocketRocket

// MARK:- ChatSocketConnection

class ChatSocketConnection: SocketConnection {
    
    typealias ChatSocketMessageHandler = ((response: ChatSocketMessageResponse?) -> Void)
    
    // MARK: Properties
    
    private(set) public var credentials: Credentials
    
    private var fullCredentials: FullCredentials
    
    private var requestHandlers = [Int : ChatSocketMessageHandler]()
    
    let sessionKey = "ASAPP_SESSION_KEY"
    
    // MARK: Initialization
    
    init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        self.fullCredentials = FullCredentials(withCredentials: self.credentials)
        
        var connectionRequest = NSMutableURLRequest()
        connectionRequest.URL = NSURL(string: "wss://vs-dev.asapp.com/api/websocket")
        connectionRequest.addValue("consumer-ios-sdk", forHTTPHeaderField: "ASAPP-ClientType")
        connectionRequest.addValue("0.1.0", forHTTPHeaderField: "ASAPP-ClientVersion")

        super.init(withConnectionRequest: connectionRequest)
    }
    
    override init(withConnectionRequest connectionRequest: NSURLRequest) {
        fatalError("Use the default init method")
    }
}

// MARK:- Sending Requests

extension ChatSocketConnection {
    public func sendRequest(withPath path: String,
                                     params: [String: AnyObject]? = nil,
                                     requestHandler: ((response: ChatSocketMessageResponse?) -> Void)? = nil) {
        
        let requestId = nextRequestId()
        let paramsJSON = paramsJSONForParams(params)
        let contextJSON = contextForRequestWithPath(path)
        let requestString = String(format: "%@|%d|%@|%@", path, requestId, contextJSON, paramsJSON)
        
        if let requestHandler = requestHandler {
            requestHandlers[requestId] = requestHandler
        }
        
        makeRequestWithString(requestString)
    }
    
    public func sendChatMessage(withText text: String, requestHandler: ChatSocketMessageHandler? = nil) {
        var path = "\(credentials.isCustomer ? "customer/" : "rep/")SendTextMessage"
        sendRequest(withPath: path, params: ["Text" : text], requestHandler: requestHandler)
    }
}

// MARK:- Request Utilites

extension ChatSocketConnection {
    func nextRequestId() -> Int {
        fullCredentials.reqId += 1
        
        return fullCredentials.reqId
    }
    
    func requestWithPathIsCustomerEndpoint(path: String?) -> Bool {
        if let path = path {
            return path.hasPrefix("customer/")
        }
        return false
    }
    
    func contextForRequestWithPath(path: String) -> [String: AnyObject] {
        var context = [ "CompanyId" : fullCredentials.customerTargetCompanyId ]
        if !requestWithPathIsCustomerEndpoint(path) {
            if fullCredentials.targetCustomerToken != nil {
                context = [ "IssueId" : fullCredentials.issueId ]
            }
        }
        return context
    }
    
    func paramsJSONForParams(params: [String: AnyObject]?) -> String {
        var paramsJSON = "{}"
        if let params = params {
            if NSJSONSerialization.isValidJSONObject(params) {
                do {
                    let rawJSON = try NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
                    paramsJSON = String(data: rawJSON, encoding: NSUTF8StringEncoding)!
                } catch {
                    NSLog("ERROR: JSON Serialization failed")
                }
            }
        }
        return paramsJSON
    }
    
    func contextJSONForContext(context: [String: AnyObject]?) -> String {
        var contextJSON = "{}"
        if let context = context {
            if NSJSONSerialization.isValidJSONObject(context) {
                do {
                    let rawJSON = try NSJSONSerialization.dataWithJSONObject(context, options: .PrettyPrinted)
                    contextJSON = String(data: rawJSON, encoding: NSUTF8StringEncoding)!
                } catch {
                    NSLog("ERROR: JSON Serialization failed")
                }
            }
        }
        return contextJSON
    }
}

// MARK:- Overriding SocketRocketDelegate

extension ChatSocketConnection {
    override func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        let response = ChatSocketMessageResponse(withResponse: message)
        guard let type = response.type else {
            DebugLogError("Unable to determine type from response: \(message)")
            return
        }
        
        DebugLog("\n\n\nReceived Message:\n\(response.serializedbody ?? response.originalMessage)\n\n\n")
        
        switch type {
        case .Response:
            if let requestId = response.requestId {
                if let handler = requestHandlers[requestId] {
                    handler(response: response)
                    requestHandlers[requestId] = nil
                }
            }
            break;
            
        case .Event:
            if let body = response.body {
                delegate?.socketConnection(self, didReceiveMessage: body)
            }
            break
            
        case .ResponseError:
            DebugLogError("Received Response Error: \(message)")
            break
        }
    }
    
    override func webSocketDidOpen(webSocket: SRWebSocket!) {
        super.webSocketDidOpen(webSocket)
        
        authenticate()
    }
}

// MARK:- Authentication

extension ChatSocketConnection {
    
    public func authenticate() {
        if let sessionInfo = fullCredentials.sessionInfo {
            authenticateWithSession(sessionInfo)
        } else if let userToken = fullCredentials.userToken {
            if fullCredentials.isCustomer {
                authenticateCustomerWithToken(userToken)
            } else {
                authenticateNonCustomerWithToken(userToken)
            }
        } else {
            createAnonAccount()
        }
    }
    
    // MARK: Private Utilities
    
    func authenticateWithSession(session: String) {
        print("\n\nAuthenticating with session \(session)\n\n")
        
        guard let jsonObject = try? NSJSONSerialization.JSONObjectWithData(session.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as? [String: AnyObject] else {
            return
        }

        let params: [String: AnyObject] = [
            "SessionInfo": jsonObject!,
            "App": "ios-sdk"
        ]
        sendRequest(withPath: "auth/AuthenticateWithSession", params: params) { [weak self] (response) in
            self?.handleAuthIfNeeded(response)
        }
    }
    
    func authenticateCustomerWithToken(token: String) {
        print("\n\nAuthenticating customer with token \(token)\n\n")
        
        let params: [String: AnyObject] = [
            "CompanyMarker": "vs-dev",
            "Identifiers": token,
            "App": "ios-sdk"
        ]
        
        sendRequest(withPath: "auth/AuthenticateWithCustomerToken", params: params) { [weak self] (response) in
            self?.handleAuthIfNeeded(response)
        }
    }
    
    func authenticateNonCustomerWithToken(token: String) {
        print("\n\nAuthenticating non-customer with token \(token)\n\n")
        
        let params: [String: AnyObject] = [
            "Company": "vs-dev",
            "AuthCallbackData": token,
            "GhostEmailAddress": "",
            "CountConnectionForIssueTimeout": false,
            "App": "ios-sdk"
        ]
        sendRequest(withPath: "auth/AuthenticateWithSalesForceToken", params: params) { [weak self] (response) in
            self?.handleAuthIfNeeded(response)
        }
    }
    
    func createAnonAccount() {
        print("\n\nCreating anon account")
        
        let params: [String: AnyObject] = [
            "CompanyMarker": "vs-dev",
            "RegionCode": "US"
        ]
        sendRequest(withPath: "auth/CreateAnonCustomerAccount", params: params) { [weak self] (response) in
            self?.handleAuthIfNeeded(response)
        }
    }
    
    func handleAuthIfNeeded(response: ChatSocketMessageResponse?) {
        guard let response = response else {
            return
        }
        
        if let jsonObj = response.serializedbody {
            if let sessionInfo = jsonObj["SessionInfo"] as? [String: AnyObject] {
                if let jsonData = try? NSJSONSerialization.dataWithJSONObject(sessionInfo, options: []) {
                    fullCredentials.sessionInfo = String(data: jsonData, encoding: NSUTF8StringEncoding)
                }
                
                if let company = sessionInfo["Company"] as? [String: AnyObject] {
                    if let companyId = company["CompanyId"] as? Int {
                        fullCredentials.customerTargetCompanyId = companyId
                    }
                }
                
                if fullCredentials.isCustomer {
                    if let customer = sessionInfo["Customer"] as? [String: AnyObject] {
                        if let rawId = customer["CustomerId"] as? Int {
                            fullCredentials.myId = rawId
                        }
                    }
                } else {
                    if let customer = sessionInfo["Rep"] as? [String: AnyObject] {
                        if let rawId = customer["RepId"] as? Int {
                            fullCredentials.myId = rawId
                        }
                    }
                }
                
//                fire(.Auth, info: nil)
            }
        }
    }
}
