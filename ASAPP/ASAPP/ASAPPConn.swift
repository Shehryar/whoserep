//
//  ASAPPConn.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/15/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation
import SocketRocket

protocol ASAPPConnDelegate {
    func sessionInfoIfAvailable() -> String?
    func nextRequestId() -> Int
    
    func issueId() -> Int
    
    func customerTargetCompanyId() -> Int
    
    func didChangeConnState(isConnected: Bool)
    func didReceiveMessage(message: AnyObject)
}

class ASAPPConn: NSObject, SRWebSocketDelegate {
    
    var state: ASAPPState!
    var ws: SRWebSocket!
    var delegate: ASAPPConnDelegate!
    
    typealias RequestHandler = (message: AnyObject?) -> Void
    var requestHandlers: [Int: RequestHandler] = [:]
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ASAPPConn.connectIfNeeded(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func connectIfNeeded(sender: NSNotification) {
        ASAPPLog("ConnectIfNeeded")
        if isOpen() {
            return
        }
        
        connect()
    }
    
    func connect() {
        if ws != nil && ws.readyState == .CLOSING {
            ws.delegate = nil
            ws = nil
        }
        if ws != nil && ws.readyState != .CLOSED {
            ASAPPLoge("ASAPP: Connection state is not closed")
            return
        }
        
        let url = NSURL(string: "wss://vs-dev.asapp.com/api/websocket")
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("consumer-ios-sdk", forHTTPHeaderField: "ASAPP-ClientType")
        request.addValue("0.1.0", forHTTPHeaderField: "ASAPP-ClientVersion")
        ws = SRWebSocket(URLRequest: request)
        ws.delegate = self
        ws.open()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) { [weak self] in
            guard self != nil else {
                return
            }
            
            if self?.isOpen() == true {
                return
            }
            
            self!.connect()
        }
    }
    
    func isOpen() -> Bool {
        if ws != nil && ws.readyState == .OPEN {
            return true
        }
        
        return false
    }
    
    // MARK: - Request
    
    func request(endPoint: String, handler: RequestHandler?) {
        return request(endPoint, params: [:], handler: handler)
    }
    
    func request(endPoint: String, params: [String: AnyObject], handler: RequestHandler?) {
        if delegate == nil {
            ASAPPLoge("ERROR: Delegate not set for conn")
            return
        }
        
        var context: [String: AnyObject] = [
            "CompanyId": delegate.customerTargetCompanyId()
        ]
        
        if !isCustomerEndpoint(endPoint) && state.targetCustomerToken() != nil {
            context = [
                "IssueId": delegate.issueId()
            ]
        }
        
        return request(endPoint, params: params, context: context, handler: handler)
    }
    
    func request(endPoint: String, params: [String: AnyObject], context: [String: AnyObject], handler: RequestHandler?) {
        let reqId = delegate.nextRequestId()
        if handler != nil {
            requestHandlers[reqId] = handler!
        }
        var paramsJSON = "{}"
        if NSJSONSerialization.isValidJSONObject(params) {
            do {
                let rawJSON = try NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
                paramsJSON = String(data: rawJSON, encoding: NSUTF8StringEncoding)!
            } catch {
                NSLog("ERROR: JSON Serialization failed")
            }
        }
        var contextJSON = "{}"
        if NSJSONSerialization.isValidJSONObject(context) {
            do {
                let rawJSON = try NSJSONSerialization.dataWithJSONObject(context, options: .PrettyPrinted)
                contextJSON = String(data: rawJSON, encoding: NSUTF8StringEncoding)!
            } catch {
                NSLog("ERROR: JSON Serialization failed")
            }
        }
        
        let requestStr = String(format: "%@|%d|%@|%@", endPoint, reqId, contextJSON, paramsJSON)
        ASAPPLog(requestStr)
        ws.send(requestStr)
    }
    
    func isCustomerEndpoint(endpoint: String) -> Bool {
        if endpoint.hasPrefix("customer/") {
            return true
        }
        
        return false
    }
    
    // MARK: - SocketRocket
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        ASAPPLog("ws opened")
        delegate.didChangeConnState(true)
//        authenticate()
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        ASAPPLog("WS-MESSAGE:", message)
        if delegate == nil {
            return
        }
        
        if let message = message as? String {
            let tokens = message.characters.split("|").map(String.init)
            if tokens[0] == ASAPPState.ASAPPMsgTypeResponse {
                if let handler = requestHandlers[Int(tokens[1])!] {
                    handler(message: tokens[2])
                }
            } else if tokens[0] == ASAPPState.ASAPPMsgTypeEvent {
                delegate.didReceiveMessage(tokens[1])
            }
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        ASAPPLog(error)
        delegate.didChangeConnState(false)
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        ASAPPLog(reason)
        delegate.didChangeConnState(false)
    }
}
