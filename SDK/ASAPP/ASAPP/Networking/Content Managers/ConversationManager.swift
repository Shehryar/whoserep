//
//  ConversationManager.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class ConversationManager: NSObject {
    
    let config: ASAPPConfig
    
    let user: ASAPPUser
    
    let sessionManager: SessionManager
    
    weak var delegate: ConversationManagerDelegate?
    
    var originalSearchQuery: String? {
        set {
            simpleStore.updateSRSOriginalSearchQuery(query: newValue)
        }
        get {
            return simpleStore.getSRSOriginalSearchQuery()
        }
    }
    
    var currentSRSClassification: String? {
        didSet {
            DebugLog.d(caller: self, "Updating currentSRSClassification: \(currentSRSClassification ?? "nil")")
        }
    }
    
    var isConnected: Bool {
        return socketConnection.isConnected
    }
    
    fileprivate let simpleStore: ChatSimpleStore
    
    fileprivate(set) var events: [Event]
    
    fileprivate(set) var isLiveChat: Bool
    
    fileprivate var conversantBeganTypingTime: TimeInterval?
    
    fileprivate var timer: Timer?
    
    // MARK: Private Properties
    
    let socketConnection: SocketConnection
    
    let fileStore: ConversationFileStore
    
    // MARK: Initialization
    
    init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction?) {
        self.config = config
        self.user = user
        self.sessionManager = SessionManager(config: config, user: user)
        self.simpleStore = ChatSimpleStore(config: config, user: user)
        self.socketConnection = SocketConnection(config: config, user: user, userLoginAction: userLoginAction)
        self.fileStore = ConversationFileStore(config: config, user: user)
        self.events = self.fileStore.getSavedEvents() ?? [Event]()
        self.isLiveChat = EventType.getLiveChatStatus(from: self.events)
        super.init()
        
        self.socketConnection.delegate = self
        self.timer = Timer.scheduledTimer(timeInterval: 6,
                                          target: self,
                                          selector:  #selector(ConversationManager.checkForTypingStatusChange),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    deinit {
        socketConnection.delegate = nil
        
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }
}

// MARK:- Utility

extension ConversationManager {
    
    func isConnected(retryConnectionIfNeeded: Bool = false) -> Bool {
        if !isConnected && retryConnectionIfNeeded {
            socketConnection.connectIfNeeded()
        }
        
        return isConnected
    }
    
    func checkForTypingStatusChange() {
        guard let conversantBeganTypingTime = conversantBeganTypingTime else {
            return
        }
        
        let timeSinceConversantBeganTyping = Date.timeIntervalSinceReferenceDate - conversantBeganTypingTime
        if timeSinceConversantBeganTyping > 10 {
            self.conversantBeganTypingTime = nil
            delegate?.conversationManager(self, didChangeTypingStatus: false)
        }
    }
    
    func saveCurrentEvents(async: Bool = false) {
        fileStore.save(async: async)
    }
}

// MARK:- Entering/Leaving a Conversation

extension ConversationManager {
    
    func enterConversation() {
        DebugLog.d(caller: self, "Entering Conversation")
        
        socketConnection.connectIfNeeded()
    }
    
    func exitConversation() {
        DebugLog.d(caller: self, "Exiting Conversation")
        
        fileStore.save()
        socketConnection.disconnect()
    }
}

// MARK:- Requests 

extension ConversationManager {
    
    func getRequestParameters(with params: [String : Any]?,
                              requiresContext: Bool = true,
                              insertContextAsString: Bool = true,
                              contextKey: String = "Context",
                              completion: @escaping (_ params: [String : Any]) -> Void) {
        
        var requestParams: [String : Any] = [
            ASAPP.CLIENT_TYPE_KEY: ASAPP.CLIENT_TYPE_VALUE,
            ASAPP.CLIENT_VERSION_KEY: ASAPP.clientVersion
            ].with(params)
        
        if requiresContext {
            user.getContext(completion: { (context, authToken) in
                if let context = context {
                    if !insertContextAsString {
                        requestParams[contextKey] =  context
                    } else if insertContextAsString, let contextString = JSONUtil.stringify(context) {
                        requestParams[contextKey] =  contextString
                    }
                }
                if let authToken = authToken {
                    requestParams["Auth"] = authToken
                }
                completion(requestParams)
            })
        } else {
            completion(requestParams)
        }
    }
    
    func sendRequest(path: String,
                     params: [String : Any]? = nil,
                     requiresContext: Bool = true,
                     isRequestFromPrediction: Bool = false,
                     completion: IncomingMessageHandler? = nil) {
                
        getRequestParameters(with: params, requiresContext: requiresContext) { (requestParams) in
    
            self.socketConnection.sendRequest(withPath: path, params: requestParams, context: nil, requestHandler: { (incomingMessage, request, responseTime) in
                completion?(incomingMessage, request, responseTime)
       
                if path.contains("srs/") {
                    self.trackSRSRequest(path: path,
                                         requestUUID: request?.requestUUID,
                                         isPredictive: isRequestFromPrediction,
                                         params: params,
                                         responseTimeInMilliseconds: responseTime)
                }
            })
        }
    }
}

