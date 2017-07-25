//
//  ConversationManagerDelegate.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol ConversationManagerDelegate: class {
    
    func conversationManager(_ manager: ConversationManager, didReceive message: ChatMessage)
    
    func conversationManager(_ manager: ConversationManager, didUpdate message: ChatMessage)
    
    func conversationManager(_ manager: ConversationManager, didChangeLiveChatStatus isLiveChat: Bool, with event: Event)
    
    func conversationManager(_ manager: ConversationManager, didChangeTypingStatus isTyping: Bool)
    
    func conversationManager(_ manager: ConversationManager, didChangeConnectionStatus isConnected: Bool)
}

