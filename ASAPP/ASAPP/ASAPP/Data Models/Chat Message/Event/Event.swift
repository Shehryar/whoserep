//
//  Event.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/20/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

enum EventType: Int {
    case none = 0
    case textMessage = 1
    case newRep = 3
    case conversationEnd = 4
    case pictureMessage = 5
    case srsResponse = 22
    case srsEcho = 23
    case srsAction = 24
    case scheduleAppointment = 27
    case switchSRSToChat = 28
    
    static func typeMayContainSRSContent(_ type: EventType) -> Bool {
        switch type {
        case srsResponse,
             srsEcho,
             srsAction,
             newRep,
             conversationEnd,
             switchSRSToChat:
            return true
            
        default:
            return false
        }
    }
}

enum EphemeralType: Int {
    case none = 0
    case typingStatus = 1
    case eventStatus = 6
}

// MARK:- Event

class Event: NSObject {
    
    let eventLogSeq: Int
    let parentEventLogSeq: Int?
    let eventType: EventType
    let ephemeralType: EphemeralType
    let eventTime: Double // In Seconds
    let issueId: Int
    let companyId: Int
    let customerId: Int
    let repId: Int
    let eventFlags: Int
    let eventJSON: [String : AnyObject]?
    
    // Internally Set
    
    let uniqueIdentifier: String
    let isCustomerEvent: Bool
    let isReply: Bool
    let eventDate: Date
    let sendTimeString: String?
    
    // Body Content
    
    var typingStatus: EventTypingStatus?
    var textMessage: EventTextMessage?
    var pictureMessage: EventPictureMessage?
    var srsResponse: EventSRSResponse?
    var chatMessage: ChatMessage?
    
    var messageText: String? {
        switch eventType {
        case .textMessage: return textMessage?.text
        case .pictureMessage: return nil
            
        default: return srsResponse?.messageText
        }
    }
    
    // MARK:- Init
    
    required init(eventId: Int,
                  parentEventLogSeq: Int?,
                  eventType: EventType,
                  ephemeralType: EphemeralType,
                  eventTime: Double,
                  issueId: Int,
                  companyId: Int,
                  customerId: Int,
                  repId: Int,
                  eventFlags: Int,
                  eventJSON: [String : AnyObject]?) {
        
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
        self.isReply = !self.isCustomerEvent
        self.eventDate = Date(timeIntervalSince1970: eventTime)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.eventDate.dateFormatForMostRecent()
        self.sendTimeString = dateFormatter.string(from: self.eventDate as Date)
        
        super.init()
        
        // Create any body content objects
        
        switch eventType {
        case .textMessage:
            textMessage = EventTextMessage.fromEventJSON(eventJSON)
            break
            
        case .pictureMessage:
            pictureMessage = EventPictureMessage.fromEventJSON(eventJSON,
                                                               eventCustomerId: customerId,
                                                               eventCompanyId: companyId)
            break
            
        default:
            // No-op
            break
        }
        
        if EventType.typeMayContainSRSContent(eventType) {
            srsResponse = EventSRSResponse.fromEventJSON(eventJSON)
        }
        
        if ephemeralType == EphemeralType.typingStatus {
            typingStatus = EventTypingStatus.fromEventJSON(eventJSON: eventJSON)
        }
        
        chatMessage = ChatMessage.fromEvent(self)
    }
}

// MARK:- JSON Parsing

extension Event {
    
    class func fromJSON(_ json: [String : Any]?) -> Event? {
        guard let json = json else {
            return nil
        }
        
        guard let eventTypeInt = json["EventType"] as? Int,
            let ephemeralTypeInt = json["EphemeralType"] as? Int,
            let issueId = json["IssueId"] as? Int,
            let companyId = json["CompanyId"] as? Int,
            let customerId = json["CustomerId"] as? Int,
            let repId = json["RepId"] as? Int,
            let eventTimeInMicroSeconds = json["EventTime"] as? Double,
            let eventFlags = json["EventFlags"] as? Int,
            let customerEventLogSeq = json["CustomerEventLogSeq"] as? Int,
            let companyEventLogSeq = json["CompanyEventLogSeq"] as? Int
            else {
                return nil
        }

        guard let ephemeralType = EphemeralType(rawValue: ephemeralTypeInt) else {
            DebugLog.d("Ignoring event with ephemeral type: \(ephemeralTypeInt)")
            return nil
        }
        
        
        // Event JSON
        var eventJSONString = json["EventJSON"] as? String
        
        // EventType
        var tempEventType = EventType(rawValue: eventTypeInt)
        if tempEventType == EventType.srsAction ||
            (ephemeralType == EphemeralType.eventStatus && tempEventType == .none) {
            tempEventType = EventType.srsResponse
        }
        if tempEventType == EventType.srsEcho,
            let tempJSON = JSONUtil.parseString(eventJSONString),
            let echoJSONString = tempJSON["Echo"] as? String {
            eventJSONString = echoJSONString
            tempEventType = EventType.srsResponse
        }
        
        // Demo Content
        if ASAPP.isDemoContentEnabled() {
            // Appointment Scheduler
            if tempEventType == .scheduleAppointment {
                if let scheduleApptJSON = Event.getDemoEventJsonString(eventType: .scheduleAppointment, company: nil) {
                    tempEventType = .srsResponse
                    eventJSONString = scheduleApptJSON
                }
                
            }
            // Live Chat Began
            else if tempEventType == .newRep || tempEventType == .switchSRSToChat {
                if let liveChatBeginJson = Event.getDemoEventJsonString(eventType: .liveChatBegin, company: nil) {
                    eventJSONString = liveChatBeginJson
                }
            }
            // Conversation End
            else if tempEventType == .conversationEnd {
                if let liveChatEndJson = Event.getDemoEventJsonString(eventType: .liveChatEnd, company: nil) {
                    eventJSONString = liveChatEndJson
                }
            }
        }
        
        guard let eventType = tempEventType else {
            DebugLog.d("Ignoring event with event type: \(eventTypeInt)")
            return nil
        }
    
        var eventJSON = JSONUtil.parseString(eventJSONString)
        var parentEventLogSeq = eventJSON?["ParentEventLogSeq"] as? Int
        
        return Event(eventId: max(customerEventLogSeq, companyEventLogSeq),
                     parentEventLogSeq: parentEventLogSeq,
                     eventType: eventType,
                     ephemeralType: ephemeralType,
                     eventTime: eventTimeInMicroSeconds / 1000000,
                     issueId: issueId,
                     companyId: companyId,
                     customerId: customerId,
                     repId: repId,
                     eventFlags: eventFlags,
                     eventJSON: eventJSON)
    }
}
