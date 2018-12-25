//
//  MockConversationManagerDelegate.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 10/30/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

@testable import ASAPP

class MockConversationManagerDelegate: ConversationManagerDelegate {
    private(set) var calledDidReceive = false
    private(set) var calledDidReceiveEventOutOfOrder = false
    private(set) var calledDidUpdate = false
    private(set) var calledDidChangeLiveChatStatus = false
    private(set) var calledDidChangeTypingStatus = false
    private(set) var calledDidChangeConnectionStatus = false
    private(set) var calledDidReturnAfterInactivityWith = false
    private(set) var calledDidReceiveNotificationWith = false
    private(set) var calledDidReceivePartnerEventWith = false
    
    private(set) var lastConnectionStatus: ConnectionResult?
    private(set) var lastEventReceived: Event?
    private(set) var lastTypingStatus: Bool?
    private(set) var lastMessageReceived: ChatMessage?
    
    func conversationManager(_ manager: ConversationManagerProtocol, didReceive message: ChatMessage) {
        calledDidReceive = true
        lastMessageReceived = message
    }
    
    func conversationManager(_ manager: ConversationManagerProtocol, didReceiveEventOutOfOrder event: Event) {
        calledDidReceiveEventOutOfOrder = true
        lastEventReceived = event
    }
    
    func conversationManager(_ manager: ConversationManagerProtocol, didUpdate message: ChatMessage) {
        calledDidUpdate = true
        lastMessageReceived = message
    }
    
    func conversationManager(_ manager: ConversationManagerProtocol, didChangeLiveChatStatus isLiveChat: Bool, with event: Event?) {
        calledDidChangeLiveChatStatus = true
        lastEventReceived = event
    }
    
    func conversationManager(_ manager: ConversationManagerProtocol, didChangeTypingStatus isTyping: Bool) {
        calledDidChangeTypingStatus = true
    }
    
    func conversationManager(_ manager: ConversationManagerProtocol, didChangeConnectionStatus result: ConnectionResult) {
        calledDidChangeConnectionStatus = true
        lastConnectionStatus = result
    }
    
    func conversationManager(_ manager: ConversationManagerProtocol, didReturnAfterInactivityWith event: Event) {
        calledDidReturnAfterInactivityWith = true
        lastEventReceived = event
    }
    
    func conversationManager(_ manager: ConversationManagerProtocol, didReceiveNotificationWith event: Event) {
        calledDidReceiveNotificationWith = true
        lastEventReceived = event
    }
    
    func conversationManager(_ manager: ConversationManagerProtocol, didReceivePartnerEventWith event: Event) {
        calledDidReceivePartnerEventWith = true
        lastEventReceived = event
    }
    
    func cleanCalls() {
        calledDidReceive = false
        calledDidReceiveEventOutOfOrder = false
        calledDidUpdate = false
        calledDidChangeLiveChatStatus = false
        calledDidChangeTypingStatus = false
        calledDidChangeConnectionStatus = false
        calledDidReturnAfterInactivityWith = false
        calledDidReceiveNotificationWith = false
        calledDidReceivePartnerEventWith = false
    }
    
    func clean() {
        cleanCalls()
        lastConnectionStatus = nil
        lastEventReceived = nil
    }
}
