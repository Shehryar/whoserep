//
//  ChatSocketConnection.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/22/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

// MARK: ChatSockectConnectionDataSource

protocol ChatSockectConnectionDataSource {
    func targetCustomerTokenForSocketConnection(socketConnection: ChatSocketConnection) -> Int?
    func customerTargetCompanyIdForSocketConnection(socketConnection: ChatSocketConnection) -> Int
    func nextRequestIdForSocketConnection(socketConnection: ChatSocketConnection) -> Int
    func issueIdForSocketConnection(socketConnection: ChatSocketConnection) -> Int
    func fullCredentialsForSocketConnection(socketConnection: ChatSocketConnection) -> FullCredentials?
}

// MARK: ChatSocketConnectionDelegate {

protocol ChatSocketConnectionDelegate {
    func chatSocketConnection(chatSocketConnection: ChatSocketConnection, didUpdateFullCredentials: FullCredentials, value: AnyObject?, forKeyPath keyPath: String)
}

// MARK:- ChatSocketConnection

class ChatSocketConnection: SocketConnection {
    
    // Websocket Message Types
    enum MessageType: String {
        case Response = "Response"
        case Event = "Event"
        case ResponseError = "ResponseError"
    }
    
    // MARK: Properties
    
    var dataSource: ChatSockectConnectionDataSource?
    
    var onFullCredentialsUpdate: ((fullCredentials: FullCredentials, value: AnyObject?, keyPath: String) -> Void)?
    
    let sessionKey = "ASAPP_SESSION_KEY"
    
    // MARK: Initialization
    
