//
//  ASAPPEventLog.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/16/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation
import RealmSwift

protocol ASAPPEventLogDelegate {
    func didProcessEvent(event: ASAPPEvent, isNew: Bool)
    func didClearEventLog()
}

typealias ASAPPTime = Int
typealias ASAPPId = Int
typealias ASAPPEventType = Int
typealias ASAPPEphemeralType = Int

enum ASAPPEventTypes: ASAPPEventType {
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

enum ASAPPEphemeralTypes: ASAPPEphemeralType {
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
typealias ASAPPEventFlag = Int
typealias ASAPPEventJSON = String

class ASAPPEvent: Object {
    dynamic var CreatedTime: ASAPPCreatedTime = 0
    dynamic var IssueId: ASAPPIssueId = 0
    dynamic var CompanyId: ASAPPCompanyId = 0
    dynamic var CustomerId: ASAPPCustomerId = 0
    dynamic var RepId: ASAPPRepId = 0
    dynamic var EventTime: ASAPPEventTime = 0
    dynamic var EventType: ASAPPEventType = 0
    dynamic var EphemeralType: ASAPPEphemeralType = 0
    dynamic var EventFlags: ASAPPEventFlag = 0
    dynamic var EventJSON: ASAPPEventJSON = ""
    dynamic var EventLogSeq: Int = 0
    
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
    
    override static func primaryKey() -> String? {
        return "EventLogSeq"
    }
    
    func isCustomerEvent() -> Bool {
        if EventFlags == 1 {
            return true
        }
        
        return false
    }
    
    func isMessageEvent() -> Bool {
        if EventType == ASAPPEventTypes.EventTypeTextMessage.rawValue || EventType == ASAPPEventTypes.EventTypePictureMessage.rawValue {
            return true
        }
        
        return false
    }
    
    func payload() -> Any? {
        if EventType == ASAPPEventTypes.EventTypeTextMessage.rawValue {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(EventJSON.dataUsingEncoding(NSUTF8StringEncoding)!, options: [])
                
                if let text = json["Text"] as? String {
                    return ASAPPEventPayload.TextMessage(Text: text)
                }
            } catch let error as NSError {
                ASAPPLoge(error)
            } catch {
                ASAPPLoge("Unknown Error")
            }
        }
        
        return nil
    }
    
    func shouldDisplay() -> Bool {
        if EventType == ASAPPEventTypes.EventTypeTextMessage.rawValue ||
            EventType == ASAPPEventTypes.EventTypePictureMessage.rawValue {
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
    
    var dataSource: ASAPPStateDataSource!
    var delegate: ASAPPEventLogDelegate!
    var store: ASAPPStore!
    
    var events: Results<ASAPPEvent>?
    
    convenience init(dataSource: ASAPPStateDataSource, delegate: ASAPPEventLogDelegate, store: ASAPPStore) {
        self.init()
        self.dataSource = dataSource
        self.delegate = delegate
        self.store = store
    }
    
    func load() {
        if events != nil || delegate == nil {
            return
        }
        
        events = store.mEventLog.sorted("EventLogSeq", ascending: true)
        for i in 0 ..< events!.count {
            let event = events![i]
            delegate.didProcessEvent(event, isNew: false)
        }
        
        if events?.last != nil {
            dataSource.fetchEvents((events?.last?.EventLogSeq)!)
        } else if delegate != nil {
            dataSource.fetchEvents(0)
        }
    }
    
    func processEvent(eventData: String, isNew: Bool) {
        var json: [String: AnyObject] = [:]
        do {
            json = try NSJSONSerialization.JSONObjectWithData(eventData.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as! [String: AnyObject]
        } catch let err as NSError {
            ASAPPLoge(err)
        } catch {
            ASAPPLoge("Unknown Error")
        }
        
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
        
        if dataSource.isCustomer() {
            if let eventLogSeq = json["CustomerEventLogSeq"] as? Int {
                event.EventLogSeq = eventLogSeq
            }
        } else {
            if let eventLogSeq = json["CompanyEventLogSeq"] as? Int {
                event.EventLogSeq = eventLogSeq
            }
        }
//        event.state = state
//        if isNew {
            saveEvent(event)
//        }
        
        if delegate != nil {
            delegate.didProcessEvent(event, isNew: isNew)
        }
    }
    
    func eventTypeEnumValue(rawValue: AnyObject?) -> ASAPPEventType? {
        var enumValue: ASAPPEventType? = nil
        if let value = rawValue as? Int {
            enumValue = ASAPPEventType(value)
        }
        return enumValue
    }
    
    func ephemeralTypeEnumValue(rawValue: AnyObject?) -> ASAPPEphemeralType? {
        var enumValue: ASAPPEphemeralType? = nil
        if let value = rawValue as? Int {
            enumValue = ASAPPEphemeralType(value)
        }
        return enumValue
    }
    
    func saveEvent(event: ASAPPEvent) {
        store.addEvent(event)
    }
    
    func reloadEventLog() {
        
    }
    
    func clearAll() {
        ASAPPLog("CLEAR EVENTLOG")
        
        if delegate != nil {
            delegate.didClearEventLog()
        }
    }
}