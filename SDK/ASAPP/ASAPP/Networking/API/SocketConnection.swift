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
    func socketConnectionFailedToAuthenticate(_ socketConnection: SocketConnection, error: SocketConnection.AuthError)
    func socketConnectionEstablishedConnection(_ socketConnection: SocketConnection)
    func socketConnection(_ socketConnection: SocketConnection, didReceiveMessage message: IncomingMessage)
}

// MARK: - SocketConnection

class SocketConnection: NSObject {
    
    // MARK: Public Properties
    
    weak var delegate: SocketConnectionDelegate?
    
    let config: ASAPPConfig

    var isConnected: Bool {
        if let socket = socket {
            return socket.readyState == .SR_OPEN
        }
        return false
    }
    
    var session: Session? {
        return outgoingMessageSerializer.session
    }
    
    // MARK: Private Properties
    
    private var connectionRequest: URLRequest
    private var webSocketClass: ASAPPSRWebSocket.Type
    private var socket: ASAPPSRWebSocket?
    private let savedSessionManager: SavedSessionManagerProtocol
    private var outgoingMessageSerializer: OutgoingMessageSerializerProtocol
    private var incomingMessageDeserializer = IncomingMessageDeserializer()
    private var requestHandlers = [Int: IncomingMessageHandler]()
    private var requestSendTimes = [Int: TimeInterval]()
    private var requestLookup = [Int: SocketRequest]()
    private var timer: RepeatingTimer?
    private var isAuthenticated = false
    private var didManuallyDisconnect = false
    
    enum AuthError: String {
        case invalidAuth = "invalid_auth"
        case tokenExpired = "token_expired"
    }
    
    // MARK: Initialization
    
