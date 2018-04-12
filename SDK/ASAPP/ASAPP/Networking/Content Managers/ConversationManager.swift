//
//  ConversationManager.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

protocol ConversationManagerProtocol {
    typealias ComponentViewHandler = (ComponentViewContainer?) -> Void
    typealias FetchedEventsCompletion = (_ fetchedEvents: [Event]?, _ error: String?) -> Void
    
    init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction?)
    
    weak var delegate: ConversationManagerDelegate? { get set }
    var events: [Event] { get }
    var currentSRSClassification: String? { get set }
    var isLiveChat: Bool { get }
    var isConnected: Bool { get }
    
    func enterConversation()
    func exitConversation()
    func saveCurrentEvents(async: Bool)
    func isConnected(retryConnectionIfNeeded: Bool) -> Bool
    
    func getCurrentQuickReplyMessage() -> ChatMessage?
    func getEvents(afterEvent: Event?, completion: @escaping FetchedEventsCompletion)
    func sendEnterChatRequest(_ completion: (() -> Void)?)
    func sendRequestForAPIAction(_ action: Action?, formData: [String: Any]?, completion: @escaping APIActionResponseHandler)
    func sendRequestForDeepLinkAction(_ action: Action?, with buttonTitle: String)
    func sendRequestForHTTPAction(_ action: Action, formData: [String: Any]?, completion: @escaping HTTPClient.DictCompletionHandler)
    func sendRequestForTreewalkAction(_ action: TreewalkAction, messageText: String?, parentMessage: ChatMessage?, completion: ((Bool) -> Void)?)
    func getComponentView(named name: String, data: [String: Any]?, completion: @escaping ComponentViewHandler)
    func sendUserTypingStatus(isTyping: Bool, withText text: String?)
    func sendAskRequest(_ completion: ((_ success: Bool) -> Void)?)
    func sendPictureMessage(_ image: UIImage, completion: (() -> Void)?)
    func sendTextMessage(_ message: String, completion: RequestResponseHandler?)
    func sendSRSQuery(_ query: String, isRequestFromPrediction: Bool)
    func endLiveChat() -> Bool
}

extension ConversationManagerProtocol {
    func sendEnterChatRequest() {
        return sendEnterChatRequest(nil)
    }
    
    func saveCurrentEvents() {
        return saveCurrentEvents(async: false)
    }
    
    func sendPictureMessage(_ image: UIImage) {
        return sendPictureMessage(image, completion: nil)
    }
    
    func sendTextMessage(_ message: String) {
        return sendTextMessage(message, completion: nil)
    }
    
    func getEvents(completion: @escaping FetchedEventsCompletion) {
        return getEvents(afterEvent: nil, completion: completion)
    }
}

class ConversationManager: NSObject, ConversationManagerProtocol {
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
    
    private let simpleStore: ChatSimpleStore
    
    private(set) var events: [Event]
    
    private(set) var isLiveChat: Bool
    
    private var conversantBeganTypingTime: TimeInterval?
    
    private var timer: Timer?
    
    // MARK: Private Properties
    
    let socketConnection: SocketConnection
    
    let httpClient: HTTPClientProtocol
    
    let fileStore: ConversationFileStore
    
    // MARK: Initialization
    
