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
        self.socketConnection = ChatSocketConnection(withCredentials: self.credentials)
        self.conversationStore = ConversationStore(withCredentials: self.credentials)
        super.init()
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
       socketConnection.sendChatMessage(withText: text)
    }
}
