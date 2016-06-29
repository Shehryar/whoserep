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

class ASAPPState: NSObject, ASAPPConnDelegate, ASAPPEventLogDelegate {
    
    var conn: ASAPPConn!
    var eventLog: ASAPPEventLog!
    var realm: Realm!
    
    var mMyId: UInt = 0
    var mCustomerTargetCompanyId = 0
    var mIssueId = 0
    var mReqId: Int = 0
    
    // MARK: - Persistence
    
    // Keys for saving data
    let ASAPPSessionKey: String = "ASAPP_SESSION_KEY"
    
    // Websocket Message Types
    static let ASAPPMsgTypeResponse: String = "Response"
    static let ASAPPMsgTypeEvent: String = "Event"
    static let ASAPPMsgTypeResponseError: String = "ResponseError"
    
    override init() {
        super.init()
        print("Initializing State")
        
        let filePaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let filePath = filePaths[0].stringByAppendingString("/ASAPP.realm")
        let fileURL = NSURL(fileURLWithPath: filePath)
        print(NSFileManager.defaultManager().createFileAtPath(fileURL.absoluteString, contents: nil, attributes: nil))
        realm = try! Realm(fileURL: fileURL)
        ASAPPLog(realm.configuration.fileURL, filePath)
        
        eventLog = ASAPPEventLog()
        eventLog.delegate = self
        
        conn = ASAPPConn()
        conn.delegate = self
        conn.connect()
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
    
    func sessionInfoIfAvailable() -> String? {
//        let info = realm.objects(ASAPPSessionInfo.self)

        return nil
    }
    
    func customerTargetCompanyId() -> Int {
        return 1
    }
    
    func issueId() -> Int {
        return mIssueId
    }
    
    func nextRequestId() -> Int {
        var reqId = 0
        
        objc_sync_enter(self)
        reqId = mReqId
        mReqId += 1
        objc_sync_exit(self)
        
        return reqId
    }
    
    // MARK: - Authentication
    
    func authenticate() {
        let sessionInfo: String? = nil
        if sessionInfo != nil {
            authenticateWithSession(sessionInfo!)
        } else if ASAPP.instance.mUserToken != nil {
            authenticateWithToken(ASAPP.instance.mUserToken)
        } else {
            createAnonAccount()
        }
    }
    
    func authenticateWithSession(session: String) {
        let params: [String: AnyObject] = [
            "SessionInfo": session
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
    
    func authenticateWithToken(token: String) {
        let params: [String: AnyObject] = [
            "Company": "dev",
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
            "CompanyMarker": "text-rex",
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
    
    func handleAuthIfNeeded(authInfo: String) {
        if authInfo == "null" {
            return
        }
        do {
            let jsonObj = try NSJSONSerialization.JSONObjectWithData(authInfo.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as! [String: AnyObject]
            
            if let sessionInfo = jsonObj["SessionInfo"] as? [String: AnyObject] {
                saveToDefaults(sessionInfo, key: ASAPPSessionKey)
                
                if let company = sessionInfo["Company"] as? [String: AnyObject] {
                    if let companyId = company["CompanyId"] as? Int {
                        mCustomerTargetCompanyId = companyId
                    }
                }
                
                if ASAPP.isCustomer() {
                    if let customer = sessionInfo["Customer"] as? [String: AnyObject] {
                        if let rawId = customer["CustomerId"] as? UInt {
                            mMyId = rawId
                        }
                    }
                } else {
                    if let customer = sessionInfo["Rep"] as? [String: AnyObject] {
                        if let rawId = customer["RepId"] as? UInt {
                            mMyId = rawId
                        }
                    }
                }
                
                fire(.Auth, info: nil)
            }
        } catch let err as NSError {
            print(err)
        }
        
        return
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
    
    func didClearEventLog() {
        
    }
    
    func fetchEvents(afterSeq: Int) {
        var params: [String: AnyObject] = [
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
                
                if let events = jsonObj["Events"] as? [AnyObject] {
                    for event in events {
                        let rawJSON = try NSJSONSerialization.dataWithJSONObject(event, options: .PrettyPrinted)
                        self!.didReceiveMessage(String(data: rawJSON, encoding: NSUTF8StringEncoding)!)
                    }
                }
            } catch let error as NSError {
                ASAPPLoge(error)
            }
        }
    }
    
    // MARK: - Actions
    
    func prefixForRequests() -> String {
        if ASAPP.isCustomer() {
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
    
    // MARK: - State Info
    
    func isConnected() -> Bool {
        return conn.isOpen()
    }
    
    // MARK: - Rep chat actions
    
    func reloadStateForRep(targetCustomerToken: String) {
        eventLog.clearAll()
        customerByCRMCustomerId()
    }
    
    func customerByCRMCustomerId() {
        self.on(.Auth, observer: self) { [weak self] (info) in
            guard self != nil else {
                return
            }
            
            let params: [String: AnyObject] = [
                "CRMCustomerId": ASAPP.instance.mTargetCustomerToken
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
                    self?.mIssueId = issueId
                    self?.fetchEvents(0)
                }
            } catch let error as NSError {
                ASAPPLoge(error)
            }
        }
    }

}

// MARK: - SessionInfo
//
//class ASAPPSessionInfo: Object {
//    var AuthenticatedTime: Int64 = 0
//    var CountConnectionForIssueTimeout = false
//    var IsGhostSession = false
//    var Company: ASAPPCompany? = nil
//    var Customer: ASAPPCustomer? = nil
//    var Rep: ASAPPRep? = nil
//    var SessionAuth: ASAPPSessionAuth!
//    
//    class ASAPPCustomer: Object {
//        var CustomerId: UInt64 = 0
//        var LastCustomerEventLogSeq: UInt = 0
//        var CreatedTime: UInt64 = 0
//        var RegionId: UInt64 = 0
//    }
//    
//    class ASAPPCompany: Object {
//        var CompanyId: UInt64 = 0
//        var CRMCompanyId: String = ""
//        var CRMCompanyBridge: String = ""
//        var CompanyMarker: String = ""
//        var Name: String = ""
//        var CreatedTime: UInt64 = 0
//        var CreatedBySuperUserId: UInt64 = 0
//        var RootGroupId: UInt64 = 0
//    }
//    
//    class ASAPPSessionAuth: Object {
//        var AgentType: UInt8 = 0
//        var AgentId: UInt64 = 0
//        var SessionTime: Int64 = 0
//        var SessionSecret: String = ""
//    }
//    
//    class ASAPPRep: Object {
//        var CRMRepId: String = ""
//        var CompanyId: UInt64 = 0
//        var CreatedTime: Int64 = 0
//        var DisabledTime: Int64 = 0
//        var MadeAdminTime: Int64 = 0
//        var Name: String = ""
//        var RepId: UInt64 = 0
//        var RolesJSON: String = ""
//    }
//}
