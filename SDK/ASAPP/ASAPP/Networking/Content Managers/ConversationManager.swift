//
//  ConversationManager.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

struct AutosuggestMetadata: Encodable {
    typealias ResponseId = String
    
    var responseId: ResponseId = ""
    var suggestion: String = ""
    var original: String = ""
    var index: Int = -1
    var displayedCount: Int = -1
    var returnedCount: Int = -1
    var keystrokesBeforeSelection: Int = -1
    var keystrokesAfterSelection: Int = -1
    
    enum CodingKeys: String, CodingKey {
        case responseId = "ResponseId"
        case suggestion = "Suggestion"
        case original = "Original"
        case index = "Index"
        case displayedCount = "DisplayedCount"
        case returnedCount = "ReturnedCount"
        case keystrokesBeforeSelection = "KeystrokesBeforeSelection"
        case keystrokesAfterSelection = "KeystrokesAfterSelection"
    }
}

protocol ConversationManagerProtocol: class {
    typealias ComponentViewHandler = (ComponentViewContainer?) -> Void
    typealias FetchedEventsCompletion = (_ fetchedEvents: [Event]?, _ error: String?) -> Void
    typealias AutosuggestCompletion = (_ suggestions: [String], _ responseId: AutosuggestMetadata.ResponseId, _ error: String?) -> Void
    
    init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction?)
    
    var delegate: ConversationManagerDelegate? { get set }
    var events: [Event] { get }
    var currentSRSClassification: String? { get set }
    var isLiveChat: Bool { get }
    var isConnected: Bool { get }
    var hasConversationEnded: Bool { get }
    
    func enterConversation()
    func exitConversation()
    func isConnected(retryConnectionIfNeeded: Bool) -> Bool
    
    func getCurrentQuickReplyMessage() -> ChatMessage?
    func getEvents(before firstEvent: Event, limit: Int, completion: @escaping FetchedEventsCompletion)
    func getEvents(after lastEvent: Event, completion: @escaping FetchedEventsCompletion)
    func getEvents(limit: Int, completion: @escaping FetchedEventsCompletion)
    func getSuggestions(for: String, completion: @escaping AutosuggestCompletion)
    func sendEnterChatRequest(_ completion: (() -> Void)?)
    func sendRequestForAPIAction(_ action: Action?, formData: [String: Any]?, completion: @escaping APIActionResponseHandler)
    func sendRequestForDeepLinkAction(_ action: Action?, with buttonTitle: String)
    func sendRequestForHTTPAction(_ action: Action, formData: [String: Any]?, completion: @escaping HTTPClient.DictCompletionHandler)
    func sendRequestForTreewalkAction(_ action: TreewalkAction, messageText: String?, parentMessage: ChatMessage?, completion: ((Bool) -> Void)?)
    func getComponentView(named name: String, data: [String: Any]?, completion: @escaping ComponentViewHandler)
    func sendUserTypingStatus(isTyping: Bool, with text: String?)
    func sendAskRequest(_ completion: ((_ success: Bool) -> Void)?)
    func sendPictureMessage(_ image: UIImage, completion: (() -> Void)?)
    func sendTextMessage(_ message: String, completion: RequestResponseHandler?)
    func sendSRSQuery(_ query: String, isRequestFromPrediction: Bool, autosuggestMetadata: AutosuggestMetadata?)
    func endLiveChat() -> Bool
}

extension ConversationManagerProtocol {
    func sendEnterChatRequest() {
        return sendEnterChatRequest(nil)
    }
    
    func sendPictureMessage(_ image: UIImage) {
        return sendPictureMessage(image, completion: nil)
    }
    
    func sendTextMessage(_ message: String) {
        return sendTextMessage(message, completion: nil)
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
    
    var hasConversationEnded: Bool {
        guard let lastEvent = events.last else {
            return true
        }
        
        return lastEvent.eventType == .conversationEnd
            || lastEvent.eventType == .accountMerge
            || ((lastEvent.chatMessage?.hasMessageActions == true
                || lastEvent.chatMessage?.hasQuickReplies == true)
                && lastEvent.chatMessage?.userCanTypeResponse != true)
    }
    
    var isConnected: Bool {
        return socketConnection.isConnected
    }
    
    private let simpleStore: ChatSimpleStore
    
    private(set) var events: [Event] = []
    
    private(set) var isLiveChat: Bool = false
    
    private var conversantBeganTypingTime: TimeInterval?
    
    private weak var timer: RepeatingTimer?
    
    // MARK: Private Properties
    
    let socketConnection: SocketConnection
    
    let httpClient: HTTPClientProtocol
    
    // MARK: Initialization
    
    required init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction?) {
        self.config = config
        self.user = user
        self.sessionManager = SessionManager(config: config, user: user)
        self.simpleStore = ChatSimpleStore(config: config, user: user)
        self.socketConnection = SocketConnection(config: config, user: user, userLoginAction: userLoginAction)
        self.httpClient = HTTPClient.shared
        self.httpClient.config(config)
        super.init()
        
        self.socketConnection.delegate = self
        
        self.timer = RepeatingTimer(interval: 6)
        self.timer?.eventHandler = checkForTypingStatusChange
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
}

// MARK: - Entering/Leaving a Conversation

extension ConversationManager {
    
