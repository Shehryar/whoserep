//
//  ConversationManager+DemoContent.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/9/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

extension ConversationManager {
    
    // MARK: Sample Responses
    
    func demo_AppOpenResponse() -> AppOpenResponse? {
        guard ASAPP.isDemoContentEnabled() else { return nil }
        
        return AppOpenResponse.sampleResponse(forCompany: config.appId)
    }
}

// MARK:- Sending Fake Data

extension ConversationManager {
    
    func echoMessageResponse(withJSONString jsonString: String?) {
        guard let jsonString = jsonString else { return }
        
        let editedString = jsonString.replacingOccurrences(of: "\n", with: "")
        
        socketConnection.sendRequest(
            withPath: "srs/Echo",
            params: ["Echo": editedString as AnyObject])
    }
    
    // MARK: Generic
    
    func sendDemoMessageEvent(_ event: Event?) {
        guard let message = event?.chatMessage else { return }
        
        Dispatcher.delay(600, closure: {
            self.delegate?.conversationManager(self, didReceive: message)
        })
    }
}
