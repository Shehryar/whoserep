//
//  Event.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/20/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation
import RealmSwift

@objc enum EventType: Int {
    case None = 0
    case TextMessage = 1
    case NewIssue = 2
    case NewRep = 3
    case ConversationEnd = 4
    case PictureMessage = 5
    case PrivateNote = 6
    case NewIssueTopic = 7
    case IssueEnqueued = 8
    case ConversationRated = 9
    case CustomerTimedOut = 10
    case CRMCustomerLinked = 11
    case IssueSummarized = 12
    case TextAnnotation = 13
    case CustomerPrompt = 14
    case CustomerConversationEnd = 15
    case IssueAnnotation = 16
    case WhisperMessage = 17
    case CustomerFeedback = 18
    case VCardMessage = 19
}

@objc enum EphemeralType: Int {
    case None = 0
    case TypingStatus = 1
    case TypingPreview = 2
    case CustomerCRMInfo = 3
    case UpdateCustomerIdentifiers = 4
    case ConnectionUpdate = 5
    case IPBlock = 6
}

class EventPayload: NSObject {
    struct TextMessage {
        let text: String
    }
    
    struct TypingStatus {
        let isTyping: Bool
    }
}

class Event: Object {
    
    // MARK:- Realm Properties
    
    dynamic var createdTime = 0
    dynamic var issueId = 0
    dynamic var companyId = 0
    dynamic var customerId = 0
    dynamic var repId = 0
    dynamic var eventTime = 0
    dynamic var eventType = EventType.None
    dynamic var ephemeralType = EphemeralType.None
    dynamic var eventFlags = 0
    dynamic var eventJSON = ""
    dynamic var eventLogSeq = 0
    dynamic var uniqueIdentifier: String = NSUUID().UUIDString
    
    override class func primaryKey() -> String? {
        return "uniqueIdentifier"
    }
    
    // MARK:- Read-only Properties
    
    var isCustomerEvent: Bool {
        return eventFlags == 1
    }
    var isMessageEvent: Bool {
        return eventType == .TextMessage || eventType == .PictureMessage
    }
    var shouldDisplay: Bool {
        return eventType == .TextMessage || eventType == .PictureMessage
    }
    
    // MARK:- Initialization
    
    convenience init(createdTime: Int, issueId: Int, companyId: Int, customerId: Int, repId: Int, eventTime: Int, eventType: EventType, ephemeralType: EphemeralType, eventFlags: Int, eventJSON: String) {
        self.init()
        
        self.createdTime = createdTime
        self.issueId = issueId
        self.companyId = companyId
        self.customerId = customerId
        self.repId = repId
        self.eventTime = eventTime
        self.eventType = eventType
        self.ephemeralType = ephemeralType
        self.eventFlags = eventFlags
        self.eventJSON = eventJSON
    }
    
    convenience init?(withJSON json: [String: AnyObject]?) {
        guard let json = json else {
            return nil
        }
        
        guard let eventTypeInt = json["EventType"] as? Int,
            let ephemeralTypeInt = json["EphemeralType"] as? Int
            else {
                return nil
        }
        
        guard let createdTime = json["CreatedTime"] as? Int,
            let issueId = json["IssueId"] as? Int,
            let companyId = json["CompanyId"] as? Int,
            let customerId = json["CustomerId"] as? Int,
            let repId = json["RepId"] as? Int,
            let eventTime = json["EventTime"] as? Int,
            let eventType = EventType(rawValue: eventTypeInt),
            let ephemeralType = EphemeralType(rawValue: ephemeralTypeInt),
            let eventFlags = json["EventFlags"] as? Int,
            let eventJSON = json["EventJSON"] as? String,
            let customerEventLogSeq = json["CustomerEventLogSeq"] as? Int,
            let companyEventLogSeq = json["CompanyEventLogSeq"] as? Int
            else {
                return nil
        }

        self.init()
        
        self.createdTime = createdTime
        self.issueId = issueId
        self.companyId = companyId
        self.customerId = customerId
        self.repId = repId
        self.eventTime = eventTime
        self.eventType = eventType
        self.ephemeralType = ephemeralType
        self.eventFlags = eventFlags
        self.eventJSON = eventJSON
        self.eventLogSeq = max(customerEventLogSeq, companyEventLogSeq)
    }

    // MARK:- Instance Methods
    
    func getPayload() -> Any? {
        return payload
    }
    
    // MARK:- Ignored Properties
    
    override static func ignoredProperties() -> [String] {
        return ["eventJSONObject", "payload"]
    }
    
    lazy var eventJSONObject: [String : AnyObject]? = {
        var eventJSONObject: [String : AnyObject]?
        do {
            eventJSONObject =  try NSJSONSerialization.JSONObjectWithData(self.eventJSON.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as? [String : AnyObject]
        } catch {
            // Unable to serialize eventJSON
            DebugLogError("Unable to serialize eventJSON: \(self.eventJSON)")
        }
        return eventJSONObject
    }()
    
    lazy var payload: Any? = {
        guard let eventJSONObject = self.eventJSONObject else {
            return nil
        }
        
        switch self.eventType {
        case .TextMessage:
            if let text = eventJSONObject["Text"] as? String {
                return EventPayload.TextMessage(text: text)
            }
            break
            
        case .None:
            switch self.ephemeralType {
            case .TypingStatus:
                if let isTyping = eventJSONObject["IsTyping"] as? Bool {
                    return EventPayload.TypingStatus(isTyping: isTyping)
                }
                break
                
            default:
                break
            }
            break
            
        default:
            break
        }
        
        return nil
    }()
}
