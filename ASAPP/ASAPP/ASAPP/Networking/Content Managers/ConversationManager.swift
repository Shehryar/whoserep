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
    func conversationManager(manager: ConversationManager, connectionStatusDidChange isConnected: Bool)
}

// MARK:- ConversationManager

class ConversationManager: NSObject {
    
    typealias ConversationManagerRequestBlock = ((fetchedEvents: [Event]?, error: String?) -> Void)
    
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
    var storedMessages: [Event] {
        return conversationStore.getMessageEvents()
    }

    func enterConversation() {
        socketConnection.connectIfNeeded()
    }
    
    func exitConversation() {
        socketConnection.disconnect()
    }
    
    func sendMessage(message: String) {
        let path = "\(requestPrefix)SendTextMessage"
        socketConnection.sendRequest(withPath: path, params: ["Text" : message])
    }
    
    func getLatestMessages(completion: ConversationManagerRequestBlock) {
        getMessageEvents { (fetchedEvents, error) in
            if let fetchedEvents = fetchedEvents {
                self.conversationStore.updateWithRecentMessageEvents(fetchedEvents)
                completion(fetchedEvents: fetchedEvents, error: error)
            }
        }
    }

    /// Returns all types of events
    func getMessageEvents(afterEvent: Event? = nil, completion: ConversationManagerRequestBlock) {
        let path = "\(requestPrefix)GetEvents"
        var params = [String : AnyObject]()
        if let afterEvent = afterEvent {
            params["AfterSeq"] = afterEvent.eventLogSeq
        }
        
        socketConnection.sendRequest(withPath: path, params: params) { (message: IncomingMessage) in
            var fetchedEvents: [Event]?
            var errorMessage: String?
            
            if message.type == .Response {
                if let fetchedEventsJSON = (message.body?["EventList"] as? [AnyObject] ??
                    message.body?["Events"] as? [AnyObject]) {
                    fetchedEvents = [Event]()
                    for eventJSON in fetchedEventsJSON {
                        guard let eventJSON = eventJSON as? [String : AnyObject] else {
                            continue
                        }
                        if let event = Event(withJSON: eventJSON) {
                            fetchedEvents?.append(event)
                        }
                    }
                }
            } else if message.type == .ResponseError {
                errorMessage = message.debugError
            }
            
            let numberOfEventsFetched = (fetchedEvents != nil ? fetchedEvents!.count : 0)
            if numberOfEventsFetched == 0 {
                errorMessage = errorMessage ?? "No results returned."
            }
            
            DebugLog("Fetched \(numberOfEventsFetched) events\(errorMessage != nil ? "with error: \(errorMessage!)" : "")")
            
            completion(fetchedEvents: fetchedEvents, error: errorMessage)
        }
    }
    
    private var requestPrefix: String {
        return credentials.isCustomer ? "customer/" : "rep/"
    }
}

// MARK:- SocketConnectionDelegate

extension ConversationManager: SocketConnectionDelegate {
    func socketConnection(socketConnection: SocketConnection, didReceiveMessage message: IncomingMessage) {
        
        if message.type == .Event {
            if let event = Event(withJSON: message.body) {
                conversationStore.addEvent(event)
                
                switch event.eventType {
                case .TextMessage:
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
        delegate?.conversationManager(self, connectionStatusDidChange: isConnected)
    }
}
