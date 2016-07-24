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

    public var isConnected: Bool {
        if let socket = socket {
            return socket.readyState == .OPEN
        }
        return false
    }
    
    public var delegate: SocketConnectionDelegate?
    
    // MARK: Private Properties
    
    private var connectionRequest: NSURLRequest
    
    private var socket: SRWebSocket?
    
    private var outgoingMessageSerializer: OutgoingMessageSerializer
    
    private var incomingMessageSerializer = IncomingMessageSerializer()
    
    private var requestQueue = [String /* RequestString */]()
    
    private var requestHandlers = [Int : IncomingMessageHandler]()
    
    // MARK: Initialization
    
    init(withCredentials credentials: Credentials) {
        var connectionRequest = NSMutableURLRequest()
        connectionRequest.URL = NSURL(string: "wss://vs-dev.asapp.com/api/websocket")
        connectionRequest.addValue("consumer-ios-sdk", forHTTPHeaderField: "ASAPP-ClientType")
        connectionRequest.addValue("0.1.0", forHTTPHeaderField: "ASAPP-ClientVersion")
        self.connectionRequest = connectionRequest
        self.credentials = credentials
        self.outgoingMessageSerializer = OutgoingMessageSerializer(withCredentials: self.credentials)
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
        let (path, params) = outgoingMessageSerializer.createAuthRequest()
        
        sendRequest(withPath: path, params: params) { [weak self] (message) in
            self?.outgoingMessageSerializer.updateWithAuthResponse(message)
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
