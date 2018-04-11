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
    private(set) var calledSaveCurrentEvents = false
    private(set) var calledIsConnected = false
    private(set) var calledGetCurrentQuickReplyMessage = false
    private(set) var calledGetEvents = false
    private(set) var calledSendEnterChatRequest = false
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
    private(set) var calledTrackSessionStart = false
    private(set) var calledTrackButtonTap = false
    private(set) var calledTrackAction = false
    private(set) var calledTrackLiveChatBegan = false
    private(set) var calledTrackLiveChatEnded = false
    
    weak var delegate: ConversationManagerDelegate?
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
    
    func saveCurrentEvents(async: Bool) {
        calledSaveCurrentEvents = true
    }
    
    func isConnected(retryConnectionIfNeeded: Bool) -> Bool {
        calledIsConnected = true
        return isConnected
    }
    
    func getCurrentQuickReplyMessage() -> ChatMessage? {
        calledGetCurrentQuickReplyMessage = true
        return nextQuickReplyMessage
    }
    
    func getEvents(afterEvent: Event?, completion: @escaping ConversationManagerProtocol.FetchedEventsCompletion) {
        calledGetEvents = true
    }
    
    func sendEnterChatRequest(_ completion: (() -> Void)?) {
        calledSendEnterChatRequest = true
    }
    
    func sendRequestForAPIAction(_ action: Action?, formData: [String: Any]?, completion: @escaping APIActionResponseHandler) {
        calledSendRequestForAPIAction = true
    }
    
    func sendRequestForDeepLinkAction(_ action: Action?, with buttonTitle: String, completion: IncomingMessageHandler?) {
        calledSendRequestForDeepLinkAction = true
    }
    
    func sendRequestForHTTPAction(_ action: Action, formData: [String: Any]?, completion: @escaping HTTPClient.CompletionHandler) {
        calledSendRequestForHTTPAction = true
    }
    
    func sendRequestForTreewalkAction(_ action: TreewalkAction, messageText: String?, parentMessage: ChatMessage?, completion: ((Bool) -> Void)?) {
        calledSendRequestForTreewalkAction = true
    }
    
    func getComponentView(named name: String, data: [String: Any]?, completion: @escaping ConversationManagerProtocol.ComponentViewHandler) {
        calledGetComponentView = true
    }
    
    func sendUserTypingStatus(isTyping: Bool, withText text: String?) {
        calledSendUserTypingStatus = true
    }
    
    func sendAskRequest(_ completion: ((Bool) -> Void)?) {
        calledSendAskRequest = true
    }
    
    func sendPictureMessage(_ image: UIImage, completion: (() -> Void)?) {
        calledSendPictureMessage = true
    }
    
    func sendTextMessage(_ message: String, completion: IncomingMessageHandler?) {
        calledSendTextMessage = true
    }
    
    func sendSRSQuery(_ query: String, isRequestFromPrediction: Bool) {
        calledSendSRSQuery = true
    }
    
    func endLiveChat() -> Bool {
        calledEndLiveChat = true
        return true
    }
    
    func trackSessionStart() {
        calledTrackSessionStart = true
    }
    
    func trackButtonTap(buttonName: AnalyticsButtonName) {
        calledTrackButtonTap = true
    }
    
    func trackAction(_ action: Action) {
        calledTrackAction = true
    }
    
    func trackLiveChatBegan(issueId: Int) {
        calledTrackLiveChatBegan = true
    }
    
    func trackLiveChatEnded(issueId: Int) {
        calledTrackLiveChatEnded = true
    }
    
    func cleanCalls() {
        calledEnterConversation = false
        calledExitConversation = false
        calledSaveCurrentEvents = false
        calledIsConnected = false
        calledGetCurrentQuickReplyMessage = false
        calledGetEvents = false
        calledSendEnterChatRequest = false
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
        calledTrackSessionStart = false
        calledTrackButtonTap = false
        calledTrackAction = false
        calledTrackLiveChatBegan = false
        calledTrackLiveChatEnded = false
    }
    
    func clean() {
        cleanCalls()
    }
}
