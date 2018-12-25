//
//  ConversationManagerDelegate.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol ConversationManagerDelegate: class {
    func conversationManager(_ manager: ConversationManagerProtocol, didReceive message: ChatMessage)
    func conversationManager(_ manager: ConversationManagerProtocol, didReceiveEventOutOfOrder event: Event)
    func conversationManager(_ manager: ConversationManagerProtocol, didUpdate message: ChatMessage)
    func conversationManager(_ manager: ConversationManagerProtocol, didChangeLiveChatStatus isLiveChat: Bool, with event: Event?)
    func conversationManager(_ manager: ConversationManagerProtocol, didChangeTypingStatus isTyping: Bool)
    func conversationManager(_ manager: ConversationManagerProtocol, didChangeConnectionStatus result: ConnectionResult)
    func conversationManager(_ manager: ConversationManagerProtocol, didReturnAfterInactivityWith event: Event)
    func conversationManager(_ manager: ConversationManagerProtocol, didReceiveNotificationWith event: Event)
    func conversationManager(_ manager: ConversationManagerProtocol, didReceivePartnerEventWith event: Event)
}

extension ConversationManagerDelegate {
    func conversationManager(_ manager: ConversationManagerProtocol, didChangeLiveChatStatus isLiveChat: Bool) {
        conversationManager(manager, didChangeLiveChatStatus: isLiveChat, with: nil)
    }
}
