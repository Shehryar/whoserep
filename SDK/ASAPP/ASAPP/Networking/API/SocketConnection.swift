//
//  SocketConnection.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

// MARK: - SocketConnectionDelegate

protocol SocketConnectionDelegate: class {
    func socketConnectionDidLoseConnection(_ socketConnection: SocketConnection)
    func socketConnectionFailedToAuthenticate(_ socketConnection: SocketConnection)
    func socketConnectionEstablishedConnection(_ socketConnection: SocketConnection)
    func socketConnection(_ socketConnection: SocketConnection, didReceiveMessage message: IncomingMessage)
}

// MARK: - SocketConnection

class SocketConnection: NSObject {
    
    private let logAnalyticsEventsVerbose = false
    
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
    
    private var isAuthenticated = false
    
    private var connectionRequest: URLRequest
    
    private var socket: SRWebSocket?
    
    private var outgoingMessageSerializer: OutgoingMessageSerializer
    
    private var incomingMessageDeserializer = IncomingMessageDeserializer()
    
    private var requestQueue = [SocketRequest]()
    
    private var requestHandlers = [Int: IncomingMessageHandler]()
    
    private var requestSendTimes = [Int: TimeInterval]()
    
    private var requestLookup = [Int: SocketRequest]()
    
    private var didManuallyDisconnect = false
    
    // MARK: Initialization
    
    init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction? = nil) {
        self.config = config
        self.connectionRequest = SocketConnection.createConnectionRequest(with: config)
        self.outgoingMessageSerializer = OutgoingMessageSerializer(config: config, user: user, userLoginAction: userLoginAction)
        super.init()
        
        DebugLog.d("SocketConnection created with host url: \(String(describing: connectionRequest.url))")
        
        if let savedSession = SavedSessionManager.getSession() {
            if savedSession.customer.matches(id: user.userIdentifier) {
                outgoingMessageSerializer.session = savedSession
            } else if savedSession.isAnonymous && !user.isAnonymous {
                outgoingMessageSerializer.userLoginAction = UserLoginAction(customer: savedSession.customer, nextAction: outgoingMessageSerializer.userLoginAction?.nextAction)
            } else {
                SavedSessionManager.clearSession()
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SocketConnection.connect),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        socket?.delegate = nil
    }
}

// MARK: - Connection URL

extension SocketConnection {
    
    class func createConnectionRequest(with config: ASAPPConfig) -> URLRequest {
        let connectionRequest = NSMutableURLRequest()
        connectionRequest.url = URL(string: "wss://\(config.apiHostName)/api/websocket")
        connectionRequest.addValue(ASAPP.clientType, forHTTPHeaderField: ASAPP.clientTypeKey)
        connectionRequest.addValue(ASAPP.clientVersion, forHTTPHeaderField: ASAPP.clientVersionKey)
        connectionRequest.addValue(config.clientSecret, forHTTPHeaderField: ASAPP.clientSecretKey)
        
        return connectionRequest as URLRequest
    }
}

// MARK: - Managing Connection

