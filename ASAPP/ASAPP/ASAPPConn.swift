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
    func sessionInfoIfAvailable() -> [String: AnyObject]?
    func customerTargetCompanyId() -> Int
    
    func didChangeConnState(isConnected: Bool)
    func didReceiveMessage(message: AnyObject)
}

class ASAPPConn: NSObject, SRWebSocketDelegate {
    
    var ws: SRWebSocket!
    var delegate: ASAPPConnDelegate!
    
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
            print("ASAPP: Connection state is not closed")
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
    
    func authenticate() {
        let params: [String: AnyObject] = [
            "CompanyMarker": "text-rex",
            "RegionCode": "US"
        ]
        request("auth/CreateAnonCustomerAccount", params: params)
    }
    
    func authenticate(session: String) {
        
    }
    
    func sendMessage(message: String) {
        
    }
    
    // MARK: - Request
    
    func request(endPoint: String) {
        return request(endPoint, params: [:])
    }
    
    func request(endPoint: String, params: [String: AnyObject]) {
        let context: [String: AnyObject] = [
            "CompanyId": delegate.customerTargetCompanyId()
        ]
        return request(endPoint, params: params, context: context)
    }
    
    func request(endPoint: String, params: [String: AnyObject], context: [String: AnyObject]) {
        let reqId = 1
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
        print(requestStr)
        ws.send(requestStr)
    }
    
    // MARK: - SocketRocket
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        ASAPPLog("ws opened")
        delegate.didChangeConnState(true)
        authenticate()
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        print(message)
        if delegate == nil {
            return
        }
        
        delegate.didReceiveMessage(message)
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
