//
//  EventMetadata.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class EventMetadata: NSObject {
    
    let isReply: Bool
    let isAutomatedMessage: Bool
    let eventId: Int
    let eventType: EventType
    let issueId: Int
    let classification: String? = nil
    
    private(set) var sendTime: Date
    private(set) var sendTimeString: String
    
    // MARK: - Init
    
    init(isReply: Bool,
         isAutomatedMessage: Bool,
         eventId: Int,
         eventType: EventType,
         issueId: Int,
         sendTime: Date) {
        self.isReply = isReply
        self.isAutomatedMessage = isAutomatedMessage
        self.eventId = eventId
        self.eventType = eventType
        self.issueId = issueId
        self.sendTime = sendTime
        self.sendTimeString = self.sendTime.formattedStringMostRecent()
        super.init()
    }
    
    // MARK: - Updates
    
    func updateSendTime(to date: Date) {
        self.sendTime = date
        self.sendTimeString = date.formattedStringMostRecent()
    }
    
    func updateSendTime(toMatchMessage message: ChatMessage) {
        updateSendTime(to: message.metadata.sendTime)
    }
}
