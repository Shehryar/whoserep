//
//  ChatAPI.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/20/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation
import SocketRocket

enum ChatAPIConnectionState {
    case Disconnected
    case Connected
}

protocol ChatAPIDelegate {
    func chatAPI(api: ChatAPI, didChangeConnectionState state: ChatAPIConnectionState)
    func chatAPI(api: ChatAPI, didReceiveMessage message: AnyObject)
}

protocol ChatAPIDataSource {
    func targetCustomerTokenForChatAPI(api: ChatAPI) -> Int?
    func customerTargetCompanyIdForChatAPI(api: ChatAPI) -> Int
    func nextRequestIdForChatAPI(api: ChatAPI) -> Int
    func issueIdForChatAPI(api: ChatAPI) -> Int
}

class ChatAPI: NSObject {

    typealias RequestHandler = (message: AnyObject?) -> Void
    
    // MARK:- Public Properties
    
    public var dataSource: ChatAPIDataSource?
    
    public var delegate: ChatAPIDelegate?

    private(set) public var connectionState = ChatAPIConnectionState.Disconnected
    
    public var isOpen: Bool {
        if let socket = socket {
            return socket.readyState == .OPEN
        }
        return false
    }
    
    // MARK:- Private Properties
    
    private var socket: SRWebSocket?
    
    private var requestHandlers: [Int: RequestHandler] = [:]
    
    private lazy var connectionRequest: NSURLRequest = {
        var request = NSMutableURLRequest()
        request.URL = NSURL(string: "wss://vs-dev.asapp.com/api/websocket")
        request.addValue("consumer-ios-sdk", forHTTPHeaderField: "ASAPP-ClientType")
        request.addValue("0.1.0", forHTTPHeaderField: "ASAPP-ClientVersion")
        return request
    }()
    
    // MARK:- Initialization
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatAPI.connectIfNeeded), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Establishing Connection
    
    func connectIfNeeded() {
        ASAPPLog("ConnectIfNeeded")
        
        if !isOpen {
            connect()
        }
    }
    
    func connect() {
        if let socket = socket {
            if socket.readyState == .CLOSING {
                socket.delegate = nil
                self.socket = nil
            }
            if socket.readyState != .CLOSED {
                ASAPPLoge("ASAPP: Connection state is not closed")
                return
            }
        }
        
        ASAPPLog("Connecting")
        
        socket = SRWebSocket(URLRequest: connectionRequest)
        socket?.delegate = self
        socket?.open()
        
        // Retry
        connect(afterDelay: 5)
    }
    
    func connect(afterDelay delayInSeconds: Double) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            if !self.isOpen {
                self.connect()
            }
        }
    }
}

// MARK:- Requests

extension ChatAPI {
    func makeRequest(withPath path: String,
                              params: [String: AnyObject]? = nil,
                              context: [String: AnyObject]? = nil,
                              requestHandler: RequestHandler) {
        guard let dataSource = dataSource, let delegate = delegate else {
            ASAPPLoge("ChatAPIClient missing dataSource/delegate")
            return
        }
        
        let requestId = dataSource.nextRequestIdForChatAPI(self)
        requestHandlers[requestId] = requestHandler

        let paramsJSON = paramsJSONForParams(params)
        let contextJSON = contextJSONForContext(context ?? defaultContextForRequestWithPath(path))
        
        let requestStr = String(format: "%@|%d|%@|%@", path, requestId, contextJSON, paramsJSON)
       
        ASAPPLog(requestStr)
       
        socket?.send(requestStr)
    }
    
    // MARK: Utility
    
    func requestWithPathIsCustomerEndpoint(path: String?) -> Bool {
        if let path = path {
            return path.hasPrefix("customer/")
        }
        return false
    }
    
    func defaultContextForRequestWithPath(path: String) -> [String: AnyObject] {
        guard let dataSource = dataSource else {
            ASAPPLoge("ChatAPIClient missing dataSource")
            return [:]
        }
        
        var context = ["CompanyId": dataSource.customerTargetCompanyIdForChatAPI(self)]
        if !requestWithPathIsCustomerEndpoint(path) {
            if dataSource.targetCustomerTokenForChatAPI(self) != nil {
                context = ["IssueId" : dataSource.issueIdForChatAPI(self)]
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

// MARK:- SRWebSocketDelegate

extension ChatAPI: SRWebSocketDelegate {
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        ASAPPLog("WS-OPENED")
        
        connectionState = .Connected
        
        delegate?.chatAPI(self, didChangeConnectionState: connectionState)
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        ASAPPLog("WS-MESSAGE:", message)
        if let message = message as? String {
            let tokens = message.characters.split("|").map(String.init)
            if tokens[0] == ASAPPState.ASAPPMsgTypeResponse {
                if let handler = requestHandlers[Int(tokens[1])!] {
                    handler(message: tokens[2])
                }
            } else if tokens[0] == ASAPPState.ASAPPMsgTypeEvent {
                delegate?.chatAPI(self, didReceiveMessage: tokens[1])
            }
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        ASAPPLog(error)
        
        connectionState = .Disconnected
        
        delegate?.chatAPI(self, didChangeConnectionState: connectionState)
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        ASAPPLog(reason)
        
        connectionState = .Disconnected
        
        delegate?.chatAPI(self, didChangeConnectionState: connectionState)
    }
}
