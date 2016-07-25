//
//  ConversationManager.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

// MARK:- ConversationManagerDelegate

protocol ConversationManagerDelegate {
    func conversationManager(manager: ConversationManager, didReceiveMessageEvent messageEvent: Event)
    func conversationManager(manager: ConversationManager, didUpdateRemoteTypingStatus isTyping: Bool, withEvent event: Event)
}

// MARK:- ConversationManager

class ConversationManager: NSObject {
    
    // MARK: Properties
    
    var credentials: Credentials
    
    var delegate: ConversationManagerDelegate?
    
    // MARK: Private Properties
    
    private var socketConnection: SocketConnection
    
    private var conversationStore: ConversationStore
    
    // MARK: Initialization
    
    init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        self.socketConnection = SocketConnection(withCredentials: self.credentials)
        self.conversationStore = ConversationStore(withCredentials: self.credentials)
        super.init()
        
        self.socketConnection.delegate = self
    }
    
    deinit {
        socketConnection.delegate = nil
    }
}

// MARK:- Network Actions

extension ConversationManager {
    func enterConversation() {
        socketConnection.connectIfNeeded()
    }
    
    func exitConversation() {
        socketConnection.disconnect()
    }
    
    func sendMessage(message: String) {
        let path = "\(credentials.isCustomer ? "customer/" : "rep/")SendTextMessage"
        socketConnection.sendRequest(withPath: path, params: ["Text" : message])
    }
    
    func getStoredMessages() -> [Event]? {
        return conversationStore.messageEvents
    }
}

// MARK:- SocketConnectionDelegate

extension ConversationManager: SocketConnectionDelegate {
    func socketConnection(socketConnection: SocketConnection, didReceiveMessage message: IncomingMessage) {
        
        if message.type == .Event {
            if let event = Event(withJSON: message.body) {
                event.isNew = true
                
                switch event.eventType {
                case .TextMessage:
                    conversationStore.addEvent(event)
                    delegate?.conversationManager(self, didReceiveMessageEvent: event)
                    break
                  
                case .None:
                    switch event.ephemeralType {
                    case .TypingStatus:
                        if let typingStatus = event.payload as? EventPayload.TypingStatus {
                            delegate?.conversationManager(self, didUpdateRemoteTypingStatus: typingStatus.isTyping, withEvent: event)
                        }
                        break
                        
                    default:
                        // Not yet handled
                        break
                    }
                    break
                    
                    
                default:
                    // Not yet handled
                    break
                }
                
            }
        }
    }


    func socketConnection(socketConnection: SocketConnection, didChangeConnectionStatus isConnected: Bool) {
    
    }
}
