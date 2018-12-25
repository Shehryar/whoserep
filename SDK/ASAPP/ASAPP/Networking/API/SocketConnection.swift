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
    func socketConnectionFailedToConnect(_ socketConnection: SocketConnection)
    func socketConnectionEstablishedConnection(_ socketConnection: SocketConnection)
    func socketConnection(_ socketConnection: SocketConnection, didReceiveMessage message: IncomingMessage)
}

protocol SocketConnectionProtocol: class {
    init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction?, savedSessionManager: SavedSessionManagerProtocol, webSocketClass: ASAPPSRWebSocket.Type, httpClient: HTTPClientProtocol)
    var delegate: SocketConnectionDelegate? { get set }
    var isConnected: Bool { get }
    func connect(shouldRetry: Bool, retries: Int)
    func connect(shouldRetry: Bool)
    func disconnect()
}

extension SocketConnectionProtocol {
    init(config: ASAPPConfig, user: ASAPPUser) {
        self.init(config: config, user: user, userLoginAction: nil, savedSessionManager: SavedSessionManager.shared, webSocketClass: ASAPPSRWebSocket.self, httpClient: HTTPClient.shared)
    }
    
    func connect(shouldRetry: Bool) {
        return connect(shouldRetry: shouldRetry, retries: 0)
    }
}

// MARK: - SocketConnection

class SocketConnection: NSObject, SocketConnectionProtocol {
    
    // MARK: Public Properties
    
    weak var delegate: SocketConnectionDelegate?

    var isConnected: Bool {
        if let socket = socket {
            return socket.readyState == .SR_OPEN
        }
        return false
    }
    
    // MARK: Private Properties
    
    private let config: ASAPPConfig
    private let httpClient: HTTPClientProtocol
    private var webSocketClass: ASAPPSRWebSocket.Type
    private var socket: ASAPPSRWebSocket?
    private let savedSessionManager: SavedSessionManagerProtocol
    private var incomingMessageDeserializer = IncomingMessageDeserializer()
    private var requestHandlers = [Int: IncomingMessageHandler]()
    private var requestSendTimes = [Int: TimeInterval]()
    private var requestLookup = [Int: SocketRequest]()
    private var timer: RepeatingTimer?
    private var isAuthenticated = false
    private var didManuallyDisconnect = false
    
    // MARK: Initialization
    
    required init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction? = nil, savedSessionManager: SavedSessionManagerProtocol = SavedSessionManager.shared, webSocketClass: ASAPPSRWebSocket.Type = ASAPPSRWebSocket.self, httpClient: HTTPClientProtocol = HTTPClient.shared) {
        self.config = config
        self.savedSessionManager = savedSessionManager
        self.webSocketClass = webSocketClass
        self.httpClient = httpClient
        super.init()
        
        if let savedSession = self.savedSessionManager.getSession() {
            if savedSession.customerMatches(primaryId: user.userIdentifier)
            || savedSession.isAnonymous && !user.isAnonymous {
                httpClient.session = savedSession
            } else {
                self.savedSessionManager.clearSession()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(SocketConnection.connect), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        timer = nil
    }
}

// MARK: - Managing Connection

extension SocketConnection {
    private func createConnectionRequest(oneTimeURL: URL) -> URLRequest {
        let connectionRequest = NSMutableURLRequest()
        connectionRequest.url = oneTimeURL
        connectionRequest.addValue(ASAPP.clientType, forHTTPHeaderField: ASAPP.clientTypeKey)
        connectionRequest.addValue(ASAPP.clientVersion, forHTTPHeaderField: ASAPP.clientVersionKey)
        connectionRequest.addValue(ASAPP.partnerAppVersion, forHTTPHeaderField: ASAPP.partnerAppVersionKey)
        connectionRequest.addValue(config.clientSecret, forHTTPHeaderField: ASAPP.clientSecretKey)
        return connectionRequest as URLRequest
    }
    
    private func open(with request: URLRequest) {
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
        
        socket = webSocketClass.init(urlRequest: request)
        socket?.delegate = self
        DebugLog.d("Opening Web Socket with url: \(request.url?.absoluteString ?? "nil")")
        socket?.open()
    }
    
    private func createWebSocketURL(from response: URLResponse, and path: String) -> URL? {
        guard
            let baseUrl = response.url,
            let partialUrl = URL(string: path),
            var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false),
            var partialComponents = URLComponents(url: partialUrl, resolvingAgainstBaseURL: false)
        else {
            return nil
        }
        
        components.scheme = "wss"
        components.queryItems = partialComponents.queryItems
        var path = partialComponents.path
        if path.hasPrefix("/") {
            path = String(path.suffix(from: path.index(after: path.startIndex)))
        }
        return components.url?.deletingLastPathComponent().appendingPathComponent(path, isDirectory: false).standardized
    }
    
    @objc func connect(shouldRetry: Bool, retries: Int = 0) {
        func getDelay(forRetry retry: Int) -> DispatchTimeInterval {
            return .seconds(min(retry * 3, 30))
        }
        
        guard !isConnected && !didManuallyDisconnect,
            let url = httpClient.baseUrl?.replacingPath(with: "/api/v2/websocket/request") else {
            return
        }
        
        DebugLog.d(caller: self, "Requesting URL for Web Socket...")
        
        httpClient.sendRequest(method: .POST, url: url) { [weak self] (dict: [String: Any]?, response, error) in
            guard let strongSelf = self else {
                return
            }
            
            guard
                error == nil,
                let response = response,
                let path = dict?["url"] as? String,
                let url = self?.createWebSocketURL(from: response, and: path)
            else {
                if let error = error {
                    DebugLog.e(error)
                }
                
                if retries == 1 {
                    strongSelf.delegate?.socketConnectionFailedToConnect(strongSelf)
                }
                
                let nextRetry = retries + 1
                Dispatcher.delay(getDelay(forRetry: nextRetry), qos: .utility) { [weak self] in
                    DebugLog.d(caller: HTTPClient.self, Date().debugDescription, "retrying getting Web Socket URL (retry #\(nextRetry))")
                    self?.connect(shouldRetry: true, retries: nextRetry)
                }
                return
            }
            
            let request = strongSelf.createConnectionRequest(oneTimeURL: url)
            strongSelf.open(with: request)
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
                DebugLog.i("\(message ?? "nil")")
                DebugLog.d("---------")
            } else {
                DebugLog.d("\(message != nil ? message! : "EMPTY RESPONSE")\n---------")
            }
        }
        
        guard let messageString = message as? String else {
            DebugLog.w(caller: SocketConnection.self, "Cannot downcast message \(message ?? "nil") to String for deserialization")
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
        
        delegate?.socketConnectionEstablishedConnection(self)
        
        timer = RepeatingTimer(interval: 60) { [weak self] in
            self?.keepAlive()
        }
        timer?.resume()
    }
    
    func webSocket(_ webSocket: ASAPPSRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        DebugLog.d("Socket Did Close: \(code) {\n  reason: \(String(describing: reason)),\n  wasClean: \(wasClean)\n}")
        
        isAuthenticated = false
        
        delegate?.socketConnectionDidLoseConnection(self)
    }
    
    func webSocket(_ webSocket: ASAPPSRWebSocket!, didFailWithError error: Error!) {
        DebugLog.d("Socket Did Fail: \(String(describing: error))")
        
        isAuthenticated = false
        
        delegate?.socketConnectionDidLoseConnection(self)
    }
}
