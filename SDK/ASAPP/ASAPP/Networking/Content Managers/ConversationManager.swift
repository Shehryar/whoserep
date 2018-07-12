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
    var pushNotificationPayload: [AnyHashable: Any]? { get set }
    
    func enterConversation()
    func exitConversation()
    func isConnected(retryConnectionIfNeeded: Bool) -> Bool
    
    func getCurrentQuickReplyMessage() -> ChatMessage?
    func getEvents(before firstEvent: Event, limit: Int, completion: @escaping FetchedEventsCompletion)
    func getEvents(after lastEvent: Event, completion: @escaping FetchedEventsCompletion)
    func getEvents(limit: Int, completion: @escaping FetchedEventsCompletion)
    func getSuggestions(for: String, completion: @escaping AutosuggestCompletion)
    func getSettings(completion: @escaping (() -> Void))
    func sendEnterChatRequest(_ completion: (() -> Void)?)
    func sendAcceptRequest(action: Action)
    func sendDismissRequest(action: Action)
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
    
    func getSettings() {
        return getSettings(completion: {})
    }
}

class ConversationManager: NSObject, ConversationManagerProtocol {
    let config: ASAPPConfig
    
    let user: ASAPPUser
    
    let sessionManager: SessionManager
    
    var pushNotificationPayload: [AnyHashable: Any]?
    
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
    
    private(set) var events: [Event] = []
    
    private var censor: CensorProtocol?
    
    private(set) var isLiveChat: Bool = false
    
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
                              contextKey: String = "Context",
                              contextNeedsRefresh: Bool = false,
                              completion: @escaping (_ params: [String: Any]) -> Void) {
        
        var requestParams: [String: Any] = [
            ASAPP.clientTypeKey: ASAPP.clientType,
            ASAPP.clientVersionKey: ASAPP.clientVersion,
            ASAPP.partnerAppVersionKey: ASAPP.partnerAppVersion
        ].with(params)
        
        if requiresContext {
            user.getContext(needsRefresh: contextNeedsRefresh, completion: { [weak self] (context, authToken) in
                if let context = context {
                    var updatedContext = context
                    if let strongSelf = self, !strongSelf.user.isAnonymous {
                        updatedContext[strongSelf.config.identifierType] = strongSelf.user.userIdentifier
                    }
                    
                    if let contextString = JSONUtil.stringify(updatedContext) {
                        requestParams[contextKey] = contextString
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
                     contextNeedsRefresh: Bool = false,
                     completion: RequestResponseHandler? = nil) {
                
        getRequestParameters(with: params, requiresContext: requiresContext, contextNeedsRefresh: contextNeedsRefresh) { [httpClient] requestParams in
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
    
    private func detectIsLiveChat(flag: Bool, events: IncomingMessage.Events) -> Bool {
        if flag {
            return true
        }
        
        for event in events.reversed() {
            if event.isLiveChatEvent {
                return true
            }
            
            if event.isSRSEvent {
                return false
            }
        }
        
        return false
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
                    strongSelf.isLiveChat = strongSelf.detectIsLiveChat(flag: data["IsLiveChat"] as? Bool ?? false, events: events)
                    
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
        var text = text
        
        Dispatcher.performOnBackgroundThread { [weak self] in
            if let censor = self?.censor {
                text = censor.process(text, type: .fragment)
            }
            let params = ["Text": text]
            
            self?.httpClient.sendRequest(method: .POST, path: path, params: params) { (data: [String: Any]?, _, error) in
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
}

// MARK: - Settings

extension ConversationManager {
    func getSettings(completion: @escaping (() -> Void) = {}) {
        let path = "customer/getsdksettings"
        
        httpClient.sendRequest(method: .POST, path: path) { [weak self] (data: Data?, _, error) in
            guard let data = data,
                  error == nil else {
                DebugLog.e(caller: self, "Could not fetch SDK settings")
                return
            }
            
            let decoder = JSONDecoder()
            guard let settings = try? decoder.decode(Settings.self, from: data) else {
                return
            }
            
            let censor = Censor()
            censor.rules = settings.redactionRules
            self?.censor = censor
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

// MARK: - Chat

extension ConversationManager {
    func sendUserTypingStatus(isTyping: Bool, with text: String?) {
        let path = "customer/NotifyTypingPreview"
        var text = text ?? ""
        Dispatcher.performOnBackgroundThread { [weak self] in
            if let censor = self?.censor {
                text = censor.process(text, type: .fragment)
            }
            let params = [ "Text": text]
            self?.sendRequest(path: path, params: params, requiresContext: false, completion: nil)
        }
    }
    
    func sendTextMessage(_ message: String, completion: RequestResponseHandler? = nil) {
        let path = "customer/SendTextMessage"
        var message = message
        Dispatcher.performOnBackgroundThread { [weak self] in
            if let censor = self?.censor {
                message = censor.process(message)
            }
            let params = ["Text": message]
            self?.sendRequest(path: path, params: params, completion: completion)
        }
    }
    
    func sendSRSQuery(_ query: String, isRequestFromPrediction: Bool = false, autosuggestMetadata: AutosuggestMetadata?) {
        if ASAPP.isDemoContentEnabled(), let demoResponse = Event.demoResponseForQuery(query) {
            echoMessageResponse(withJSONString: demoResponse)
            return
        }
        
        let path = "srs/SendTextMessageAndHierAndTreewalk"
        var query = query
        
        Dispatcher.performOnBackgroundThread { [weak self] in
            if let censor = self?.censor {
                query = censor.process(query)
            }
            var params: [String: Any] = [
                "Text": query,
                "SearchQuery": query
            ]
            
            if let data = try? JSONEncoder().encode(autosuggestMetadata),
                let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                params["CustAutoCompleteAnalytics"] = dict
            }
            
            self?.sendRequest(path: path, params: params)
        }
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
        
        // Auth Expired
        if event.ephemeralType == .contextNeedsRefresh {
            sendRequest(path: "customer/updateContext", contextNeedsRefresh: true)
            return
        }
        
        // Typing Status
        if event.ephemeralType == .typingStatus {
            if let typingStatus = event.typingStatus {
                delegate?.conversationManager(self, didChangeTypingStatus: typingStatus)
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
        
        // Notification Banner Event
        if event.ephemeralType == .notificationBanner {
            delegate?.conversationManager(self, didReceiveNotificationWith: event)
        }
        
        // Message Event
        if let message = event.chatMessage {
            if message.metadata.isAutomatedMessage {
                Dispatcher.delay(.defaultAnimationDuration * 2, closure: { [weak self] in
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
