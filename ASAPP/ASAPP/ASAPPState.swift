//
//  ASAPPModel.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/15/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation
import RealmSwift

protocol ASAPPStateDelegate {
    func didClearEventLog()
}

protocol ASAPPStateDataSource {
    func isConnected() -> Bool
    func isCustomer() -> Bool
    func isMyEvent(event:ASAPPEvent) -> Bool
    
    func nextRequestId() -> Int
    func myId() -> Int
    func issueId() -> Int
    func customerTargetCompanyId() -> Int
    func targetCustomerToken() -> String?
    
    func fetchEvents(afterSeq: Int)
    func eventsFromEventLog() -> Results<ASAPPEvent>?
}

protocol ASAPPStateAction {
    func sendMessage(message: String)
}

// MARK: - To register/deregister for events

enum ASAPPNotificationType {
    case Connect
    case Disconnect
    case Event
    case Auth
    case Unauth
    case FetchedEvents
}

typealias ASAPPClosure = (info: AnyObject?) -> Void

protocol ASAPPStateEventCenter {
    func on(notificationType: ASAPPNotificationType, observer: AnyObject, closure: ASAPPClosure)
    func off(notificationType: ASAPPNotificationType, observer: AnyObject)
}

// MARK: - Used by Realm

class ASAPPStateModel: Object {
    // Required
    dynamic var companyMarker: String = ""
    dynamic var userToken: String? = nil
    dynamic var isCustomer: Bool = true
    
    // Updated later
    dynamic var targetCustomerToken: String = ""
    dynamic var myId: Int = 0
    dynamic var customerTargetCompanyId: Int = 0
    dynamic var issueId: Int = 0
    dynamic var reqId: Int = 0
    dynamic var sessionInfo: String? = nil
}

class ASAPPState: NSObject, ASAPPStateDataSource, ASAPPStateEventCenter, ASAPPStateAction, ASAPPConnDelegate, ASAPPEventLogDelegate {
    
    var conn: ASAPPConn!
    var eventLog: ASAPPEventLog!
    var store: ASAPPStore!
    
    // Keys for saving data
    let ASAPPSessionKey: String = "ASAPP_SESSION_KEY"
    
    // Websocket Message Types
    static let ASAPPMsgTypeResponse: String = "Response"
    static let ASAPPMsgTypeEvent: String = "Event"
    static let ASAPPMsgTypeResponseError: String = "ResponseError"
    
    func loadOrCreate(company: String, userToken: String?, isCustomer: Bool) {
        ASAPPLog("Initializing State")
        
        store = ASAPPStore()
        store.loadOrCreate(company, userToken: userToken, isCustomer: isCustomer)
        
        eventLog = ASAPPEventLog(dataSource: self, delegate: self, store: store)
        eventLog.load()
        
        conn = ASAPPConn(dataSource: self, delegate: self)
        conn.connect()
        
        if self.isCustomer() {
            self.on(.Auth, observer: self, closure: { [weak self] (info) in
                guard self != nil else {
                    return
                }
                
                self?.eventLog.load()
            })
        }
    }
    
    // MARK: - ASAPPConnDelegate
    
    func didReceiveMessage(message: AnyObject) {
        if let message = message as? String {
            eventLog.processEvent(message, isNew: true)
        }
    }
    
    func didChangeConnState(isConnected: Bool) {
        if isConnected {
            fire(.Connect, info: nil)
            authenticate()
        } else {
            fire(.Disconnect, info: nil)
        }
    }
    
    // MARK: ASAPPStateDataSource
    
    func isConnected() -> Bool {
        return conn.isOpen()
    }
    
    func isCustomer() -> Bool {
        guard let isCustomer = store.stateProperty("isCustomer") as? Bool else {
            return true
        }
        
        return isCustomer
    }
    
    func customerTargetCompanyId() -> Int {
        guard let customerTargetCompanyId = store.stateProperty("customerTargetCompanyId") as? Int else {
            return 0
        }
        
        return customerTargetCompanyId
    }
    
    func targetCustomerToken() -> String? {
        guard let targetCustomerToken = store.stateProperty("targetCustomerToken") as? String else {
            return nil
        }
        
        return targetCustomerToken
    }
    
    func issueId() -> Int {
        guard let issueId = store.stateProperty("issueId") as? Int else {
            return 0
        }
        
        return issueId
    }
    
