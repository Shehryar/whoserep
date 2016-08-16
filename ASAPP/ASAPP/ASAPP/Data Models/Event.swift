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
    case ActionableMessage = 20
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

// MARK:- Payloads

struct TextMessage {
    let text: String
}

struct PictureMessage {
    let fileBucket: String
    let fileSecret: String
    let mimeType: String
    let width: Int
    let height: Int
    
    /// Returns the aspect ratio (w/h) or 1 if either width/height == 0
    var aspectRatio: Double {
        if width <= 0 || height <= 0 {
            return 1
        }
        return Double(width) / Double(height)
    }
}

struct TypingStatus {
    let isTyping: Bool
}

struct TypingPreview {
    let previewText: String
}

struct Issue {
    let issueId: Int
    let companyId: Int
    let companyGroupId: Int
    let platformType: Int
    let customerId: Int
    let repId: Int
    let repIssuePos: Int
    let issueStatus: Int
    let issueStatusTime: Double
    let firstCompanyEventLogSeq: Int
    let lastCompanyEventLogSeq: Int
    let issueSecret: String
    let issueTopicId: Int
    let customerState: Int
    let createdTime: Double
    let endedTime: Double
    let resolved: Bool
    let regionId: Int
}

struct Rep {
    let repId: Int
    let companyId: Int
    let crmRepId: String
    let createdTime: Double
    let makeAdminTime: Double
    let maxSlot: Int
    let rolesJSON: String?
    let name: String
    let disabledTime: Double
}

struct ConnectionUpdate {
    let agentType: Int
    let connectionId: String
    let ipAddress: String
    let geoLocation: String
    let isOpen: Bool
}

struct CRMCustomerLinked {
    let linkedTime: Double
}

// MARK:- Event

class Event: Object {
    
    // MARK: Realm Properties
    
    dynamic var createdTime: Double = 0 // in micro-seconds
    dynamic var issueId = 0
    dynamic var companyId = 0
    dynamic var customerId = 0
    dynamic var repId = 0
    dynamic var eventTime: Double = 0 // in micro-seconds
    dynamic var eventType = EventType.None
    dynamic var ephemeralType = EphemeralType.None
    dynamic var eventFlags = 0
    dynamic var eventJSON = ""
    dynamic var eventLogSeq = 0
    dynamic var uniqueIdentifier: String = NSUUID().UUIDString
    
    // MARK: Read-only Properties
    
    var isCustomerEvent: Bool {
        return eventFlags == 1
    }
    var eventTimeInSeconds: Int64 {
        return Int64(eventTime / 1000000)
    }
    
    // MARK: Lazy Properties
    
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
    
    lazy var textMessage: TextMessage? = {
        guard self.eventType == .TextMessage else { return nil }
        guard let eventJSONObject = self.eventJSONObject else { return nil }
        
        if let text = eventJSONObject["Text"] as? String {
            return TextMessage(text: text)
        }
        return nil
    }()
    
    lazy var pictureMessage: PictureMessage? = {
        guard self.eventType == .PictureMessage else { return nil }
        guard let eventJSONObject = self.eventJSONObject else { return nil }
        
        if let fileBucket = eventJSONObject["FileBucket"] as? String,
            let fileSecret = eventJSONObject["FileSecret"] as? String,
            let mimeType = eventJSONObject["MimeType"] as? String,
            let width = eventJSONObject["PicWidth"] as? Int,
            let height = eventJSONObject["PicHeight"] as? Int {
            return PictureMessage(fileBucket: fileBucket, fileSecret: fileSecret, mimeType: mimeType, width: width, height: height)
        }
        return nil
    }()
    
    lazy var typingStatus: TypingStatus? = {
        guard self.eventType == .None && self.ephemeralType == .TypingStatus else { return nil }
        guard let eventJSONObject = self.eventJSONObject else { return nil }
        
        if let isTyping = eventJSONObject["IsTyping"] as? Bool {
            return TypingStatus(isTyping: isTyping)
        }
        return nil
    }()
    
