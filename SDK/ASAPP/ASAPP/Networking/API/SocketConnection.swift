//
//  SocketConnection.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

// MARK:- SocketConnectionDelegate

protocol SocketConnectionDelegate: class {
    func socketConnectionDidLoseConnection(_ socketConnection: SocketConnection)
    func socketConnectionFailedToAuthenticate(_ socketConnection: SocketConnection)
    func socketConnectionEstablishedConnection(_ socketConnection: SocketConnection)
    func socketConnection(_ socketConnection: SocketConnection, didReceiveMessage message: IncomingMessage)
}

// MARK:- SocketConnection

class SocketConnection: NSObject {
    
    fileprivate let LOG_ANALYTICS_EVENTS_VERBOSE = false
    
    // MARK: Public Properties
    
    let config: ASAPPConfig

    var isConnected: Bool {
        if let socket = socket {
            return socket.readyState == .OPEN
        }
        return false
    }
    
    weak var delegate: SocketConnectionDelegate?
    
    // MARK: Private Properties
    
    fileprivate var isAuthenticated = false
    
    fileprivate var connectionRequest: URLRequest
    
    fileprivate var socket: SRWebSocket?
    
    fileprivate var outgoingMessageSerializer: OutgoingMessageSerializer
    
    fileprivate var incomingMessageSerializer = IncomingMessageSerializer()
    
    fileprivate var requestQueue = [SocketRequest]()
    
    fileprivate var requestHandlers = [Int : IncomingMessageHandler]()
    
    fileprivate var requestSendTimes = [Int : TimeInterval]()
    
    fileprivate var requestLookup = [Int : SocketRequest]()
    
    fileprivate var didManuallyDisconnect = false
    
    // MARK: Initialization
    
    init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction? = nil) {
        self.config = config
        self.connectionRequest = SocketConnection.createConnectionRequestion(with: config)
        self.outgoingMessageSerializer = OutgoingMessageSerializer(config: config, user: user, userLoginAction: userLoginAction)
        super.init()
        
        DebugLog.d("SocketConnection created with host url: \(String(describing: connectionRequest.url))")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SocketConnection.connect),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
        socket?.delegate = nil
    }
}

// MARK:- Connection URL

extension SocketConnection {
    
    class func createConnectionRequestion(with config: ASAPPConfig) -> URLRequest {
        let connectionRequest = NSMutableURLRequest()
        connectionRequest.url = URL(string: "wss://\(config.apiHostName)/api/websocket")
        connectionRequest.addValue(ASAPP.CLIENT_TYPE_VALUE, forHTTPHeaderField: ASAPP.CLIENT_TYPE_KEY)
        connectionRequest.addValue(ASAPP.clientVersion, forHTTPHeaderField: ASAPP.CLIENT_VERSION_KEY)
        connectionRequest.addValue(config.clientSecret, forHTTPHeaderField: ASAPP.CLIENT_SECRET_KEY)
        
        return connectionRequest as URLRequest
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
        
        didManuallyDisconnect = false
        
        socket = SRWebSocket(urlRequest: connectionRequest)
        socket?.delegate = self
        socket?.open()
        
        // Retry
        connectIfNeeded(afterDelay: 3)
    }
    
