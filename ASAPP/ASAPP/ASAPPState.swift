//
//  ASAPPModel.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/15/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

protocol ASAPPModelDelegate {
    func didReceiveEvent(event: AnyObject)
}

class ASAPPState: NSObject, ASAPPConnDelegate, ASAPPEventLogDelegate {
    
    var conn: ASAPPConn!
    var eventLog: ASAPPEventLog!
    
    var mCustomerTargetCompanyId = 0
    
    // MARK: - Persistence
    
    // Keys for saving data
    let ASAPPSessionKey: String = "ASAPP_SESSION_KEY"
    
    // Websocket Message Types
    let ASAPPMsgTypeResponse: String = "Response"
    let ASAPPMsgTypeEvent: String = "Event"
    let ASAPPMsgTypeResponseError: String = "ResponseError"
    
    override init() {
        super.init()
        print("Initializing State")
        
        eventLog = ASAPPEventLog()
        eventLog.delegate = self
        
        conn = ASAPPConn()
        conn.delegate = self
        conn.connect()
    }
    
    // MARK: - ASAPPConnDelegate
    
    func didReceiveMessage(message: AnyObject) {
        if let message = message as? String {
            let tokens = message.characters.split("|").map(String.init)
            
            if tokens[0] == ASAPPMsgTypeResponse {
                let didHandleAuth = handleAuthIfNeeded(tokens[2])
            } else if tokens[0] == ASAPPMsgTypeEvent {
                eventLog.processEvent(tokens[1], isNew: true)
            }
        }
    }
    
    func didChangeConnState(isConnected: Bool) {
        if isConnected {
            fire(.Connect, info: nil)
        } else {
            fire(.Disconnect, info: nil)
        }
    }
    
    func sessionInfoIfAvailable() -> [String : AnyObject]? {
        return nil
    }
    
    func customerTargetCompanyId() -> Int {
        return 1
    }
    
    // MARK: - State Notifications
    
    enum ASAPPNotificationType {
        case Connect
        case Disconnect
        case Event
        case Auth
        case Unauth
    }
    
    struct ASAPPNotificationObserver {
        let Observer: AnyObject
        let Closure: ASAPPClosure
    }
    
    typealias ASAPPClosure = (info: AnyObject?) -> Void
    
    var asappNotificationObservers: [ASAPPNotificationType: [ASAPPNotificationObserver]] = [:]
    
    func on(notificationType: ASAPPNotificationType, observer: AnyObject, closure: ASAPPClosure) {
        let nObserver = ASAPPNotificationObserver(Observer: observer, Closure: closure)
        
        if asappNotificationObservers[notificationType] == nil {
            asappNotificationObservers[notificationType] = []
        }
        
        asappNotificationObservers[notificationType]?.append(nObserver)
    }
    
    func off(notificationType: ASAPPNotificationType, observer: AnyObject) {
        if let list = asappNotificationObservers[notificationType] {
            for item in list {
                if item.Observer === observer {
                }
            }
        }
    }
    
    func fire(notificationType: ASAPPNotificationType, info: AnyObject?) {
        if let list = asappNotificationObservers[notificationType] {
            for item in list {
                item.Closure(info: info)
            }
        }
    }
    
    // MARK: - Message/Event processing
    
    func handleAuthIfNeeded(authInfo: String) -> Bool {
        if authInfo == "null" {
            return false
        }
        var hasSessoinInfo = false
        do {
            let jsonObj = try NSJSONSerialization.JSONObjectWithData(authInfo.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as! [String: AnyObject]
            
            if let sessionInfo = jsonObj["SessionInfo"] as? [String: AnyObject] {
                hasSessoinInfo = true
                saveToDefaults(sessionInfo, key: ASAPPSessionKey)
                
                if let company = sessionInfo["Company"] as? [String: AnyObject] {
                    if let companyId = company["CompanyId"] as? Int {
                        mCustomerTargetCompanyId = companyId
                    }
                }
            }
        } catch let err as NSError {
            print(err)
        }
        
        return hasSessoinInfo
    }
    
    func saveToDefaults(value: AnyObject, key: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(value, forKey: key)
        userDefaults.synchronize()
    }
    
    func didProcessEvent(event: ASAPPEvent, isNew: Bool) {
        let info: [String: AnyObject] = [
            "event": event,
            "isNew": isNew
        ]
        fire(.Event, info: info)
    }
    
    // MARK: - Actions
    
    func sendMessage(message: String) {
        let params: [String: AnyObject] = [
            "Text": message
        ]
        conn.request("customer/SendTextMessage", params: params)
    }
    
    // MARK: - State Info
    
    func isConnected() -> Bool {
        return conn.isOpen()
    }
    
}