extension SocketConnection {
    @objc func connect() {
        if let socket = socket {
            switch socket.readyState {
            case .CLOSING:
                // Current connection is no longer useful.
                disconnect()
                
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

// MARK: - Sending Messages

extension SocketConnection {
    func sendRequest(withPath path: String,
                     params: [String: Any]?,
                     context: [String: Any]? = nil,
                     requestHandler: IncomingMessageHandler? = nil) {

        let request = outgoingMessageSerializer.createRequest(withPath: path, params: params, context: context)
        if let requestHandler = requestHandler {
            requestHandlers[request.requestId] = requestHandler
        }
        sendRequestWithRequest(request)
    }
    
    private func sendAuthRequest(withPath path: String,
                                 params: [String: Any]?,
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
    
    private func sendRequestWithRequest(_ request: SocketRequest, isAuthRequest: Bool = false) {
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
                
                if !requestString.contains("srs/PutMAEvent") || logAnalyticsEventsVerbose {
                    request.logRequest(with: requestString)
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

// MARK: - Authentication

extension SocketConnection {
    typealias SocketAuthResponseBlock = ((_ message: IncomingMessage?, _ errorMessage: String?) -> Void)
    
    func authenticate(attempts: Int = 0, _ completion: SocketAuthResponseBlock? = nil) {
        let authRequest = outgoingMessageSerializer.createAuthRequest()
        sendAuthRequest(withPath: authRequest.path, params: authRequest.params) { [weak self] (message, _, _) in
            var session: Session?
            
            if message.type == .response {
                session = self?.getSession(from: message)
            }
            
            if let session = session {
                SavedSessionManager.save(session: session)
                self?.outgoingMessageSerializer.session = session
                self?.isAuthenticated = true
            } else {
                self?.isAuthenticated = false
                
                if self?.outgoingMessageSerializer.session != nil {
                    SavedSessionManager.clearSession()
                    self?.outgoingMessageSerializer.session = nil
                    
                    if attempts == 0 {
                        self?.authenticate(attempts: 1, completion)
                        return
                    }
                }
            }
            
            completion?(message, message.debugError)
        }
    }
    
    func getSession(from response: IncomingMessage) -> Session? {
        guard let bodyString = response.bodyString else {
            DebugLog.e("Authentication response missing body: \(response)")
            return nil
        }
        
        guard let data = bodyString.data(using: .utf8) else {
            DebugLog.e("Could not interpret UTF-8 string: \(response)")
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.userInfo[Session.rawBodyKey] = bodyString
        return try? decoder.decode(Session.self, from: data)
    }
    
    // MARK: TargetCustomer
    
    func updateCustomerByCRMCustomerId(withTargetCustomerToken targetCustomerToken: String, completion: SocketAuthResponseBlock? = nil) {
        let path = "rep/GetCustomerByCRMCustomerId"
        let params: [String: Any] = [ "CRMCustomerId": targetCustomerToken]
        
        sendRequest(withPath: path, params: params) { (response, _, _) in
            guard let customerJSON = response.body?["Customer"] as? [String: Any] else {
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
        let context: [String: Any] = [ "CustomerId": customerId ]
        
        sendRequest(withPath: path, params: nil, context: context) { (response, _, _) in
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

// MARK: - SocketRocketDelegate

extension SocketConnection: SRWebSocketDelegate {
    
    // MARK: Receiving Messages
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        
        func logMessageReceived(forRequest request: SocketRequest?, responseTime: Int) {
            let responseTimeString = responseTime > 0 ?  " [\(responseTime) ms]" : ""
            var originalRequestInfo = ""
            if let request = request {
                originalRequestInfo = " [\(request.path)] [\(request.requestUUID)]"
            }
            
            DebugLog.d("SOCKET MESSAGE RECEIVED\(responseTimeString)\(originalRequestInfo):\n---------")
            
            if (message as AnyObject).description.count > 1000 {
                if ASAPP.debugLogLevel.rawValue < ASAPPLogLevel.info.rawValue {
                    DebugLog.d("(Use info debug level to see long message)")
                }
                DebugLog.i("\(message)")
                DebugLog.d("---------")
            } else {
                DebugLog.d("\(message != nil ? message! : "EMPTY RESPONSE")\n---------")
            }
        }
        
        let incomingMessage = incomingMessageDeserializer.deserialize(message)
        if let requestId = incomingMessage.requestId {
            
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
                requestHandler(incomingMessage, originalRequest, responseTime)
            }
            
        } else {
             logMessageReceived(forRequest: nil, responseTime: -1)
        }
        
        delegate?.socketConnection(self, didReceiveMessage: incomingMessage)
    }
    
    // MARK: Connection Opening/Closing
    
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        DebugLog.d("Socket Did Open")
        
        authenticate { [weak self] (_, errorMessage) in
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
