//
//  ConversationManager.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class ConversationManager: NSObject {

    // MARK: Properties
    
    public var credentials: Credentials
    
    public var messageEvents = [Event]()
    
    private var conversationStore: ConversationStore
    
    private var socketConnection: ChatSocketConnection
    
    public var onMessageReceived: ((message: Event, messages: [Event]) -> Void)?

    
    // MARK: Initialization
    
    init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        self.socketConnection = ChatSocketConnection()
        self.conversationStore = ConversationStore(withCredentials: self.credentials)
        super.init()
        
        self.socketConnection.dataSource = self
        self.socketConnection.onFullCredentialsUpdate = { [weak self] (fullCredentials, value, keyPath) in
            self?.conversationStore.updateFullCredentials(value, forKeyPath: keyPath)
        }
    }
    
    deinit {
        socketConnection.dataSource = nil
    }
}

// MARK:- Network Actions

extension ConversationManager {
    func connectIfNeeded() {
        socketConnection.connectIfNeeded()
    }
    
    func disconnect() {
        socketConnection.disconnect()
    }
    
    func sendMessage(withText text: String, completionHandler: ((error: NSError?) -> Void)?) {
        var path = "\(credentials.isCustomer ? "customer/" : "rep/")SendTextMessage"
        var params = ["Text" : text]
        socketConnection.sendRequest(withPath: path, params: params) { (message) in
            
        }
    }
}

// MARK:- ChatSockectConnectionDataSource

extension ConversationManager: ChatSockectConnectionDataSource {
    func targetCustomerTokenForSocketConnection(socketConnection: ChatSocketConnection) -> Int? {
        return 0
    }
    
    func customerTargetCompanyIdForSocketConnection(socketConnection: ChatSocketConnection) -> Int {
        return 0
    }
    
    func nextRequestIdForSocketConnection(socketConnection: ChatSocketConnection) -> Int {
        var reqId = 1
        
        objc_sync_enter(self)
        if let curReqId = conversationStore.fullCredentials?.reqId {
            reqId = curReqId + 1
        }
        conversationStore.updateFullCredentials(reqId, forKeyPath: "reqId")
        objc_sync_exit(self)
        
        return reqId
    }
    
    func issueIdForSocketConnection(socketConnection: ChatSocketConnection) -> Int {
        return 0
    }
    
    func fullCredentialsForSocketConnection(socketConnection: ChatSocketConnection) -> FullCredentials? {
        return conversationStore.fullCredentials
    }
}