    func connectIfNeeded(afterDelay delayInSeconds: Int = 0) {
        if delayInSeconds > 0 {
            let delayTime = DispatchTime.now() + Double(Int64(UInt64(delayInSeconds) * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
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
    func sendRequest(withPath path: String,
                     params: [String : Any]?,
                     context: [String : Any]? = nil,
                     requestHandler: IncomingMessageHandler? = nil) {

        let request = outgoingMessageSerializer.createRequest(withPath: path, params: params, context: context)
        if let requestHandler = requestHandler {
            requestHandlers[request.requestId] = requestHandler
        }
        sendRequestWithRequest(request)
    }
    
    fileprivate func sendAuthRequest(withPath path: String,
                         params: [String : Any]?,
                         requestHandler: IncomingMessageHandler? = nil) {
        let request = outgoingMessageSerializer.createRequest(withPath: path, params: params, context: nil)
        if let requestHandler = requestHandler {
            requestHandlers[request.requestId] = requestHandler
        }
        sendRequestWithRequest(request, isAuthRequest: true)
    }
    
    /// Returns true if the message is sent
    
    func sendRequestWithData(_ data: Data,
                             requestHandler: IncomingMessageHandler? = nil) {
        let request = outgoingMessageSerializer.createRequestWithData(data)
        if let requestHandler = requestHandler {
            requestHandlers[request.requestId] = requestHandler
        }
        sendRequestWithRequest(request)
    }
    
    fileprivate func sendRequestWithRequest(_ request: SocketRequest, isAuthRequest: Bool = false) {
        if isConnected {
            guard isAuthRequest || isAuthenticated else {
                DebugLog.d("User not authenticated. Queueing request: \(request.path)")
                requestQueue.append(request)
                return
            }
            
            requestSendTimes[request.requestId] = Date.timeIntervalSinceReferenceDate
            requestLookup[request.requestId] = request
            
            if let data = request.requestData {
                DebugLog.d("Sending data request - (\(data.count) bytes)")
                socket?.send(data)
            } else {
                let requestString = outgoingMessageSerializer.createRequestString(withRequest: request)
                
                if !requestString.contains("srs/PutMAEvent") || LOG_ANALYTICS_EVENTS_VERBOSE {
                    request.logRequest(with: requestString)
                } else {
//                    DebugLog.d("Sending analytics request")
                }
                
                socket?.send(requestString)
            }
        } else {
            DebugLog.d("Socket not connected. Queueing request: \(request.path)")
            requestQueue.append(request)
            connect()
        }
    }
}

// MARK:- Authentication

extension SocketConnection {
    typealias SocketAuthResponseBlock = ((_ message: IncomingMessage?, _ errorMessage: String?) -> Void)
    
    func authenticate(_ completion: SocketAuthResponseBlock? = nil) {
        
        let (path, params, isSessionAuthRequest) = outgoingMessageSerializer.createAuthRequest()
        sendAuthRequest(withPath: path, params: params) { [weak self] (message, request, responseTime) in
            if message.type == .ResponseError && isSessionAuthRequest {
                // Session auth failed... retry after clearing session info
                self?.outgoingMessageSerializer.clearSessionInfo()
                self?.authenticate(completion)
                return
            }
            
            self?.outgoingMessageSerializer.updateWithAuthResponse(message)
            
            if let messageType = message.type {
                if messageType == .Response {
                    self?.isAuthenticated = true
                } else if messageType == .ResponseError {
                    self?.isAuthenticated = false
                }
            }
            
            if let completion = completion {
                completion(message, message.debugError)
            }
        }
    }
    
    // MARK: TargetCustomer
    
    func updateCustomerByCRMCustomerId(withTargetCustomerToken targetCustomerToken: String, completion: SocketAuthResponseBlock? = nil) {
        let path = "rep/GetCustomerByCRMCustomerId"
        let params: [String : Any] = [ "CRMCustomerId" : targetCustomerToken]
        
        sendRequest(withPath: path, params: params) { (response, request, responseTime) in
            guard let customerJSON = response.body?["Customer"] as? [String : Any] else {
                DebugLog.e("Missing Customer json body in: \(String(describing: response.fullMessage))")
                
                completion?(response, "Failed to update customer by CRMCustomerId")
                return
            }
            
            if let customerId = customerJSON["CustomerId"] as? Int {
                self.participateInIssueForCustomer(customerId, completion: completion)
            } else if let completion = completion {
                completion(response, "Missing CustomerId in: \(String(describing: response.fullMessage))")
            }
        }
    }
    
    func participateInIssueForCustomer(_ customerId: Int, completion: SocketAuthResponseBlock? = nil) {
        let path = "rep/ParticipateInIssueForCustomer"
        let context: [String : Any] = [ "CustomerId" : customerId ]
        
        sendRequest(withPath: path, params: nil, context: context) { (response, request, responseTime) in
            var errorMessage: String?
            if let issueId = response.body?["IssueId"] as? Int {
                self.outgoingMessageSerializer.issueId = issueId
            } else {
                DebugLog.e("Failed to get IssueId with: \(String(describing: response.fullMessage))")
                errorMessage = "Failed to get IssueId"
            }
            
            if let completion = completion {
                completion(response, errorMessage)
            }
        }
    }
    
    func resendQueuedRequestsIfNeeded() {
        while !requestQueue.isEmpty {
            let request = requestQueue[0] 
            requestQueue.remove(at: 0)
            sendRequestWithRequest(request)
        }
    }
}

// MARK:- SocketRocketDelegate

extension SocketConnection: SRWebSocketDelegate {
    
    // MARK: Receiving Messages
    
    public func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        
        func logMessageReceived(forRequest request: SocketRequest?, responseTime: Int) {
            let responseTimeString = responseTime > 0 ?  " [\(responseTime) ms]" : ""
            var originalRequestInfo = ""
            if let request = request {
                originalRequestInfo = " [\(request.path)] [\(request.requestUUID)]"
            }
            
            DebugLog.d("SOCKET MESSAGE RECEIVED\(responseTimeString)\(originalRequestInfo):\n---------")
            
            if (message as AnyObject).description.characters.count > 1000 {
                if ASAPP.debugLogLevel.rawValue < ASAPPLogLevel.info.rawValue {
                    DebugLog.d("(Use info debug level to see long message)")
                }
                DebugLog.i("\(message)")
                DebugLog.d("---------")
            } else {
                DebugLog.d("\(message != nil ? message! : "EMPTY RESPONSE")\n---------")
            }
        }
        
        let serializedMessage = incomingMessageSerializer.serializedMessage(message)
        if let requestId = serializedMessage.requestId {
            
            // Original Request
            let originalRequest = requestLookup[requestId]
            requestLookup[requestId] = nil
            
            // Response Time
            var responseTime: Int = -1
            if let requestSendTime = requestSendTimes[requestId] {
                requestSendTimes[requestId] = nil
                
                let currentTime = NSDate.timeIntervalSinceReferenceDate
                responseTime = Int(floor((currentTime - requestSendTime) * 1000))
            }
            
            logMessageReceived(forRequest: originalRequest, responseTime: responseTime)
            
            if let requestHandler = requestHandlers[requestId] {
                requestHandlers[requestId] = nil
                requestHandler(serializedMessage, originalRequest, responseTime)
            }
            
        } else {
             logMessageReceived(forRequest: nil, responseTime: -1)
        }
        
        delegate?.socketConnection(self, didReceiveMessage: serializedMessage)
    }
    
    // MARK: Connection Opening/Closing
    
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        DebugLog.d("Socket Did Open")
        
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
    
    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        DebugLog.d("Socket Did Close: \(code) {\n  reason: \(reason),\n  wasClean: \(wasClean)\n}")
        
        isAuthenticated = false
        
        delegate?.socketConnectionDidLoseConnection(self)
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        DebugLog.d("Socket Did Fail: \(error)")
        
        isAuthenticated = false
        
        delegate?.socketConnectionFailedToAuthenticate(self)
    }
}
