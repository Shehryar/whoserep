//
//  ASAPPEventLog.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/16/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

protocol ASAPPEventLogDelegate {
    func didProcessEvent(event: ASAPPEvent, isNew: Bool)
    func didClearEventLog()
    
    func fetchEvents(after: Int)
}

typealias ASAPPTime = UInt
typealias ASAPPId = UInt

enum ASAPPEventType: Int {
    case EventTypeNone = 0
    case EventTypeTextMessage = 1
    case EventTypeNewIssue = 2
    case EventTypeNewRep = 3
    case EventTypeConversationEnd = 4
    case EventTypePictureMessage = 5
    case EventTypePrivateNote = 6
    case EventTypeNewIssueTopic = 7
    case EventTypeIssueEnqueued = 8
    case EventTypeConversationRated = 9
    case EventTypeCustomerTimedOut = 10
    case EventTypeCRMCustomerLinked = 11
    case EventTypeIssueSummarized = 12
    case EventTypeTextAnnotation = 13
    case EventTypeCustomerPrompt = 14
    case EventTypeCustomerConversationEnd = 15
    case EventTypeIssueAnnotation = 16
    case EventTypeWhisperMessage = 17
    case EventTypeCustomerFeedback = 18
    case EventTypeVCardMessage = 19
}

enum ASAPPEphemeralType: Int {
    case EphemeralTypeNone = 0
    case EphemeralTypeTypingStatus = 1
    case EphemeralTypeTypingPreview = 2
    case EphemeralTypeCustomerCRMInfo = 3
    case EphemeralTypeUpdateCustomerIdentifiers = 4
    case EphemeralTypeConnectionUpdate = 5
    case EphemeralTypeIPBlock = 6
}

typealias ASAPPCreatedTime = ASAPPTime
typealias ASAPPIssueId = ASAPPId
typealias ASAPPCompanyId = ASAPPId
typealias ASAPPCustomerId = ASAPPId
typealias ASAPPRepId = ASAPPId
typealias ASAPPEventTime = ASAPPTime
typealias ASAPPEventFlag = UInt
typealias ASAPPEventJSON = String

class ASAPPEvent: NSObject {
    var CreatedTime: ASAPPCreatedTime!
    var IssueId: ASAPPIssueId!
    var CompanyId: ASAPPCompanyId!
    var CustomerId: ASAPPCustomerId!
    var RepId: ASAPPRepId!
    var EventTime: ASAPPEventTime!
    var EventType: ASAPPEventType!
    var EphemeralType: ASAPPEphemeralType!
    var EventFlags: ASAPPEventFlag!
    var EventJSON: ASAPPEventJSON!
    
    convenience init(createdTime: ASAPPCreatedTime, issueId: ASAPPIssueId, companyId: ASAPPCompanyId, customerId: ASAPPCustomerId, repId: ASAPPRepId, eventTime: ASAPPEventTime, eventType: ASAPPEventType, ephemeralType: ASAPPEphemeralType, eventFlags: ASAPPEventFlag, eventJSON: ASAPPEventJSON) {
        self.init()
        CreatedTime = createdTime
        IssueId = issueId
        CompanyId = companyId
        CustomerId = customerId
        RepId = repId
        EventTime = eventTime
        EventType = eventType
        EphemeralType = ephemeralType
        EventFlags = eventFlags
        EventJSON = eventJSON
    }
    
    func isCustomerEvent() -> Bool {
        if EventFlags == 1 {
            return true
        }
        
        return false
    }
    
    func isMyEvent() -> Bool {
        if ASAPP.isCustomer() && isCustomerEvent() {
            return true
        } else if !ASAPP.isCustomer() && ASAPP.myId() != nil && ASAPP.myId() == RepId {
            return true
        }
        
        return false
    }
    
    func isMessageEvent() -> Bool {
        if EventType == ASAPPEventType.EventTypeTextMessage || EventType == ASAPPEventType.EventTypePictureMessage {
            return true
        }
        
        return false
    }
    
    func payload() -> Any? {
        if EventType == ASAPPEventType.EventTypeTextMessage {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(EventJSON.dataUsingEncoding(NSUTF8StringEncoding)!, options: [])
                
                if let text = json["Text"] as? String {
                    return ASAPPEventPayload.TextMessage(Text: text)
                }
            } catch let error as NSError {
                print(error)
            }
        }
        
        return nil
    }
    
    func shouldDisplay() -> Bool {
        if EventType == ASAPPEventType.EventTypeTextMessage ||
            EventType == ASAPPEventType.EventTypePictureMessage {
            return true
        }
        
        return false
    }
}

class ASAPPEventPayload: NSObject {
    struct TextMessage {
        let Text: String
    }
}

class ASAPPEventLog: NSObject {
    
    var delegate: ASAPPEventLogDelegate!
    var events: [ASAPPEvent] = []
    
    func processEvent(eventData: String, isNew: Bool) {
        var json: [String: AnyObject] = [:]
        do {
            json = try NSJSONSerialization.JSONObjectWithData(eventData.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as! [String: AnyObject]
        } catch let err as NSError {
            ASAPPLoge(err)
        }
        
        print(eventTypeEnumValue(json["EventType"]))
        guard let createdTime = json["CreatedTime"] as? ASAPPCreatedTime,
            let issueId = json["IssueId"] as? ASAPPIssueId,
            let companyId = json["CompanyId"] as? ASAPPCompanyId,
            let customerId = json["CustomerId"] as? ASAPPCustomerId,
            let repId = json["RepId"] as? ASAPPRepId,
            let eventTime = json["EventTime"] as? ASAPPEventTime,
            let eventType = eventTypeEnumValue(json["EventType"]),
            let ephemeralType = ephemeralTypeEnumValue(json["EphemeralType"]),
            let eventFlags = json["EventFlags"] as? ASAPPEventFlag,
            let eventJSON = json["EventJSON"] as? ASAPPEventJSON
            else {
                return
        }
        
        let event = ASAPPEvent(createdTime: createdTime, issueId: issueId, companyId: companyId, customerId: customerId, repId: repId, eventTime: eventTime, eventType: eventType, ephemeralType: ephemeralType, eventFlags: eventFlags, eventJSON: eventJSON)
    
        if isNew {
            saveEvent(event)
        }
        
        if delegate != nil {
            delegate.didProcessEvent(event, isNew: isNew)
        }
    }
    
    func eventTypeEnumValue(rawValue: AnyObject?) -> ASAPPEventType? {
        var enumValue: ASAPPEventType? = nil
        if let value = rawValue as? Int {
            enumValue = ASAPPEventType.init(rawValue: value)
        }
        return enumValue
    }
    
    func ephemeralTypeEnumValue(rawValue: AnyObject?) -> ASAPPEphemeralType? {
        var enumValue: ASAPPEphemeralType? = nil
        if let value = rawValue as? Int {
            enumValue = ASAPPEphemeralType.init(rawValue: value)
        }
        return enumValue
    }
    
    func saveEvent(event: ASAPPEvent) {
        
    }
    
    func reloadEventLog() {
        
    }
    
    func clearAll() {
        events.removeAll()
        
        if delegate != nil {
            delegate.didClearEventLog()
        }
    }
}