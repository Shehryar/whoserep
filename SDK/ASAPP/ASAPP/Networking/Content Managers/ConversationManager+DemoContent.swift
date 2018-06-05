//
//  ConversationManager+DemoContent.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/9/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

// MARK: - Sending Fake Data

extension ConversationManager {
    
    func echoMessageResponse(withJSONString jsonString: String?) {
        guard let jsonString = jsonString else { return }
        
        let editedString = jsonString.replacingOccurrences(of: "\n", with: "")
        
        sendRequest(path: "srs/Echo", params: ["Echo": editedString])
    }
    
    // MARK: Generic
    
    func sendDemoMessageEvent(_ event: Event?) {
        guard let message = event?.chatMessage else { return }
        
        Dispatcher.delay(.defaultAnimationDuration * 2, closure: {
            self.delegate?.conversationManager(self, didReceive: message)
        })
    }
}
