//
//  ChatClient.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/20/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation
import RealmSwift

class ChatClient {

    // MARK:- Realm Properties
    
    dynamic var companyMarker: String = ""
    dynamic var userToken: String? = nil
    dynamic var isCustomer: Bool = true
    
    dynamic var targetCustomerToken: String = ""
    dynamic var myId: Int = 0
    dynamic var customerTargetCompanyId: Int = 0
    dynamic var issueId: Int = 0
    dynamic var reqId: Int = 0
    dynamic var sessionInfo: String? = nil
    
    // MARK:- Private Properties
    var api = ChatAPI()
//    var eventLog: EventLog
    var store = DataStore2()
    
    // MARK:- Initialization
    
    init(company: String, userToken: String?, isCustomer: Bool) {
        self.store.loadOrCreate(withCompany: company, userToken: userToken, isCustomer: isCustomer)
        
//        self.eventLog = EventLog(dataSource: self, delegate: self, store: store)
//        self.eventLog.load()
        
        self.api.dataSource = self
        self.api.delegate = self
    }
    
    deinit {
        api.dataSource = nil
        api.delegate = nil
    }
}

// MARK:- EventLogDelegate

extension ChatClient: EventLogDelegate {
    func didProcessEvent(event: Event, isNew: Bool) {
        
    }
    
    func didClearEventLog() {
        
    }
}

// MARK:- ChatAPIDelegate

extension ChatClient: ChatAPIDelegate {
    func chatAPI(api: ChatAPI, didChangeConnectionState state: ChatAPIConnectionState) {
        
    }
    
    func chatAPI(api: ChatAPI, didReceiveMessage message: AnyObject) {
        
    }
}

// MARK:- ChatAPIDataSource

extension ChatClient: ChatAPIDataSource {
    func targetCustomerTokenForChatAPI(api: ChatAPI) -> Int? {
        return 0
    }
    
    func customerTargetCompanyIdForChatAPI(api: ChatAPI) -> Int {
        return 0
    }
    
    func nextRequestIdForChatAPI(api: ChatAPI) -> Int {
        return 0
    }
    
    func issueIdForChatAPI(api: ChatAPI) -> Int {
        return 0
    }
}