    init() {
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
    
    // MARK: Sending Messages
    
    public func sendRequest(withPath path: String,
                                     params: [String: AnyObject]? = nil,
                                     context: [String: AnyObject]? = nil,
                                     requestHandler: ((message: AnyObject?) -> Void)? = nil) {
        guard let dataSource = dataSource else {
            ASAPPLoge("ChatSocketConnection missing dataSource")
            return
        }
        
        // NOTE: Request handler was here
        
        let requestId = dataSource.nextRequestIdForSocketConnection(self)
        let paramsJSON = paramsJSONForParams(params)
        let contextJSON = contextJSONForContext(context ?? defaultContextForRequestWithPath(path))
        let requestString = String(format: "%@|%d|%@|%@", path, requestId, contextJSON, paramsJSON)
        
        sendMessage(withString: requestString)
    }
    
    // MARK: Private Utilities

    func requestWithPathIsCustomerEndpoint(path: String?) -> Bool {
        if let path = path {
            return path.hasPrefix("customer/")
        }
        return false
    }
    
    func defaultContextForRequestWithPath(path: String) -> [String: AnyObject] {
        guard let dataSource = dataSource else {
            ASAPPLoge("ChatSocketConnection missing dataSource")
            return [:]
        }
        
        var context = ["CompanyId": dataSource.customerTargetCompanyIdForSocketConnection(self)]
        if !requestWithPathIsCustomerEndpoint(path) {
            if dataSource.targetCustomerTokenForSocketConnection(self) != nil {
                context = ["IssueId" : dataSource.issueIdForSocketConnection(self)]
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

// MARK:- Updates for Connection Status

extension ChatSocketConnection {
    override func connectionStatusDidChange() {
        guard let dataSource = dataSource else {
            ASAPPLoge("Missing dataSource for ChatSocketConnection")
            return
        }
        
        print("\n\n\nConnection Status Did Change\n\n")
        
        if isConnected {
            if let fullCredentials = dataSource.fullCredentialsForSocketConnection(self) {
                authenticate(withFullCredentials: fullCredentials)
            } else {
                ASAPPLoge("Unable to authenticate because ChatSocketConnection.dataSource returned nil FullCredentials")
            }
        }
    }
}

// MARK:- Authentication

extension ChatSocketConnection {
    
    public func authenticate(withFullCredentials fullCredentials: FullCredentials) {
        if let sessionInfo = fullCredentials.sessionInfo {
            authenticateWithSession(sessionInfo, fullCredentials: fullCredentials)
        } else if let userToken = fullCredentials.userToken {
            if fullCredentials.isCustomer {
                authenticateCustomerWithToken(userToken, fullCredentials: fullCredentials)
            } else {
                authenticateWithToken(userToken, fullCredentials: fullCredentials)
            }
        } else {
            createAnonAccount(withFullCredentials: fullCredentials)
        }
    }
    
    // MARK: Private Utilities
    
    func authenticateWithSession(session: String, fullCredentials: FullCredentials) {
        guard let jsonObject = try? NSJSONSerialization.JSONObjectWithData(session.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as? [String: AnyObject] else {
            return
        }

        let params: [String: AnyObject] = [
            "SessionInfo": jsonObject!,
            "App": "ios-sdk"
        ]
        sendRequest(withPath: "auth/AuthenticateWithSession", params: params) { [weak self] (message) in
            guard self != nil else {
                return
            }
            
            if let authInfo = message as? String {
                self?.handleAuthIfNeeded(authInfo, fullCredentials: fullCredentials)
            }
        }
    }
    
    func authenticateCustomerWithToken(token: String, fullCredentials: FullCredentials) {
        let params: [String: AnyObject] = [
            "CompanyMarker": "vs-dev",
            "Identifiers": token,
            "App": "ios-sdk"
        ]
        
        sendRequest(withPath: "auth/AuthenticateWithCustomerToken", params: params) { [weak self] (message) in
            if let authInfo = message as? String {
                self?.handleAuthIfNeeded(authInfo, fullCredentials: fullCredentials)
            }
        }
    }
    
    func authenticateWithToken(token: String, fullCredentials: FullCredentials) {
        let params: [String: AnyObject] = [
            "Company": "vs-dev",
            "AuthCallbackData": token,
            "GhostEmailAddress": "",
            "CountConnectionForIssueTimeout": false,
            "App": "ios-sdk"
        ]
        sendRequest(withPath: "auth/AuthenticateWithSalesForceToken", params: params) { [weak self] (message) in
            if let authInfo = message as? String {
                self?.handleAuthIfNeeded(authInfo, fullCredentials: fullCredentials)
            }
        }
    }
    
    func createAnonAccount(withFullCredentials fullCredentials: FullCredentials) {
        let params: [String: AnyObject] = [
            "CompanyMarker": "vs-dev",
            "RegionCode": "US"
        ]
        sendRequest(withPath: "auth/CreateAnonCustomerAccount", params: params) { [weak self] (message) in
            if let authInfo = message as? String {
                self?.handleAuthIfNeeded(authInfo, fullCredentials: fullCredentials)
            }
        }
    }
    
    func handleAuthIfNeeded(authInfo: String, fullCredentials: FullCredentials) {
        guard let onFullCredentialsUpdate = onFullCredentialsUpdate else {
            ASAPPLoge("Missing onFullCredentialsUpdate in ChatSocketConnection")
            return
        }
        
        
        if authInfo == "null" {
            return
        }
        do {
            let jsonObj = try NSJSONSerialization.JSONObjectWithData(authInfo.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as! [String: AnyObject]
            
            if let sessionInfo = jsonObj["SessionInfo"] as? [String: AnyObject] {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(sessionInfo, options: [])
                onFullCredentialsUpdate(fullCredentials: fullCredentials, value: String(data: jsonData, encoding: NSUTF8StringEncoding), keyPath: "sessionInfo")
                
                if let company = sessionInfo["Company"] as? [String: AnyObject] {
                    if let companyId = company["CompanyId"] as? Int {
                        onFullCredentialsUpdate(fullCredentials: fullCredentials, value: companyId, keyPath: "customerTargetCompanyId")
                    }
                }
                
                if fullCredentials.isCustomer {
                    if let customer = sessionInfo["Customer"] as? [String: AnyObject] {
                        if let rawId = customer["CustomerId"] as? UInt {
                            onFullCredentialsUpdate(fullCredentials: fullCredentials, value: rawId, keyPath: "myId")
                        }
                    }
                } else {
                    if let customer = sessionInfo["Rep"] as? [String: AnyObject] {
                        if let rawId = customer["RepId"] as? UInt {
                            onFullCredentialsUpdate(fullCredentials: fullCredentials, value: rawId, keyPath: "myId")
                        }
                    }
                }
                
//                fire(.Auth, info: nil)
            }
        } catch let err as NSError {
            ASAPPLoge(err)
        }
    }
}
