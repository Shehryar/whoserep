//
//  MockConversationManager.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 3/7/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

@testable import ASAPP

class MockConversationManager: ConversationManagerProtocol {
    private(set) var calledEnterConversation = false
    private(set) var calledExitConversation = false
    private(set) var calledIsConnected = false
    private(set) var calledGetCurrentQuickReplyMessage = false
    private(set) var calledGetEventsBefore = false
    private(set) var calledGetEventsAfter = false
    private(set) var calledGetEventWithLimit = false
    private(set) var calledGetSuggestions = false
    private(set) var calledGetSettings = false
    private(set) var calledSendEnterChatRequest = false
    private(set) var calledSendAcceptRequest = false
    private(set) var calledSendDismissRequest = false
    private(set) var calledSendRequestForAPIAction = false
    private(set) var calledSendRequestForDeepLinkAction = false
    private(set) var calledSendRequestForHTTPAction = false
    private(set) var calledSendRequestForTreewalkAction = false
    private(set) var calledGetComponentView = false
    private(set) var calledSendUserTypingStatus = false
    private(set) var calledSendAskRequest = false
    private(set) var calledSendPictureMessage = false
    private(set) var calledSendTextMessage = false
    private(set) var calledSendSRSQuery = false
    private(set) var calledEndLiveChat = false
    
    weak var delegate: ConversationManagerDelegate?
    var pushNotificationPayload: [AnyHashable: Any]?
    var events: [Event]
    var currentSRSClassification: String?
    var isLiveChat: Bool
    var isConnected: Bool
    
    var nextQuickReplyMessage: ChatMessage?
    
    required init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction?) {
        events = []
        isLiveChat = false
        isConnected = false
    }
    
    func enterConversation() {
        calledEnterConversation = true
    }
    
    func exitConversation() {
        calledExitConversation = true
    }
    
    func isConnected(retryConnectionIfNeeded: Bool) -> Bool {
        calledIsConnected = true
        return isConnected
    }
    
    func getCurrentQuickReplyMessage() -> ChatMessage? {
        calledGetCurrentQuickReplyMessage = true
        return nextQuickReplyMessage
    }
    
    func getEvents(before firstEvent: Event, limit: Int, completion: @escaping ConversationManagerProtocol.FetchedEventsCompletion) {
        calledGetEventsBefore = true
    }
    
    func getEvents(after lastEvent: Event, completion: @escaping ConversationManagerProtocol.FetchedEventsCompletion) {
        calledGetEventsAfter = true
    }
    
    func getEvents(limit: Int, completion: @escaping ConversationManagerProtocol.FetchedEventsCompletion) {
        calledGetEventWithLimit = true
    }
    
    func getSuggestions(for: String, completion: @escaping ConversationManagerProtocol.AutosuggestCompletion) {
        calledGetSuggestions = true
    }
    
    func getSettings(attempts: Int = 0, completion: @escaping (() -> Void)) {
        calledGetSettings = true
    }
    
    func sendEnterChatRequest(_ completion: (() -> Void)?) {
        calledSendEnterChatRequest = true
    }
    
    func sendAcceptRequest(action: Action) {
        calledSendAcceptRequest = true
    }
    
    func sendDismissRequest(action: Action) {
        calledSendDismissRequest = true
    }
    
    func sendRequestForAPIAction(_ action: Action?, formData: [String: Any]?, completion: @escaping APIActionResponseHandler) {
        calledSendRequestForAPIAction = true
    }
    
    func sendRequestForDeepLinkAction(_ action: Action?, with buttonTitle: String) {
        calledSendRequestForDeepLinkAction = true
    }
    
    func sendRequestForHTTPAction(_ action: Action, formData: [String: Any]?, completion: @escaping HTTPClient.DictCompletionHandler) {
        calledSendRequestForHTTPAction = true
    }
    
    func sendRequestForTreewalkAction(_ action: TreewalkAction, messageText: String?, parentMessage: ChatMessage?, completion: ((Bool) -> Void)?) {
        calledSendRequestForTreewalkAction = true
    }
    
    func getComponentView(named name: String, data: [String: Any]?, completion: @escaping ConversationManagerProtocol.ComponentViewHandler) {
        calledGetComponentView = true
    }
    
    func sendUserTypingStatus(isTyping: Bool, with text: String?) {
        calledSendUserTypingStatus = true
    }
    
    func sendAskRequest(_ completion: ((Bool) -> Void)?) {
        calledSendAskRequest = true
    }
    
    func sendPictureMessage(_ image: UIImage, completion: (() -> Void)?) {
        calledSendPictureMessage = true
    }
    
    func sendTextMessage(_ message: String, completion: RequestResponseHandler?) {
        calledSendTextMessage = true
    }
    
    func sendSRSQuery(_ query: String, isRequestFromPrediction: Bool, autosuggestMetadata: AutosuggestMetadata?) {
        calledSendSRSQuery = true
    }
    
    func endLiveChat() -> Bool {
        calledEndLiveChat = true
        return true
    }
    
    func cleanCalls() {
        calledEnterConversation = false
        calledExitConversation = false
        calledIsConnected = false
        calledGetCurrentQuickReplyMessage = false
        calledGetEventsBefore = false
        calledGetEventsAfter = false
        calledGetEventWithLimit = false
        calledGetSuggestions = false
        calledGetSettings = false
        calledSendEnterChatRequest = false
        calledSendAcceptRequest = false
        calledSendDismissRequest = false
        calledSendRequestForAPIAction = false
        calledSendRequestForDeepLinkAction = false
        calledSendRequestForHTTPAction = false
        calledSendRequestForTreewalkAction = false
        calledGetComponentView = false
        calledSendUserTypingStatus = false
        calledSendAskRequest = false
        calledSendPictureMessage = false
        calledSendTextMessage = false
        calledSendSRSQuery = false
        calledEndLiveChat = false
    }
    
    func clean() {
        cleanCalls()
    }
}