    lazy var typingPreview: TypingPreview? = {
        guard self.eventType == .None && self.ephemeralType == .TypingPreview else { return nil }
        guard let eventJSONObject = self.eventJSONObject else { return nil }
        
        if let previewText = eventJSONObject["Text"] as? String {
            return TypingPreview(previewText: previewText)
        }
        return nil
    }()
    
    lazy var connectionUpdate: ConnectionUpdate? = {
        guard self.eventType == .None && self.ephemeralType == .ConnectionUpdate else { return nil }

        if let agentType = self.eventJSONObject?["AgentType"] as? Int,
            let connectionId = self.eventJSONObject?["ConnectionId"] as? String,
            let ipAddress = self.eventJSONObject?["IPAdress"] as? String,
            let geoLocation = self.eventJSONObject?["GeoLocation"] as? String,
            let isOpen = self.eventJSONObject?["IsOpen"] as? Bool {
            return ConnectionUpdate(agentType: agentType, connectionId: connectionId, ipAddress: ipAddress, geoLocation: geoLocation, isOpen: isOpen)
        }
        
        return nil
    }()
    
    lazy var crmCustomerLinked: CRMCustomerLinked? = {
        guard self.eventType == .CRMCustomerLinked else { return nil }
        
        if let linkedTime = self.eventJSONObject?["CRMCustomerLinkedTime"] as? Double {
            return CRMCustomerLinked(linkedTime: linkedTime)
        }
        
        return nil
    }()
    
    lazy var newIssue: Issue? = {
        guard self.eventType == .NewIssue else { return nil }
        guard let issueJSON = self.eventJSONObject?["Issue"] as? [String : AnyObject] else { return nil }
        
        if let issueId = issueJSON["IssueId"] as? Int,
            let companyId = issueJSON["CompanyId"] as? Int,
            let companyGroupId = issueJSON["CompanyGroupId"] as? Int,
            let platformType = issueJSON["PlatformType"] as? Int,
            let customerId = issueJSON["CustomerId"] as? Int,
            let repId = issueJSON["RepId"] as? Int,
            let repIssuePos = issueJSON["RepIssuePos"] as? Int,
            let issueStatus = issueJSON["IssueStatus"] as? Int,
            let issueStatusTime = issueJSON["IssueStatusTime"] as? Double,
            let firstCompanyEventLogSeq = issueJSON["FirstCompanyEventLogSeq"] as? Int,
            let lastCompanyEventLogSeq = issueJSON["LastCompanyEventLogSeq"] as? Int,
            let issueSecret = issueJSON["IssueSecret"] as? String,
            let issueTopicId = issueJSON["IssueTopicId"] as? Int,
            let customerState = issueJSON["CustomerState"] as? Int,
            let createdTime = issueJSON["CreatedTime"] as? Double,
            let endedTime = issueJSON["EndedTime"] as? Double,
            let resolved = issueJSON["Resolved"] as? Bool,
            let regionId = issueJSON["RegionId"] as? Int {
            return Issue(issueId: issueId, companyId: companyId, companyGroupId: companyGroupId, platformType: platformType, customerId: customerId, repId: repId, repIssuePos: repIssuePos, issueStatus: issueStatus, issueStatusTime: issueStatusTime, firstCompanyEventLogSeq: firstCompanyEventLogSeq, lastCompanyEventLogSeq: lastCompanyEventLogSeq, issueSecret: issueSecret, issueTopicId: issueTopicId, customerState: customerState, createdTime: createdTime, endedTime: endedTime, resolved: resolved, regionId: regionId)
        }
        
        return nil
    }()
    
