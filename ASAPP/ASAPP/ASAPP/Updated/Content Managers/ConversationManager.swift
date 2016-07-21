//
//  ConversationManager.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ConversationManager: NSObject {

    // MARK:- Properties
    
    public var credentials: Credentials
    
    public var messages = [Event]()
    
    public var onMessageReceived: ((message: Event, messages: [Event]) -> Void)?
    
    // MARK:- Initialization
    
    init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        super.init()
        
        
    }
}

// MARK:- Actions

extension ConversationManager {
    func sendMessage(withText text: String, completionHandler: ((error: NSError?) -> Void)?) {
        
        if let onMessageReceived = onMessageReceived {
            
        }
    }
    
    func loadMessages(limit: Int? = 50, sinceMessage: Event? = nil, completionHandler: ((messages: [Event], error: NSError?) -> Void)) {
        
    }
}
