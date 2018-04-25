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
    
    func conversationManager(_ manager: ConversationManagerProtocol, didUpdate message: ChatMessage)
    
    func conversationManager(_ manager: ConversationManagerProtocol, didChangeLiveChatStatus isLiveChat: Bool, with event: Event)
    
    func conversationManager(_ manager: ConversationManagerProtocol, didChangeTypingStatus isTyping: Bool)
    
    func conversationManager(_ manager: ConversationManagerProtocol, didChangeConnectionStatus isConnected: Bool, authenticationFailed: Bool)
    
    func conversationManager(_ manager: ConversationManagerProtocol, didReturnAfterInactivityWith: Event)
}
