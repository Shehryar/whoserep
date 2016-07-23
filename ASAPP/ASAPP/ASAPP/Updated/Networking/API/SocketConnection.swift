//
//  SocketConnection.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import SocketRocket

// MARK:- SocketConnectionDelegate

protocol SocketConnectionDelegate {
    func socketConnection(socketConnection: SocketConnection, didChangeConnectionStatus isConnected: Bool)
    func socketConnection(socketConnection: SocketConnection, didReceiveMessage message: IncomingMessage)
}

// MARK:- SocketConnection

class SocketConnection: NSObject {
    
    // MARK: Public Properties
    
    private(set) public var credentials: Credentials
    
    lazy var connectionRequest: NSURLRequest = {
        var connectionRequest = NSMutableURLRequest()
        connectionRequest.URL = NSURL(string: "wss://vs-dev.asapp.com/api/websocket")
        connectionRequest.addValue("consumer-ios-sdk", forHTTPHeaderField: "ASAPP-ClientType")
        connectionRequest.addValue("0.1.0", forHTTPHeaderField: "ASAPP-ClientVersion")
        return connectionRequest
    }()

    public var isConnected: Bool {
        if let socket = socket {
            return socket.readyState == .OPEN
        }
        return false
    }
    
    public var delegate: SocketConnectionDelegate?
    
    // MARK: Private Properties
    
    private var socket: SRWebSocket?
    
    private var outgoingMessageSerializer = OutgoingMessageSerializer()
    
    private var incomingMessageSerializer = IncomingMessageSerializer()
    
    private var requestQueue = [String /* RequestString */]()
    
    private var requestHandlers = [Int : IncomingMessageHandler]()
    
    // MARK: Initialization
    
    init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        super.init()
    }
    
    deinit {
        socket?.delegate = nil
    }
}

// MARK:- Managing Connection

extension SocketConnection {
    func connect() {
        if let socket = socket {
            switch socket.readyState {
            case .CLOSING:
                // Current connection is no longer useful.
                disconnect()
                break
                
            case _ where socket.readyState != .CLOSED:
                // Connection is valid. No need to connect.
                return
                
            default: break
            }
        }
        
        DebugLog("Socket connecting with request \(connectionRequest)")
        
        socket = SRWebSocket(URLRequest: connectionRequest)
        socket?.delegate = self
        socket?.open()
        
        // Retry
        connectIfNeeded(afterDelay: 3)
    }
    
    func connectIfNeeded(afterDelay delayInSeconds: Int = 0) {
        if delayInSeconds > 0 {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(delayInSeconds) * NSEC_PER_SEC))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                if !self.isConnected {
                    self.connect()
                }
            }
        } else if !isConnected {
            connect()
        }
    }
    
    func disconnect() {
        socket?.delegate = nil
        socket?.close()
        socket = nil
    }
}

// MARK:- Sending Messages

extension SocketConnection {
    func sendRequest(withPath path: String, params: [String : AnyObject]?, requestHandler: IncomingMessageHandler? = nil) {
        let (requestString, requestId) = outgoingMessageSerializer.createRequestString(withPath: path, params: params)
        if let requestHandler = requestHandler {
            requestHandlers[requestId] = requestHandler
        }
        sendRequest(withRequestString: requestString)
    }
    
    func sendRequest(withRequestString requestString: String) {
        if isConnected {
            DebugLog("Sending request: \(requestString)")
            socket?.send(requestString)
        } else {
            DebugLog("Socket not connected. Queueing request: \(requestString)")
            requestQueue.append(requestString)
            connect()
        }
    }
}

// MARK:- Authentication

extension SocketConnection {
    func authenticate() {
        var path: String
        var params: [String : AnyObject]
        
        if let sessionInfo = outgoingMessageSerializer.sessionInfo {
            // Session
            path = "auth/AuthenticateWithSession"
            params =  [
                "SessionInfo": sessionInfo, // convert to json?
                "App": "ios-sdk"
            ]
        } else if let userToken = credentials.userToken {
            // Customer w/ Token
            if credentials.isCustomer {
                path = "auth/AuthenticateWithCustomerToken"
                params = [
                    "CompanyMarker": "vs-dev",
                    "Identifiers": userToken,
                    "App": "ios-sdk"
                ]
            } else {
                // Non-customer w/ Token
                path = "auth/AuthenticateWithSalesForceToken"
                params = [
                    "Company": "vs-dev",
                    "AuthCallbackData": userToken,
                    "GhostEmailAddress": "",
                    "CountConnectionForIssueTimeout": false,
                    "App": "ios-sdk"
                ]
            }
        } else {
            // Anonymous User
            path = "auth/CreateAnonCustomerAccount"
            params = [
                "CompanyMarker": "vs-dev",
                "RegionCode": "US"
            ]
        }
        
        sendRequest(withPath: path, params: params) { [weak self] (message) in
            self?.handleAuthenticationResponse(message)
        }
    }
    
    func handleAuthenticationResponse(response: IncomingMessage) {
        guard let jsonObj = response.body else {
            DebugLogError("Authentication response missing body: \(response)")
            return
        }
        
        guard let sessionInfoDict = jsonObj["SessionInfo"] as? [String: AnyObject] else {
            DebugLogError("Authentication response missing sessionInfo: \(response)")
            return
        }
        
        if let sessionJsonData = try? NSJSONSerialization.dataWithJSONObject(sessionInfoDict, options: []) {
            outgoingMessageSerializer.sessionInfo = String(data: sessionJsonData, encoding: NSUTF8StringEncoding)
        }
        
        if let company = sessionInfoDict["Company"] as? [String: AnyObject] {
            if let companyId = company["CompanyId"] as? Int {
                outgoingMessageSerializer.customerTargetCompanyId = companyId
            }
        }
        
        if credentials.isCustomer {
            if let customer = sessionInfoDict["Customer"] as? [String: AnyObject] {
                if let rawId = customer["CustomerId"] as? Int {
                    outgoingMessageSerializer.myId = rawId
                }
            }
        } else {
            if let customer = sessionInfoDict["Rep"] as? [String: AnyObject] {
                if let rawId = customer["RepId"] as? Int {
                    outgoingMessageSerializer.myId = rawId
                }
            }
        }
    }
}

// MARK:- SocketRocketDelegate

extension SocketConnection: SRWebSocketDelegate {
    // MARK: Receiving Messages
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        DebugLog("Received message:\n\(message)")
        
        let serializedMessage = incomingMessageSerializer.serializedMessage(message)
        if let requestId = serializedMessage.requestId {
            if let requestHandler = requestHandlers[requestId] {
                requestHandlers[requestId] = nil
                requestHandler(serializedMessage)
            }
        }
        
        delegate?.socketConnection(self, didReceiveMessage: serializedMessage)
    }
    
    // MARK: Connection Opening/Closing
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        authenticate()
        
        while !requestQueue.isEmpty {
            let requestString = requestQueue[0]
            requestQueue.removeAtIndex(0)
            sendRequest(withRequestString: requestString)
        }
        
        delegate?.socketConnection(self, didChangeConnectionStatus: isConnected)
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        delegate?.socketConnection(self, didChangeConnectionStatus: isConnected)
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        delegate?.socketConnection(self, didChangeConnectionStatus: isConnected)
    }
}
