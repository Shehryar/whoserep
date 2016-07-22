//
//  SocketConnection.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import SocketRocket

// MARK:- SocketConnectionDelegate

protocol SocketConnectionDelegate {
    func socketConnection(socketConnection: SocketConnection, didChangeConnectionStatus isConnected: Bool)
    func socketConnection(socketConnection: SocketConnection, didReceiveMessage message: AnyObject)
}

// MARK:- SocketConnection

class SocketConnection: NSObject {
    
    typealias SocketMessageHandler = ((message: AnyObject?) -> Void)
    
    // MARK: Public Properties
    
    public var connectionRequest: NSURLRequest
    
    public var isConnected: Bool {
        if let socket = socket {
            return socket.readyState == .OPEN
        }
        return false
    }
    
    public var delegate: SocketConnectionDelegate?
    
    // MARK: Private Properties
    
    private var socket: SRWebSocket?
    
    // MARK: Initialization
    
    init(withConnectionRequest connectionRequest: NSURLRequest) {
        self.connectionRequest = connectionRequest
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
        
        ASAPPLog("Socket connecting with request \(connectionRequest)")
        
        socket = SRWebSocket(URLRequest: connectionRequest)
        socket?.delegate = self
        socket?.open()
        
        // Retry
        connectIfNeeded(afterDelay: 5)
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
    func sendMessage(withString messageString: String) {
        // TODO: maybe attempt connection, maintain queue of messages to send on connection?
        if !isConnected {
            ASAPPLoge("Socket is not connected...")
        }
        
        socket?.send(messageString)
    }
}

// MARK:- Internal Connection Changes

extension SocketConnection {
    internal func connectionStatusDidChange() {
        delegate?.socketConnection(self, didChangeConnectionStatus: isConnected)
    }
}

// MARK:- SocketRocketDelegate

extension SocketConnection: SRWebSocketDelegate {
    // MARK: Receiving Messages
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        print("\n\nReceived message:\n\(message)\n\n")
        
        delegate?.socketConnection(self, didReceiveMessage: message)
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceivePong pongPayload: NSData!) {
        // No-op for now
    }
    
    // MARK: Connection Opening/Closing
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        connectionStatusDidChange()
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        connectionStatusDidChange()
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        connectionStatusDidChange()
    }
}

// MARK:- Notifications

extension SocketConnection {
    // TODO: Send notifications for all messages received and connectionStatus updates
}
