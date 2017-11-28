//
//  Event.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/20/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class Event: NSObject {
    
    // Server-set
    
    let eventLogSeq: Int
    let parentEventLogSeq: Int?
    let eventType: EventType
    let ephemeralType: EphemeralEventType
    let eventTime: Double // In Seconds
    let issueId: Int
    let companyId: Int
    let customerId: Int
    let repId: Int
    let eventFlags: Int
    private let eventJSON: [String: Any]?
    
    // Client-Set
    
    let uniqueIdentifier: String
    let isCustomerEvent: Bool
    let isReply: Bool
    let eventDate: Date
    let sendTimeString: String?
    let isAutomatedMessage: Bool
    
    // Body Content
    
    var chatMessage: ChatMessage?
    var typingStatus: Bool?
    var switchToSRSClassification: String?
    
    // MARK: - Init
    
    required init(eventId: Int,
                  parentEventLogSeq: Int?,
                  eventType: EventType,
                  ephemeralType: EphemeralEventType,
                  eventTime: Double,
                  issueId: Int,
                  companyId: Int,
                  customerId: Int,
                  repId: Int,
                  eventFlags: Int,
                  eventJSON: [String: Any]?) {
        
        self.eventLogSeq = eventId
        self.parentEventLogSeq = parentEventLogSeq
        self.eventType = eventType
        self.ephemeralType = ephemeralType
        self.eventTime = eventTime
        self.issueId = issueId
        self.companyId = companyId
        self.customerId = customerId
        self.repId = repId
        self.eventFlags = eventFlags
        self.eventJSON = eventJSON
        
        self.uniqueIdentifier = UUID().uuidString
        self.isCustomerEvent = eventFlags == 1
        self.isReply = !self.isCustomerEvent || eventType == .conversationEnd
        self.eventDate = Date(timeIntervalSince1970: eventTime)
        self.sendTimeString = self.eventDate.formattedStringMostRecent()
        self.isAutomatedMessage = eventType == .srsResponse
        
        super.init()
    }
    
    // MARK: - Metadata
    
    func makeMetadata() -> EventMetadata {
        let eventId: Int
        if ephemeralType == .eventStatus, let parentId = parentEventLogSeq {
            eventId = parentId
        } else {
            eventId = eventLogSeq
        }
        
        return EventMetadata(isReply: isReply,
                             isAutomatedMessage: isAutomatedMessage,
                             eventId: eventId,
                             eventType: eventType,
                             issueId: issueId,
                             sendTime: eventDate)
    }
}