// MARK:- Fetching Events

extension ConversationManager {
    
    typealias FetchedEventsCompletion = (_ fetchedEvents: [Event]?, _ error: String?) -> Void
    
    func getEvents(afterEvent: Event? = nil,
                   completion: @escaping FetchedEventsCompletion) {
        
        let path = "customer/GetEvents"
        let afterSeq = afterEvent != nil ? afterEvent!.eventLogSeq : 0
        let params = ["AfterSeq": afterSeq as AnyObject]
        
        socketConnection.sendRequest(withPath: path, params: params) { (message: IncomingMessage, _, _) in
            
            Dispatcher.performOnBackgroundThread { [weak self] in
                guard let strongSelf = self else {
                    return
                }
            
                let (events, eventsJSONArray, errorMessage) = message.parseEvents()
                if let events = events, let eventsJSONArray = eventsJSONArray {
                    strongSelf.events = events
                    strongSelf.fileStore.replaceEventsWithJSONArray(eventsJSONArray: eventsJSONArray)
                    strongSelf.isLiveChat = EventType.getLiveChatStatus(from: strongSelf.events)
                }
                
                Dispatcher.performOnMainThread {
                    completion(events, errorMessage)
                }
            }
        }
    }
}

// MARK:- Quick Replies

extension ConversationManager {
    
    func getQuickReplyMessages() -> [ChatMessage]? {
        guard let (currentQuickReplyEvent, currentQuickReplyMessage) = getCurrentQuickReplyMessage() else {
            return nil
        }
        
        var quickReplyMessages: [ChatMessage] = [currentQuickReplyMessage]
        var parentEventLogSeq = currentQuickReplyEvent.parentEventLogSeq
        
        for (_, event) in events.enumerated().reversed() {
            if parentEventLogSeq == nil || parentEventLogSeq! > event.eventLogSeq || parentEventLogSeq == 0 {
                break
            }
            
            if event.eventLogSeq == parentEventLogSeq {
                if let message = event.chatMessage {
                    quickReplyMessages.append(message)
                    parentEventLogSeq = event.parentEventLogSeq
                } else {
                    break
                }
            }
        }
        
        return quickReplyMessages.reversed()
    }
    
    private func getCurrentQuickReplyMessage() -> (Event, ChatMessage)? {
        for (_, event) in events.enumerated().reversed() {
            if event.eventType == .accountMerge {
                break
            }
            
            if event.isReply {
                if let chatMessage = event.chatMessage,
                    let quickReplies = chatMessage.quickReplies, !quickReplies.isEmpty {
                    return (event, chatMessage)
                }
                break
            }
        }
        
        return nil
    }
}

// MARK:- SocketConnectionDelegate

extension ConversationManager: SocketConnectionDelegate {
    
    func socketConnection(_ socketConnection: SocketConnection, didReceiveMessage message: IncomingMessage) {
        guard message.type == .event, let event = Event.fromJSON(message.body) else {
            return
        }
    
        if event.ephemeralType == .none {
            events.append(event)
            fileStore.addEventJSONString(eventJSONString: message.bodyString)
        }
        
        // Entering / Exiting Live Chat
        if let liveChatStatus = EventType.getLiveChatStatus(for: event.eventType) {
            let wasLiveChat = isLiveChat
            isLiveChat = liveChatStatus
            if wasLiveChat != isLiveChat {
                delegate?.conversationManager(self, didChangeLiveChatStatus: liveChatStatus, with: event)
            }
        }
        
        // Typing Status
        if event.ephemeralType == .typingStatus {
            if let typingStatus = event.typingStatus {
                delegate?.conversationManager(self, didChangeTypingStatus: typingStatus)
                if typingStatus {
                    conversantBeganTypingTime = Date.timeIntervalSinceReferenceDate
                }
            }
            return
        }
        
        // Updated Event
        if event.ephemeralType == .eventStatus {
            if let message = event.chatMessage {
                delegate?.conversationManager(self, didUpdate: message)
            } else {
                DebugLog.d("Missing message on updated event")
            }
            return
        }
        
        // Message Event
        if let message = event.chatMessage {
            if message.metadata.isAutomatedMessage {
                Dispatcher.delay(600, closure: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.delegate?.conversationManager(strongSelf, didReceive: message)
                })
            } else {
                delegate?.conversationManager(self, didReceive: message)
            }
        }
    }
    
    func socketConnectionEstablishedConnection(_ socketConnection: SocketConnection) {
        DebugLog.d("ConversationManager: Established Connection")
        
        delegate?.conversationManager(self, didChangeConnectionStatus: true)
    }
    
    func socketConnectionFailedToAuthenticate(_ socketConnection: SocketConnection) {
        DebugLog.d("ConversationManager: Authentication Failed")
        
        delegate?.conversationManager(self, didChangeConnectionStatus: false)
    }
    
    func socketConnectionDidLoseConnection(_ socketConnection: SocketConnection) {
        DebugLog.d("ConversationManager: Connection Lost")
        
        delegate?.conversationManager(self, didChangeConnectionStatus: false)
    }
}