    init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction? = nil, outgoingMessageSerializer: OutgoingMessageSerializerProtocol? = nil, savedSessionManager: SavedSessionManagerProtocol = SavedSessionManager.shared, webSocketClass: ASAPPSRWebSocket.Type = ASAPPSRWebSocket.self) {
        self.config = config
        self.connectionRequest = SocketConnection.createConnectionRequest(with: config)
        self.outgoingMessageSerializer = outgoingMessageSerializer ?? OutgoingMessageSerializer(config: config, user: user, userLoginAction: userLoginAction)
        self.savedSessionManager = savedSessionManager
        self.webSocketClass = webSocketClass
        super.init()
        
        DebugLog.d("SocketConnection created with host url: \(String(describing: connectionRequest.url))")
        
        if let savedSession = self.savedSessionManager.getSession() {
            if savedSession.customer.matches(id: user.userIdentifier) {
                updateSession(savedSession)
            } else if savedSession.isAnonymous && !user.isAnonymous {
                let nextAction = self.outgoingMessageSerializer.userLoginAction?.nextAction
                self.outgoingMessageSerializer.userLoginAction = UserLoginAction(customer: savedSession.customer, nextAction: nextAction)
            } else {
                self.savedSessionManager.clearSession()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(SocketConnection.connect), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        timer = nil
    }
    
    private func updateSession(_ session: Session?) {
        outgoingMessageSerializer.session = session
        PushNotificationsManager.shared.session = session
    }
}

// MARK: - Connection URL

extension SocketConnection {
    
    class func createConnectionRequest(with config: ASAPPConfig) -> URLRequest {
        let connectionRequest = NSMutableURLRequest()
        connectionRequest.url = URL(string: "wss://\(config.apiHostName)/api/websocket")
        connectionRequest.addValue(ASAPP.clientType, forHTTPHeaderField: ASAPP.clientTypeKey)
        connectionRequest.addValue(ASAPP.clientVersion, forHTTPHeaderField: ASAPP.clientVersionKey)
        connectionRequest.addValue(ASAPP.partnerAppVersion, forHTTPHeaderField: ASAPP.partnerAppVersionKey)
        connectionRequest.addValue(config.clientSecret, forHTTPHeaderField: ASAPP.clientSecretKey)
        
        return connectionRequest as URLRequest
    }
}

// MARK: - Managing Connection

extension SocketConnection {
    @objc func connect() {
        if let socket = socket {
            switch socket.readyState {
            case .SR_CLOSING:
                // Current connection is no longer useful.
                disconnect()
                
            case _ where socket.readyState != .SR_CLOSED:
                // Connection is valid. No need to connect.
                return
                
            default: break
            }
        }
        
        didManuallyDisconnect = false
        
        socket = webSocketClass.init(urlRequest: connectionRequest)
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
    
    @objc func keepAlive() {
        guard socket?.readyState == .SR_OPEN else {
            timer?.suspend()
            return
        }
        
        socket?.sendPing(nil)
    }
}

// MARK: - Sending Messages

extension SocketConnection {
    
    private func sendAuthRequest(withPath path: String,
                                 params: [String: Any]?,
                                 requestHandler: IncomingMessageHandler? = nil) {
        let request = outgoingMessageSerializer.createRequest(withPath: path, params: params, context: nil)
        if let requestHandler = requestHandler {
            requestHandlers[request.requestId] = requestHandler
        }
        
        requestSendTimes[request.requestId] = Date.timeIntervalSinceReferenceDate
        requestLookup[request.requestId] = request
        
        guard isConnected else {
            DebugLog.d("Socket not connected. Not sending request: \(request.path). Reconnecting...")
            connect()
            return
        }
        
        if let data = request.requestData {
            DebugLog.d("Sending data request - (\(data.count) bytes)")
            socket?.send(data)
        } else {
            let requestString = outgoingMessageSerializer.createRequestString(withRequest: request)
            request.logRequest(with: requestString)
            socket?.send(requestString)
        }
    }
}

// MARK: - Authentication

extension SocketConnection {
    typealias SocketAuthResponseBlock = ((_ message: IncomingMessage?, _ errorMessage: String?) -> Void)
    
    func authenticate(attempts: Int = 0, contextNeedsRefresh: Bool = false, _ completion: SocketAuthResponseBlock? = nil) {
        outgoingMessageSerializer.createAuthRequest(contextNeedsRefresh: contextNeedsRefresh) { [weak self] authRequest in
            self?.sendAuthRequest(withPath: authRequest.path, params: authRequest.params) { [weak self] (message, _, _) in
                var session: Session?
                
                if message.type == .response {
                    session = self?.getSession(from: message)
                }
                
                if let session = session {
                    self?.savedSessionManager.save(session: session)
                    self?.updateSession(session)
                    self?.isAuthenticated = true
                } else {
                    self?.isAuthenticated = false
                    
                    if self?.outgoingMessageSerializer.session != nil {
                        self?.savedSessionManager.clearSession()
                        self?.updateSession(nil)
                        
                        if attempts == 0 {
                            let needsRefresh = (message.debugError == AuthError.tokenExpired.rawValue)
                            self?.authenticate(attempts: 1, contextNeedsRefresh: needsRefresh, completion)
                            return
                        }
                    }
                }
                
                completion?(message, message.debugError)
            }
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
}

// MARK: - SocketRocketDelegate

extension SocketConnection: ASAPPSRWebSocketDelegate {
    
    // MARK: Receiving Messages
    
    func webSocket(_ webSocket: ASAPPSRWebSocket!, didReceiveMessage message: Any!) {
        
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
        
        guard let messageString = message as? String else {
            DebugLog.w(caller: SocketConnection.self, "Cannot downcast message \(message) to String for deserialization")
            return
        }
        
        let incomingMessage = incomingMessageDeserializer.deserialize(messageString)
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
    
    func webSocketDidOpen(_ webSocket: ASAPPSRWebSocket!) {
        DebugLog.d("Socket Did Open")
        
        authenticate { [weak self] (_, errorMessage) in
            guard let strongSelf = self else {
                return
            }
            
            if let errorMessage = errorMessage,
               let authError = AuthError(rawValue: errorMessage) {
                strongSelf.delegate?.socketConnectionFailedToAuthenticate(strongSelf, error: authError)
            } else {
                strongSelf.delegate?.socketConnectionEstablishedConnection(strongSelf)
                
                self?.timer = RepeatingTimer(interval: 60) { [weak self] in
                    self?.keepAlive()
                }
                self?.timer?.resume()
            }
        }
    }
    
    func webSocket(_ webSocket: ASAPPSRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        DebugLog.d("Socket Did Close: \(code) {\n  reason: \(reason),\n  wasClean: \(wasClean)\n}")
        
        isAuthenticated = false
        
        delegate?.socketConnectionDidLoseConnection(self)
    }
    
    func webSocket(_ webSocket: ASAPPSRWebSocket!, didFailWithError error: Error!) {
        DebugLog.d("Socket Did Fail: \(error)")
        
        isAuthenticated = false
        
        delegate?.socketConnectionDidLoseConnection(self)
    }
}
