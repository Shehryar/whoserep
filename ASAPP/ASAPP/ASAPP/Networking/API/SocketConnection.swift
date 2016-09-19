//
//  SocketConnection.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import SocketRocket


enum ASAPPEnvironment {
    case Local
    case Development
    case SRSDevelopment
    case Production
}
let CURRENT_ENVIRONMENT = ASAPPEnvironment.SRSDevelopment


// MARK:- SocketConnectionDelegate

protocol SocketConnectionDelegate {
    func socketConnectionDidLoseConnection(socketConnection: SocketConnection)
    func socketConnectionFailedToAuthenticate(socketConnection: SocketConnection)
    func socketConnectionEstablishedConnection(socketConnection: SocketConnection)
    func socketConnection(socketConnection: SocketConnection, didReceiveMessage message: IncomingMessage)
}

// MARK:- SocketConnection

class SocketConnection: NSObject {
    
    // MARK: Public Properties
    
    private(set) var credentials: Credentials

    var isConnected: Bool {
        if let socket = socket {
            return socket.readyState == .OPEN
        }
        return false
    }
    
    var delegate: SocketConnectionDelegate?
    
    // MARK: Private Properties
    
    private var connectionRequest: NSURLRequest
    
    private var socket: SRWebSocket?
    
    private var outgoingMessageSerializer: OutgoingMessageSerializer
    
    private var incomingMessageSerializer = IncomingMessageSerializer()
    
    private var requestQueue = [SocketRequest]()
    
    private var requestHandlers = [Int : IncomingMessageHandler]()
    
    private var didManuallyDisconnect = false
    
    // MARK: Initialization
    
    init(withCredentials credentials: Credentials) {
        let connectionRequest = NSMutableURLRequest()
        switch CURRENT_ENVIRONMENT {
        case .Local:
            connectionRequest.URL = NSURL(string: "wss://localhost:8443/api/websocket")
            break
            
        case .Development:
            connectionRequest.URL = NSURL(string: "wss://vs-dev.asapp.com/api/websocket")
            break
            
        case .SRSDevelopment:
            connectionRequest.URL = NSURL(string: "wss://srs-api-dev.asapp.com/api/websocket")
            break
            
        case .Production:
            // TODO: Add this
            break
        }
        connectionRequest.addValue("consumer-ios-sdk", forHTTPHeaderField: "ASAPP-ClientType")
        connectionRequest.addValue("0.1.0", forHTTPHeaderField: "ASAPP-ClientVersion")
        self.connectionRequest = connectionRequest
        self.credentials = credentials
        self.outgoingMessageSerializer = OutgoingMessageSerializer(withCredentials: self.credentials)
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SocketConnection.connect), name: UIApplicationDidBecomeActiveNotification, object: nil)
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
        
        didManuallyDisconnect = false
        
        socket = SRWebSocket(URLRequest: connectionRequest)
        socket?.delegate = self
        socket?.open()
        
        // Retry
        connectIfNeeded(afterDelay: 3)
    }
    
    func connectIfNeeded(afterDelay delayInSeconds: Int = 0) {
        if delayInSeconds > 0 {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(delayInSeconds) * NSEC_PER_SEC))
            dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                if let strongSelf = self {
                    if !strongSelf.isConnected && !strongSelf.didManuallyDisconnect {
                        self?.connect()
                    }
                }
            }
        } else if !isConnected {
            connect()
        }
    }
    
    func disconnect() {
        didManuallyDisconnect = true
        socket?.delegate = nil
        socket?.close()
        socket = nil
    }
}

// MARK:- Sending Messages

extension SocketConnection {
    func sendRequest(withPath path: String, params: [String : AnyObject]?, context: [String : AnyObject]? = nil, requestHandler: IncomingMessageHandler? = nil) {
        let request = outgoingMessageSerializer.createRequest(withPath: path, params: params, context: context)
        if let requestHandler = requestHandler {
            requestHandlers[request.requestId] = requestHandler
        }
        sendRequestWithRequest(request)
    }
    