    func myId() -> Int {
        guard let myId = store.stateProperty("myId") as? Int else {
            return 0
        }
        
        return myId
    }
    
    func isMyEvent(event:ASAPPEvent) -> Bool {
        if isCustomer() && event.isCustomerEvent() {
            return true
        } else if !isCustomer() && myId() == event.RepId {
            return true
        }
        
        return false
    }
    
    func nextRequestId() -> Int {
        var reqId = 1
        
        objc_sync_enter(self)
        if let curReqId = store.stateProperty("reqId") as? Int {
            reqId = curReqId + 1
        }
        
        store.updateState(reqId, forKeyPath: "reqId")
        objc_sync_exit(self)
        
        return reqId
    }
    
    func eventsFromEventLog() -> Results<ASAPPEvent>? {
        return eventLog.events
    }
    
    // MARK: - Authentication

    func authenticate() {
        if let sessionInfo = store.stateProperty("sessionInfo") as? String {
            authenticateWithSession(sessionInfo)
        } else if let userToken = store.stateProperty("userToken") as? String {
            if isCustomer() {
                authenticateCustomerWithToken(userToken)
            } else {
                authenticateWithToken(userToken)
            }
        } else {
            createAnonAccount()
        }
    }
    
    func authenticateWithSession(session: String) {
        var jsonObj: [String: AnyObject] = [:]
        do {
            jsonObj = try NSJSONSerialization.JSONObjectWithData(session.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as! [String: AnyObject]
        } catch let error as NSError {
            ASAPPLoge(error)
        }
        
        let params: [String: AnyObject] = [
            "SessionInfo": jsonObj,
            "App": "ios-sdk"
        ]
        conn.request("auth/AuthenticateWithSession", params: params) { [weak self] (message) in
            guard self != nil else {
                return
            }
            
            if let authInfo = message as? String {
                self?.handleAuthIfNeeded(authInfo)
            }
        }
    }
    
    func authenticateCustomerWithToken(token: String) {
        let params: [String: AnyObject] = [
            "CompanyMarker": "vs-dev",
            "Identifiers": token,
            "App": "ios-sdk"
        ]
        conn.request("auth/AuthenticateWithCustomerToken", params: params) { [weak self] (message) in
            guard self != nil else {
                return
            }
            
            if let authInfo = message as? String {
                self?.handleAuthIfNeeded(authInfo)
            }
        }
    }
    
    func authenticateWithToken(token: String) {
        let params: [String: AnyObject] = [
            "Company": "vs-dev",
            "AuthCallbackData": token,
            "GhostEmailAddress": "",
            "CountConnectionForIssueTimeout": false,
            "App": "ios-sdk"
        ]
        conn.request("auth/AuthenticateWithSalesForceToken", params: params) { [weak self] (message) in
            guard self != nil else {
                return
            }
            
            if let authInfo = message as? String {
                self?.handleAuthIfNeeded(authInfo)
            }
        }
    }
    
    func createAnonAccount() {
        let params: [String: AnyObject] = [
            "CompanyMarker": "vs-dev",
            "RegionCode": "US"
        ]
        conn.request("auth/CreateAnonCustomerAccount", params: params) { [weak self] (message) in
            guard self != nil else {
                return
            }
            
            if let authInfo = message as? String {
                self?.handleAuthIfNeeded(authInfo)
            }
        }
    }
    
    // MARK: - State Notifications
    
    struct ASAPPNotificationObserver {
        let Observer: AnyObject
        let Closure: ASAPPClosure
    }
    
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
    
    func handleAuthIfNeeded(authInfo: String) {
        if authInfo == "null" {
            return
        }
        do {
            let jsonObj = try NSJSONSerialization.JSONObjectWithData(authInfo.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as! [String: AnyObject]
            
            if let sessionInfo = jsonObj["SessionInfo"] as? [String: AnyObject] {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(sessionInfo, options: [])
                store.updateState(String(data: jsonData, encoding: NSUTF8StringEncoding) , forKeyPath: "sessionInfo")
                
                if let company = sessionInfo["Company"] as? [String: AnyObject] {
                    if let companyId = company["CompanyId"] as? Int {
                        store.updateState(companyId, forKeyPath: "customerTargetCompanyId")
                    }
                }
                
                if isCustomer() {
                    if let customer = sessionInfo["Customer"] as? [String: AnyObject] {
                        if let rawId = customer["CustomerId"] as? UInt {
                            store.updateState(rawId, forKeyPath: "myId")
                        }
                    }
                } else {
                    if let customer = sessionInfo["Rep"] as? [String: AnyObject] {
                        if let rawId = customer["RepId"] as? UInt {
                            store.updateState(rawId, forKeyPath: "myId")
                        }
                    }
                }
                
                fire(.Auth, info: nil)
            }
        } catch let err as NSError {
            ASAPPLoge(err)
        }
        
        return
    }
    
    func didProcessEvent(event: ASAPPEvent, isNew: Bool) {
        let info: [String: AnyObject] = [
            "event": event,
            "isNew": isNew
        ]
        fire(.Event, info: info)
    }
    
    func didClearEventLog() {
        
    }
    
    func fetchEvents(afterSeq: Int) {
        if conn == nil {
            return
        }
        
        let params: [String: AnyObject] = [
            "AfterSeq": afterSeq
        ]
        
        conn.request(prefixForRequests() + "GetEvents", params: params) { [weak self] (message) in
            ASAPPLog(message)
            
            guard self != nil,
                let eventData = message as? String else {
                return
            }
            
            do {
                let jsonObj = try NSJSONSerialization.JSONObjectWithData(eventData.dataUsingEncoding(NSUTF8StringEncoding)!, options: [])
                
                var events: [AnyObject] = []
                
                // This is bad because server uses different keys for returning events for rep and customers
                if let repEvents = jsonObj["Events"] as? [AnyObject] {
                    events = repEvents
                } else if let customerEvents = jsonObj["EventList"] as? [AnyObject] {
                    events = customerEvents
                }
                
                for event in events {
                    let rawJSON = try NSJSONSerialization.dataWithJSONObject(event, options: .PrettyPrinted)
                    self!.eventLog.processEvent(String(data: rawJSON, encoding: NSUTF8StringEncoding)!, isNew: false)
                }
                
                self!.fire(.FetchedEvents, info: nil)
            } catch let error as NSError {
                ASAPPLoge(error)
            }
        }
    }
    
    // MARK: - Actions
    
    func prefixForRequests() -> String {
        if isCustomer() {
            return "customer/"
        }
        
        return "rep/"
    }
    
    func sendMessage(message: String) {
        let params: [String: AnyObject] = [
            "Text": message
        ]
        
        conn.request(prefixForRequests() + "SendTextMessage", params: params, handler: nil)
    }
    
    // MARK: - Rep chat actions
    
    func reloadStateForRep(targetCustomerToken: String) {
        store.updateState(targetCustomerToken, forKeyPath: "targetCustomerToken")
        eventLog.clearAll()
        customerByCRMCustomerId()
    }
    
    func customerByCRMCustomerId() {
        self.on(.Auth, observer: self) { [weak self] (info) in
            guard self != nil else {
                return
            }
            
            let params: [String: AnyObject] = [
                "CRMCustomerId": (self?.targetCustomerToken())!
            ]
            
            self!.conn.request("rep/GetCustomerByCRMCustomerId", params: params) { [weak self] (message) in
                ASAPPLog(message)
                
                guard self != nil,
                    let customerData = message as? String else {
                    return
                }
                
                do {
                    let jsonObj = try NSJSONSerialization.JSONObjectWithData(customerData.dataUsingEncoding(NSUTF8StringEncoding)!, options: [])
                    
                    if let customer = jsonObj["Customer"] as? [String: AnyObject] {
                        if let customerId = customer["CustomerId"] as? Int {
                            self?.participateInIssueForCustomer(customerId)
                        }
                    }
                } catch let error as NSError {
                    ASAPPLoge(error)
                }
            }
        }
    }
    
    func participateInIssueForCustomer(customerId: Int) {
        let context: [String: AnyObject] = [
            "CustomerId": customerId
        ]
        conn.request("rep/ParticipateInIssueForCustomer", params: [:], context: context) { [weak self] (message) in
            ASAPPLog(message)
            
            guard self != nil,
                let issueIdData = message as? String else {
                    return
            }
            
            do {
                let jsonObj = try NSJSONSerialization.JSONObjectWithData(issueIdData.dataUsingEncoding(NSUTF8StringEncoding)!, options: [])
                
                if let issueId = jsonObj["IssueId"] as? Int {
                    self?.store.updateState(issueId, forKeyPath: "issueId")
                    self?.eventLog.load()
                }
            } catch let error as NSError {
                ASAPPLoge(error)
            }
        }
    }

}
