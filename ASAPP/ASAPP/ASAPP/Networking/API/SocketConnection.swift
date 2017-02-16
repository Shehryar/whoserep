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
    
    fileprivate(set) var credentials: Credentials

    var isConnected: Bool {
        if let socket = socket {
            return socket.readyState == .OPEN
        }
        return false
    }
    
    weak var delegate: SocketConnectionDelegate?
    
    // MARK: Private Properties
    
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
    
    init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        self.connectionRequest = SocketConnection.createConnectionRequestion(subdomain: credentials.subdomain)
        self.outgoingMessageSerializer = OutgoingMessageSerializer(withCredentials: self.credentials)
        super.init()
        
        DebugLog("SocketConnection created with host url: \(connectionRequest.url)")
        
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
    
    private static let TEMP_CLIENT_SECRET = "BD0ED4C975FF217D3FCD00A895130849E5521F517F0162F5D28D61D628B2B990"

    class func createConnectionRequestion(subdomain: String) -> URLRequest {        
        let connectionRequest = NSMutableURLRequest()
        connectionRequest.url = URL(string: "wss://\(subdomain).asapp.com/api/websocket")
        connectionRequest.addValue(ASAPP.CLIENT_TYPE_VALUE, forHTTPHeaderField: ASAPP.CLIENT_TYPE_KEY)
        connectionRequest.addValue(ASAPP.clientVersion, forHTTPHeaderField: ASAPP.CLIENT_VERSION_KEY)
        connectionRequest.addValue(TEMP_CLIENT_SECRET, forHTTPHeaderField: ASAPP.CLIENT_SECRET_KEY)
        
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
                     params: [String : AnyObject]?,
                     context: [String : AnyObject]? = nil,
                     requestHandler: IncomingMessageHandler? = nil) {

        let request = outgoingMessageSerializer.createRequest(withPath: path, params: params, context: context)
        if let requestHandler = requestHandler {
            requestHandlers[request.requestId] = requestHandler
        }
        sendRequestWithRequest(request)
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
    
    fileprivate func sendRequestWithRequest(_ request: SocketRequest) {
        if isConnected {
            requestSendTimes[request.requestId] = Date.timeIntervalSinceReferenceDate
            requestLookup[request.requestId] = request
            
            if let data = request.requestData {
                DebugLog("Sending data request - (\(data.count) bytes)")
                socket?.send(data)
            } else {
                let requestString = outgoingMessageSerializer.createRequestString(withRequest: request)
                
                if !requestString.contains("srs/PutMAEvent") || LOG_ANALYTICS_EVENTS_VERBOSE {
                    request.logRequest(with: requestString)
                } else {
                    DebugLog("Sending analytics request")
                }
                
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
    typealias SocketAuthResponseBlock = ((_ message: IncomingMessage?, _ errorMessage: String?) -> Void)
    
    func authenticate(_ completion: SocketAuthResponseBlock? = nil) {
        
        let (path, params) = outgoingMessageSerializer.createAuthRequest()
        sendRequest(withPath: path, params: params) { [weak self] (message, request, responseTime) in
            self?.outgoingMessageSerializer.updateWithAuthResponse(message)
            
            if let targetCustomerToken = self?.credentials.targetCustomerToken {
                self?.updateCustomerByCRMCustomerId(withTargetCustomerToken: targetCustomerToken, completion: completion)
            } else if let completion = completion {
                completion(message, nil)
            }
        }
    }
    
    // MARK: TargetCustomer
    
    func updateCustomerByCRMCustomerId(withTargetCustomerToken targetCustomerToken: String, completion: SocketAuthResponseBlock? = nil) {
        let path = "rep/GetCustomerByCRMCustomerId"
        let params: [String : AnyObject] = [ "CRMCustomerId" : targetCustomerToken as AnyObject]
        
        sendRequest(withPath: path, params: params) { (response, request, responseTime) in
            guard let customerJSON = response.body?["Customer"] as? [String : AnyObject] else {
                DebugLogError("Missing Customer json body in: \(response.fullMessage)")
                
                completion?(response, "Failed to update customer by CRMCustomerId")
                return
            }
            
            if let customerId = customerJSON["CustomerId"] as? Int {
                self.participateInIssueForCustomer(customerId, completion: completion)
            } else if let completion = completion {
                completion(response, "Missing CustomerId in: \(response.fullMessage)")
            }
        }
    }
    
    func participateInIssueForCustomer(_ customerId: Int, completion: SocketAuthResponseBlock? = nil) {
        let path = "rep/ParticipateInIssueForCustomer"
        let context: [String: AnyObject] = [ "CustomerId" : customerId as AnyObject ]
        
        sendRequest(withPath: path, params: nil, context: context) { (response, request, responseTime) in
            var errorMessage: String?
            if let issueId = response.body?["IssueId"] as? Int {
                self.outgoingMessageSerializer.issueId = issueId
            } else {
                DebugLogError("Failed to get IssueId with: \(response.fullMessage)")
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
            
            DebugLog("SOCKET MESSAGE RECEIVED\(responseTimeString)\(originalRequestInfo):\n---------\n\(message != nil ? message! : "EMPTY RESPONSE")\n---------")
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
        DebugLog("Socket Did Open")
        
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
        DebugLog("Socket Did Close: \(code) {\n  reason: \(reason),\n  wasClean: \(wasClean)\n}")
        
        delegate?.socketConnectionDidLoseConnection(self)
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        DebugLog("Socket Did Fail: \(error)")
        
        delegate?.socketConnectionFailedToAuthenticate(self)
    }
}
