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

class ChatSocketConnection: SocketConnection2 {
    
    typealias ChatSocketMessageHandler = ((response: ChatSocketMessageResponse?) -> Void)
    
    // MARK: Properties
    
    private(set) public var credentials: Credentials
    
    private var requestHandlers = [Int : ChatSocketMessageHandler]()
    
    private var requestId: Int = 0
    
    private var myId: Int = 0
    private var issueId: Int = 0
    private var sessionInfo: String?
    private var customerTargetCompanyId: Int = 0
    
    // MARK: Initialization
    
    init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        
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
        let contextJSON = contextJSONForRequestWithPath(path)
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
        requestId++
        return requestId
    }
    
    func requestWithPathIsCustomerEndpoint(path: String?) -> Bool {
        if let path = path {
            return path.hasPrefix("customer/")
        }
        return false
    }
    
    func contextJSONForRequestWithPath(path: String) -> String {
        var context = [ "CompanyId" : customerTargetCompanyId ]
        if !requestWithPathIsCustomerEndpoint(path) {
            if credentials.targetCustomerToken != nil {
                context = [ "IssueId" : issueId ]
            }
        }
        
        var contextJSON = "{}"
        if NSJSONSerialization.isValidJSONObject(context) {
            do {
                let rawJSON = try NSJSONSerialization.dataWithJSONObject(context, options: .PrettyPrinted)
                contextJSON = String(data: rawJSON, encoding: NSUTF8StringEncoding)!
            } catch {
                NSLog("ERROR: JSON Serialization failed")
            }
        }
        return contextJSON
    }
    
    func paramsJSONForParams(params: [String: AnyObject]?) -> String {
        var paramsJSON = "{}"
        if let params = params {
            if NSJSONSerialization.isValidJSONObject(params) {
                do {
                    let rawJSON = try NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
                    paramsJSON = String(data: rawJSON, encoding: NSUTF8StringEncoding)!
                } catch {
                    DebugLog("ERROR: JSON Serialization failed")
                }
            }
        }
        return paramsJSON
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
        
        DebugLog("Received Message:\n\(response.serializedbody ?? response.originalMessage)")
        
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
//                delegate?.socketConnection(self, didReceiveMessage: body)
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
        if let sessionInfo = sessionInfo {
            authenticateWithSession(sessionInfo)
        } else if let userToken = credentials.userToken {
            if credentials.isCustomer {
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
        DebugLog("Authenticating with session \(session)")
        
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
        DebugLog("Authenticating customer with token \(token)")
        
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
        DebugLog("Authenticating non-customer with token \(token)")
        
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
        DebugLog("Creating an anonymous account")
        
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
            if let sessionInfoDict = jsonObj["SessionInfo"] as? [String: AnyObject] {
                if let jsonData = try? NSJSONSerialization.dataWithJSONObject(sessionInfoDict, options: []) {
                    sessionInfo = String(data: jsonData, encoding: NSUTF8StringEncoding)
                }
                
                if let company = sessionInfoDict["Company"] as? [String: AnyObject] {
                    if let companyId = company["CompanyId"] as? Int {
                        customerTargetCompanyId = companyId
                    }
                }
                
                if credentials.isCustomer {
                    if let customer = sessionInfoDict["Customer"] as? [String: AnyObject] {
                        if let rawId = customer["CustomerId"] as? Int {
                            myId = rawId
                        }
                    }
                } else {
                    if let customer = sessionInfoDict["Rep"] as? [String: AnyObject] {
                        if let rawId = customer["RepId"] as? Int {
                            myId = rawId
                        }
                    }
                }
                
//                fire(.Auth, info: nil)
            }
        }
    }
}