    required init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction?) {
        self.config = config
        self.user = user
        self.sessionManager = SessionManager(config: config, user: user)
        self.simpleStore = ChatSimpleStore(config: config, user: user)
        self.socketConnection = SocketConnection(config: config, user: user, userLoginAction: userLoginAction)
        self.httpClient = HTTPClient.shared
        self.httpClient.config(config)
        self.fileStore = ConversationFileStore(config: config, user: user)
        self.events = self.fileStore.getSavedEvents() ?? [Event]()
        self.isLiveChat = EventType.getLiveChatStatus(from: self.events)
        super.init()
        
        self.socketConnection.delegate = self
        self.timer = Timer.scheduledTimer(timeInterval: 6,
                                          target: self,
                                          selector: #selector(ConversationManager.checkForTypingStatusChange),
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

// MARK: - Utility

extension ConversationManager {
    
    func isConnected(retryConnectionIfNeeded: Bool = false) -> Bool {
        if !isConnected && retryConnectionIfNeeded {
            socketConnection.connectIfNeeded()
        }
        
        return isConnected
    }
    
    @objc func checkForTypingStatusChange() {
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

// MARK: - Entering/Leaving a Conversation

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

// MARK: - Requests 

extension ConversationManager {
    
    func getRequestParameters(with params: [String: Any]?,
                              requiresContext: Bool = true,
                              insertContextAsString: Bool = true,
                              contextKey: String = "Context",
                              completion: @escaping (_ params: [String: Any]) -> Void) {
        
        var requestParams: [String: Any] = [
            ASAPP.clientTypeKey: ASAPP.clientType,
            ASAPP.clientVersionKey: ASAPP.clientVersion
        ].with(params)
        
        if requiresContext {
            user.getContext(completion: { [weak self] (context, authToken) in
                if let context = context {
                    var updatedContext = context
                    if let strongSelf = self, !strongSelf.user.isAnonymous {
                        updatedContext[strongSelf.config.identifierType] = strongSelf.user.userIdentifier
                    }
                    
                    if !insertContextAsString {
                        requestParams[contextKey] =  updatedContext
                    } else if insertContextAsString, let contextString = JSONUtil.stringify(updatedContext) {
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
                     params: [String: Any]? = nil,
                     requiresContext: Bool = true,
                     completion: RequestResponseHandler? = nil) {
                
        getRequestParameters(with: params, requiresContext: requiresContext) { [httpClient] requestParams in
            httpClient.sendRequest(method: .POST, path: path, params: requestParams) { (data: [String: Any]?, _, error) in
                guard error == nil else {
                    let message = IncomingMessage.errorMessage(error?.localizedDescription ?? "Response error")
                    completion?(message)
                    return
                }
                
                let message = IncomingMessage()
                message.body = data
                message.type = .response
                completion?(message)
            }
        }
    }
}

// MARK: - Fetching Events

extension ConversationManager {
    
    typealias FetchedEventsCompletion = (_ fetchedEvents: [Event]?, _ error: String?) -> Void
    
    func getEvents(afterEvent: Event? = nil,
                   completion: @escaping FetchedEventsCompletion) {
        
        let path = "customer/GetEvents"
        let afterSeq = afterEvent != nil ? afterEvent!.eventLogSeq : 0
        let params = ["AfterSeq": afterSeq]
        
        httpClient.sendRequest(method: .POST, path: path, params: params) { (data: [String: Any]?, _, error) in
            guard let data = data,
                  error == nil else {
                completion(nil, "Error fetching events.")
                return
            }
            
            Dispatcher.performOnBackgroundThread { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                let message = IncomingMessage()
                message.body = data
                message.type = .response
                
                let parsedEvents = message.parseEvents()
                if let events = parsedEvents.events, let eventsJSONArray = parsedEvents.eventsJSONArray {
                    strongSelf.events = events
                    strongSelf.fileStore.replaceEventsWithJSONArray(eventsJSONArray: eventsJSONArray)
                    strongSelf.isLiveChat = EventType.getLiveChatStatus(from: strongSelf.events)
                }
                
                Dispatcher.performOnMainThread {
                    completion(parsedEvents.events, parsedEvents.errorMessage)
                }
            }
        }
    }
}

// MARK: - Quick Replies

extension ConversationManager {
    func getCurrentQuickReplyMessage() -> ChatMessage? {
        for event in events.reversed() {
            if event.eventType == .accountMerge {
                break
            }
            
            if event.isReplyMessageEvent {
                if let chatMessage = event.chatMessage,
                   let quickReplies = chatMessage.quickReplies, !quickReplies.isEmpty {
                    return chatMessage
                }
                break
            }
        }
        
        return nil
    }
}

// MARK: - SocketConnectionDelegate

extension ConversationManager: SocketConnectionDelegate {
    
    func socketConnection(_ socketConnection: SocketConnection, didReceiveMessage message: IncomingMessage) {
        guard message.type == .event,
              let body = message.body,
              let event = Event.fromJSON(body) else {
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
        
        // Continue Event
        if event.ephemeralType == .continue {
            delegate?.conversationManager(self, didReturnAfterInactivityWith: event)
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
        
        httpClient.session = socketConnection.session
        PushNotificationsManager.shared.session = socketConnection.session
        
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
