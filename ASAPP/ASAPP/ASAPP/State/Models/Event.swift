//
//  Event.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/20/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import RealmSwift

class EventPayload: NSObject {
    struct TextMessage {
        let Text: String
    }
}

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
    
    override static func primaryKey() -> String? {
        return "eventLogSeq"
    }
    
    // MARK:- Read-only Properties
    
    public var isCustomerEvent: Bool {
        return eventFlags == 1
    }
    public var isMessageEvent: Bool {
        return eventType == .TextMessage || eventType == .PictureMessage
    }
    public var shouldDisplay: Bool {
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
    
    func payload() -> Any? {
        if eventType == .TextMessage {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(eventJSON.dataUsingEncoding(NSUTF8StringEncoding)!, options: [])
                
                if let text = json["Text"] as? String {
                    return EventPayload.TextMessage(Text: text)
                }
            } catch let error as NSError {
                ASAPPLoge(error)
            } catch {
                ASAPPLoge("Unknown Error")
            }
        }
        
        return nil
    }
}
