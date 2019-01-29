//
//  ConversationManager.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

enum ConnectionResult: Equatable {
    case lost
    case failed
    case couldNotAuthenticate(authError: AuthError)
    case success
}

func == (lhs: ConnectionResult, rhs: ConnectionResult) -> Bool {
    switch lhs {
    case .lost:
        if case .lost = rhs { return true }
    case .failed:
        if case .failed = rhs { return true }
    case .couldNotAuthenticate(let lhsAuthError):
        if case .couldNotAuthenticate(let rhsAuthError) = rhs {
            return lhsAuthError == rhsAuthError
        }
    case .success:
        if case .success = rhs { return true }
    }
    
    return false
}

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
    
    init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction?, httpClient: HTTPClientProtocol, secureStorage: SecureStorageProtocol, socketConnection: SocketConnectionProtocol?)
    
    var delegate: ConversationManagerDelegate? { get set }
    var events: [Event] { get }
    var isConnected: Bool { get }
    var pushNotificationPayload: [AnyHashable: Any]? { get set }
    var intentPayload: [String: Any]? { get set }
    
    func enterConversation(shouldRetry: Bool)
    func exitConversation()
    func isConnected(retryConnectionIfNeeded: Bool) -> Bool
    
    func getCurrentQuickReplyMessage() -> ChatMessage?
    func getRequestParameters(with params: [String: Any]?, requiresContext: Bool, contextKey: String, contextNeedsRefresh: Bool, completion: @escaping (_ params: [String: Any]) -> Void)
    
    func getEvents(before firstEvent: Event, limit: Int, completion: @escaping FetchedEventsCompletion)
    func getEvents(after lastEvent: Event, completion: @escaping FetchedEventsCompletion)
    func getEvents(limit: Int, completion: @escaping FetchedEventsCompletion)
    func getSuggestions(for: String, completion: @escaping AutosuggestCompletion)
    func getSettings(attempts: Int, completion: @escaping (() -> Void))
    
    func resolve(linkAction: LinkAction, completion: @escaping ((Action?) -> Void))
    func sendEnterChatRequest(_ completion: (() -> Void)?)
    func sendAcceptRequest(action: Action)
    func sendDismissRequest(action: Action)
    func sendRequestForAPIAction(_ action: Action?, formData: [String: Any]?, completion: @escaping APIActionResponseHandler)
    func sendRequestForDeepLinkAction(_ action: Action?, with buttonTitle: String)
    func sendRequestForHTTPAction(_ action: Action, formData: [String: Any]?, completion: @escaping HTTPClientProtocol.DictCompletionHandler)
    func sendRequestForTreewalkAction(_ action: TreewalkAction, messageText: String?, parentMessage: ChatMessage?, completion: ((Bool) -> Void)?)
    func getComponentView(named name: String, data: [String: Any]?, completion: @escaping ComponentViewHandler)
    func sendUserTypingStatus(isTyping: Bool, with text: String?)
    func sendAskRequest(intent: [String: Any]?, _ completion: ((_ success: Bool) -> Void)?)
    func sendPictureMessage(_ image: UIImage, completion: ((Error?) -> Void)?)
    func sendTextMessage(_ message: String, completion: RequestResponseHandler?)
    func sendSRSQuery(_ query: String, isRequestFromPrediction: Bool, autosuggestMetadata: AutosuggestMetadata?)
    func endLiveChat() -> Bool
}

extension ConversationManagerProtocol {
    init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction?) {
        self.init(config: config, user: user, userLoginAction: userLoginAction, httpClient: HTTPClient.shared, secureStorage: SecureStorage.default, socketConnection: nil)
    }
    
    func sendEnterChatRequest() {
        return sendEnterChatRequest(nil)
    }
    
    func sendPictureMessage(_ image: UIImage, completion: ((Error?) -> Void)?) {
        return sendPictureMessage(image, completion: completion)
    }
    
    func sendTextMessage(_ message: String) {
        return sendTextMessage(message, completion: nil)
    }
    
    func getSettings() {
        return getSettings(attempts: 0, completion: {})
    }
    
    func getSettings(completion: @escaping (() -> Void)) {
        return getSettings(attempts: 0, completion: completion)
    }
    
    func getSettings(attempts: Int) {
        return getSettings(attempts: attempts, completion: {})
    }
    
    func getRequestParameters(completion: @escaping (_ params: [String: Any]) -> Void) {
        return getRequestParameters(
            with: nil,
            requiresContext: true,
            contextKey: "Context",
            contextNeedsRefresh: false,
            completion: completion)
    }
    
    func sendAskRequest(intent: [String: Any]? = nil, _ completion: ((_ success: Bool) -> Void)?) {
        return sendAskRequest(intent: intent, completion)
    }
}