    func sendRequestWithData(data: NSData, requestHandler: IncomingMessageHandler? = nil) {
        let request = outgoingMessageSerializer.createRequestWithData(data)
        if let requestHandler = requestHandler {
            requestHandlers[request.requestId] = requestHandler
        }
        sendRequestWithRequest(request)
    }
    
    func sendRequestWithRequest(request: SocketRequest) {
        if isConnected {
            if let data = request.requestData {
                DebugLog("Sending data request - (\(data.length) bytes)")
                socket?.send(data)
            } else {
                let requestString = outgoingMessageSerializer.createRequestString(withRequest: request)
                DebugLog("Sending request: \(requestString)")
                socket?.send(requestString)
            }
        } else {
            DebugLog("Socket not connected. Queueing request: \(request.path)")
            requestQueue.append(request)
            connect()
        }
    }
}

// MARK:- Authentication

extension SocketConnection {
    typealias SocketAuthResponseBlock = ((message: IncomingMessage?, errorMessage: String?) -> Void)
    
    func authenticate(completion: SocketAuthResponseBlock? = nil) {
        
        let (path, params) = outgoingMessageSerializer.createAuthRequest()
        sendRequest(withPath: path, params: params) { [weak self] (message) in
            self?.outgoingMessageSerializer.updateWithAuthResponse(message)
            
            if let targetCustomerToken = self?.credentials.targetCustomerToken {
                self?.updateCustomerByCRMCustomerId(withTargetCustomerToken: targetCustomerToken, completion: completion)
            } else if let completion = completion {
                completion(message: message, errorMessage: nil)
            }
        }
    }
    
    // MARK: TargetCustomer
    
    func updateCustomerByCRMCustomerId(withTargetCustomerToken targetCustomerToken: String, completion: SocketAuthResponseBlock? = nil) {
        let path = "rep/GetCustomerByCRMCustomerId"
        let params: [String: AnyObject] = [ "CRMCustomerId" : targetCustomerToken ]
        
        sendRequest(withPath: path, params: params) { (response) in
            guard let customerJSON = response.body?["Customer"] as? [String : AnyObject] else {
                DebugLogError("Missing Customer json body in: \(response.fullMessage)")
                
                completion?(message: response, errorMessage: "Failed to update customer by CRMCustomerId")
                return
            }
            
            if let customerId = customerJSON["CustomerId"] as? Int {
                self.participateInIssueForCustomer(customerId, completion: completion)
            } else if let completion = completion {
                completion(message: response, errorMessage: "Missing CustomerId in: \(response.fullMessage)")
            }
        }
    }
    
    func participateInIssueForCustomer(customerId: Int, completion: SocketAuthResponseBlock? = nil) {
        let path = "rep/ParticipateInIssueForCustomer"
        let context: [String: AnyObject] = [ "CustomerId" : customerId ]
        
        sendRequest(withPath: path, params: nil, context: context) { (response) in
            var errorMessage: String?
            if let issueId = response.body?["IssueId"] as? Int {
                self.outgoingMessageSerializer.issueId = issueId
            } else {
                DebugLogError("Failed to get IssueId with: \(response.fullMessage)")
                errorMessage = "Failed to get IssueId"
            }
            
            if let completion = completion {
                completion(message: response, errorMessage: errorMessage)
            }
        }
    }
    
    func resendQueuedRequestsIfNeeded() {
        while !requestQueue.isEmpty {
            let request = requestQueue[0] 
            requestQueue.removeAtIndex(0)
            sendRequestWithRequest(request)
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
        authenticate { [weak self] (message, errorMessage) in
            guard self != nil else { return }
            
            if errorMessage == nil {
                self?.resendQueuedRequestsIfNeeded()
                self?.delegate?.socketConnectionEstablishedConnection(self!)
            } else {
                self?.delegate?.socketConnectionFailedToAuthenticate(self!)
            }
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        delegate?.socketConnectionDidLoseConnection(self)
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        delegate?.socketConnectionFailedToAuthenticate(self)
    }
}