    lazy var newRep: Rep? = {
        guard self.eventType == .NewRep else { return nil }
        guard let repJSON = self.eventJSONObject?["NewRep"] as? [String : AnyObject] else { return nil }
        
        if let repId = repJSON["RepId"] as? Int,
            let companyId = repJSON["CompanyId"] as? Int,
            let crmRepId = repJSON["CRMRepId"] as? String,
            let createdTime = repJSON["CreatedTime"] as? Double,
            let makeAdminTime = repJSON["MadeAdminTime"] as? Double,
            let maxSlot = repJSON["MaxSlot"] as? Int,
            let rolesJSON = repJSON["RolesJSON"] as? String,
            let name = repJSON["Name"] as? String,
            let disabledTime = repJSON["DisabledTime"] as? Double {
            return Rep(repId: repId, companyId: companyId, crmRepId: crmRepId, createdTime: createdTime, makeAdminTime: makeAdminTime, maxSlot: maxSlot, rolesJSON: rolesJSON, name: name, disabledTime: disabledTime)
        }
        
        return nil
    }()

    lazy var actionableMessage: ActionableMessage? = {
        guard self.eventType == .ActionableMessage else { return nil }

        return ActionableMessage.instanceWithJSON(self.eventJSONObject) as? ActionableMessage
    }()
    
    // MARK: Realm Property Methods
    
    override class func primaryKey() -> String? {
        return "uniqueIdentifier"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["eventJSONObject", "payload", "textMessage", "pictureMessage", "typingStatus", "typingPreview", "actionableMessage"]
    }
    
    // MARK:- Initialization
    
    convenience init?(withJSON json: [String: AnyObject]?) {
        guard let json = json else {
            return nil
        }
        
        guard let eventTypeInt = json["EventType"] as? Int,
            let ephemeralTypeInt = json["EphemeralType"] as? Int
            else {
                return nil
        }
        
        guard let createdTime = json["CreatedTime"] as? Double,
            let issueId = json["IssueId"] as? Int,
            let companyId = json["CompanyId"] as? Int,
            let customerId = json["CustomerId"] as? Int,
            let repId = json["RepId"] as? Int,
            let eventTime = json["EventTime"] as? Double,
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
}

// MARK:- Instance Methods

extension Event {
    func wasSentByUserWithCredentials(credentials: Credentials) -> Bool {
        
        // TODO: Check IDs of some sort... which IDs?
        
        if credentials.isCustomer {
            return isCustomerEvent
        } else {
            return !isCustomerEvent
        }
    }
    
    func imageURLForPictureMessage(pictureMessage: PictureMessage?) -> NSURL? {
        guard let pictureMessage = pictureMessage else { return nil }
        
        let imageSuffix = pictureMessage.mimeType.componentsSeparatedByString("/").last ?? "jpg"
        let urlString = "https://\(pictureMessage.fileBucket).s3.amazonaws.com/customer/\(customerId)/company/\(companyId)/\(pictureMessage.fileSecret)-\(pictureMessage.width)x\(pictureMessage.height).\(imageSuffix)"
        
        return NSURL(string: urlString)
    }
}

// MARK:- Sample Data

extension Event {
    class func sampleActionableMessageEvent() -> Event? {
        
        return Event(withJSON: [
            "CreatedTime" : 1471362546941927.0,
            "IssueId" : 350001,
            "CompanyId" : 10001,
            "CustomerId" : 130001,
            "RepId" : 20001,
            "EventTime" : 1471362546941927.0,
            "EventType" : 20,
            "EphemeralType" : 0,
            "EventFlags" : 0,
            "CompanyEventLogSeq":600,
            "CustomerEventLogSeq":0,
            "EventJSON" : "{ \"Message\" : \"What's yo problem?\", \"Actions\" : [ { \"Name\" : \"Internet\", \"Type\" : 0 }, { \"Name\" : \"Cable\", \"Type\" : 0 }, { \"Name\" : \"Phone\", \"Type\" : 0 }, { \"Name\" : \"Relationships\", \"Type\" : 1 } ] }"
            ])
    }
}