class ConversationManager: NSObject, ConversationManagerProtocol {
    weak var delegate: ConversationManagerDelegate?
    
    var isConnected: Bool {
        return socketConnection.isConnected
    }
    
    var pushNotificationPayload: [AnyHashable: Any]?
    var intentPayload: [String: Any]?
    
    private let secureStorage: SecureStorageProtocol
    private var censor: CensorProtocol?
    private let socketConnection: SocketConnectionProtocol
    private let httpClient: HTTPClientProtocol
    private let config: ASAPPConfig
    private let user: ASAPPUser
    private(set) var events: [Event] = []
    
    // MARK: Initialization
    
    required init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction?, httpClient: HTTPClientProtocol = HTTPClient.shared, secureStorage: SecureStorageProtocol = SecureStorage.default, socketConnection: SocketConnectionProtocol? = nil) {
        self.config = config
        self.user = user
        self.secureStorage = secureStorage
        self.socketConnection = socketConnection ?? SocketConnection(config: config, user: user, userLoginAction: userLoginAction)
        self.httpClient = httpClient
        self.httpClient.config(config)
        super.init()
        
        self.socketConnection.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationManager.reEnterConversation), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

// MARK: - Utility

extension ConversationManager {
    
    func isConnected(retryConnectionIfNeeded: Bool = false) -> Bool {
        if !isConnected && retryConnectionIfNeeded {
            socketConnection.connect(shouldRetry: false)
        }
        
        return isConnected
    }
}

// MARK: - Entering/Leaving a Conversation

extension ConversationManager {
    
    @objc func reEnterConversation() {
        enterConversation(shouldRetry: true)
    }
    
    func enterConversation(shouldRetry: Bool) {
        DebugLog.d(caller: self, "Entering Conversation")
        
        httpClient.authenticate(as: user, contextNeedsRefresh: false) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success:
                strongSelf.socketConnection.connect(shouldRetry: shouldRetry)
            case .failure(let authError):
                Dispatcher.performOnMainThread {
                    strongSelf.delegate?.conversationManager(strongSelf, didChangeConnectionStatus: .couldNotAuthenticate(authError: authError))
                }
            }
            
        }
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
    
    private func detectIsLiveChat(flag: Bool, events: IncomingMessage.Events) -> Bool? {
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
        
        return nil
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
                var isLiveChat: Bool?
                if let events = parsedEvents.events {
                    if firstEvent == nil {
                        isLiveChat = strongSelf.detectIsLiveChat(flag: data["IsLiveChat"] as? Bool ?? false, events: events)
                    }
                    
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
                    
                    if let isLiveChat = isLiveChat {
                        Dispatcher.delay {
                            strongSelf.delegate?.conversationManager(strongSelf, didChangeLiveChatStatus: isLiveChat)
                        }
                    }
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
    func getSettings(attempts: Int = 0, completion: @escaping (() -> Void) = {}) {
        let path = "customer/getsdksettings"
        
        httpClient.sendRequest(method: .POST, path: path) { [weak self] (responseData: Data?, _, error) in
            guard let strongSelf = self else {
                return
            }
            
            let settingsKey = strongSelf.config.settingsHashKey(suffix: "SDKSettings")
            var responseData = responseData
            
            if let responseData = responseData,
               error == nil {
                try? strongSelf.secureStorage.store(data: responseData, as: settingsKey)
            }
            
            if responseData == nil || error != nil {
                if attempts < 2 {
                    DebugLog.w(caller: strongSelf, "Could not fetch SDK settings. Retrying...")
                    strongSelf.getSettings(attempts: attempts + 1, completion: completion)
                    return
                }
                
                DebugLog.e(caller: strongSelf, "Failed to fetch SDK settings")
                
                responseData = try? strongSelf.secureStorage.retrieve(settingsKey)
            }
            
            guard let data = responseData else {
                DebugLog.e(caller: strongSelf, "Failed to retrieve persisted SDK settings")
                return
            }
            
            let decoder = JSONDecoder()
            guard let settings = try? decoder.decode(Settings.self, from: data) else {
                return
            }
            
            let censor = Censor()
            censor.rules = settings.redactionRules
            strongSelf.censor = censor
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
                "Text": query
            ]
            
            if let data = try? JSONEncoder().encode(autosuggestMetadata),
                let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                params["CustAutoCompleteAnalytics"] = dict
            }
            
            self?.sendRequest(path: path, params: params)
        }
    }
    
    func sendPictureMessage(_ image: UIImage, completion: ((Error?) -> Void)? = nil) {
        let path = "customer/SendPictureMessage"
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            DebugLog.e("Unable to get JPEG data for image: \(image)")
            return
        }
        let imageFileSize = imageData.count
        let params: [String: Any] = [
            "MimeType": "image/jpeg",
            "FileSize": imageFileSize,
            "PicWidth": image.size.width,
            "PicHeight": image.size.height
        ]
        
        httpClient.sendRequest(method: .POST, path: path, headers: nil, params: params, data: imageData) { (_: Data?, _, error) in
            if let error = error {
                completion?(error)
            } else {
                completion?(nil)
            }
            
        }
    }
}