    func enterConversation() {
        DebugLog.d(caller: self, "Entering Conversation")
        
        socketConnection.connectIfNeeded()
    }
    
    func exitConversation() {
        DebugLog.d(caller: self, "Exiting Conversation")
        
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
    func getEvents(before firstEvent: Event, limit: Int, completion: @escaping ConversationManagerProtocol.FetchedEventsCompletion) {
        getEvents(before: firstEvent, after: nil, limit: limit, completion: completion)
    }
    
    func getEvents(after lastEvent: Event, completion: @escaping ConversationManagerProtocol.FetchedEventsCompletion) {
        getEvents(before: nil, after: lastEvent, limit: nil, completion: completion)
    }
    
    func getEvents(limit: Int, completion: @escaping ConversationManagerProtocol.FetchedEventsCompletion) {
        getEvents(before: nil, after: nil, limit: limit, completion: completion)
    }
    
    private func getEvents(before firstEvent: Event?, after lastEvent: Event?, limit: Int?, completion: @escaping ConversationManagerProtocol.FetchedEventsCompletion) {
        let path = "customer/events"
        let shouldInsert = firstEvent != nil
        let shouldAppend = lastEvent != nil
        var params: [String: Int] = [:]
        
        if let limit = limit {
            params["Limit"] = limit
        }
        
        if let firstEvent = firstEvent {
            params["BeforeSeq"] = firstEvent.eventLogSeq
        } else if let lastEvent = lastEvent {
            params["AfterSeq"] = lastEvent.eventLogSeq
        }
        
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
                if let events = parsedEvents.events {
                    strongSelf.isLiveChat = data["IsLiveChat"] as? Bool ?? false
                    
                    if shouldInsert {
                        strongSelf.events.insert(contentsOf: events, at: 0)
                    } else if shouldAppend {
                        strongSelf.events.append(contentsOf: events)
                    } else {
                        strongSelf.events = events
                    }
                }
                
                Dispatcher.performOnMainThread {
                    completion(parsedEvents.events, parsedEvents.errorMessage)
                }
            }
        }
    }
}

// MARK: - Autosuggest

extension ConversationManager {
    func getSuggestions(for text: String, completion: @escaping ConversationManagerProtocol.AutosuggestCompletion) {
        let path = "customer/autocomplete"
        let params = ["Text": text]
        
        httpClient.sendRequest(method: .POST, path: path, params: params) { (data: [String: Any]?, _, error) in
            guard let data = data,
                  error == nil else {
                completion([], "", "Error fetching suggestions.")
                return
            }
            
            let suggestions = data["Suggestions"] as? [String] ?? []
            let responseId = data["ResponseId"] as? String ?? ""
            
            Dispatcher.performOnMainThread {
                completion(suggestions, responseId, nil)
            }
        }
    }
}

// MARK: - Quick Replies

extension ConversationManager {
    func getCurrentQuickReplyMessage() -> ChatMessage? {
        for event in events.reversed().prefix(while: { $0.eventType != .accountMerge })
            where event.isReplyMessageEvent {
            if let chatMessage = event.chatMessage,
               let quickReplies = chatMessage.quickReplies, !quickReplies.isEmpty {
                return chatMessage
            }
            break
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
        
        if event.ephemeralType == .none && event.eventLogSeq < events.last?.eventLogSeq ?? 0 {
            return
        }
        
        if event.ephemeralType == .none && event.eventLogSeq > (events.last?.eventLogSeq ?? (Int.max - 1)) + 1 {
            delegate?.conversationManager(self, didReceiveEventOutOfOrder: event)
            return
        }
    
        if event.ephemeralType == .none {
            events.append(event)
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
        
        delegate?.conversationManager(self, didChangeConnectionStatus: true, authenticationFailed: false)
    }
    
    func socketConnectionFailedToAuthenticate(_ socketConnection: SocketConnection) {
        DebugLog.d("ConversationManager: Authentication Failed")
        
        delegate?.conversationManager(self, didChangeConnectionStatus: false, authenticationFailed: true)
    }
    
    func socketConnectionDidLoseConnection(_ socketConnection: SocketConnection) {
        DebugLog.d("ConversationManager: Connection Lost")
        
        delegate?.conversationManager(self, didChangeConnectionStatus: false, authenticationFailed: false)
    }
}