// MARK: - SocketConnectionDelegate

extension ConversationManager: SocketConnectionDelegate {
    private func isDuplicate(_ event: Event) -> Bool {
        return event.eventLogSeq <= events.last?.eventLogSeq ?? 0
    }
    
    private func isOutOfOrder(_ event: Event) -> Bool {
        return event.eventLogSeq > (events.last?.eventLogSeq ?? (Int.max - 1)) + 1
    }
    
    func socketConnection(_ socketConnection: SocketConnection, didReceiveMessage message: IncomingMessage) {
        guard message.type == .event,
              let body = message.body,
              let event = Event.fromJSON(body) else {
            return
        }
        
        if event.ephemeralType == .none && isDuplicate(event) {
            return
        }
        
        if event.ephemeralType == .none && isOutOfOrder(event) {
            delegate?.conversationManager(self, didReceiveEventOutOfOrder: event)
            return
        }
    
        if event.ephemeralType == .none {
            events.append(event)
        }
        
        // Entering / Exiting Live Chat
        if let liveChatStatus = EventType.getLiveChatStatus(for: event.eventType) {
            delegate?.conversationManager(self, didChangeLiveChatStatus: liveChatStatus, with: event)
        }
        
        // Partner Event aka "Chat Event"
        if event.ephemeralType == .partnerEvent {
            delegate?.conversationManager(self, didReceivePartnerEventWith: event)
            return
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
            delegate?.conversationManager(self, didReceive: message)
        }
    }
    
    func socketConnectionEstablishedConnection(_ socketConnection: SocketConnection) {
        DebugLog.d("ConversationManager: established connection")
        
        Dispatcher.performOnMainThread { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.conversationManager(strongSelf, didChangeConnectionStatus: .success)
        }
    }
    
    func socketConnectionFailedToConnect(_ socketConnection: SocketConnection) {
        DebugLog.d("ConversationManager: failed to connect to web socket")
        
        Dispatcher.performOnMainThread { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.conversationManager(strongSelf, didChangeConnectionStatus: .failed)
        }
    }
    
    func socketConnectionDidLoseConnection(_ socketConnection: SocketConnection) {
        DebugLog.d("ConversationManager: connection lost")
        
        Dispatcher.performOnMainThread { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.socketConnection.connect(shouldRetry: true)
            strongSelf.delegate?.conversationManager(strongSelf, didChangeConnectionStatus: .lost)
        }
    }
}
