//
//  Event.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/20/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

@objc enum EventType: Int {
    case none = 0
    case textMessage = 1
    case newIssue = 2
    case newRep = 3
    case conversationEnd = 4
    case pictureMessage = 5
    case privateNote = 6
    case newIssueTopic = 7
    case issueEnqueued = 8
    case conversationRated = 9
    case customerTimedOut = 10
    case crmCustomerLinked = 11
    case issueSummarized = 12
    case textAnnotation = 13
    case customerPrompt = 14
    case customerConversationEnd = 15
    case issueAnnotation = 16
    case whisperMessage = 17
    case customerFeedback = 18
    case vCardMessage = 19
    case srsResponse = 22
    case srsEcho = 23
    case srsAction = 24
}

@objc enum EphemeralType: Int {
    case none = 0
    case typingStatus = 1
    case typingPreview = 2
    case customerCRMInfo = 3
    case updateCustomerIdentifiers = 4
    case connectionUpdate = 5
    case eventStatus = 6
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

class Event: NSObject {
    
    // MARK: Realm Properties
    
    var createdTime: Double = 0 // in micro-seconds
    var issueId = 0
    var companyId = 0
    var customerId = 0
    var repId = 0
    var eventTime: Double = 0 // in micro-seconds
    var eventType = EventType.none
    var ephemeralType = EphemeralType.none
    var eventFlags = 0
    var eventJSON = ""
    var eventLogSeq = 0
    var uniqueIdentifier: String = UUID().uuidString
    
    // MARK: Read-only Properties
    
    var isCustomerEvent: Bool {
        return eventFlags == 1
    }
    var eventTimeInSeconds: Double {
        return Double(Int64(eventTime / 1000000))
    }
    var eventDate: Date {
        return Date(timeIntervalSince1970: eventTimeInSeconds)
    }
    
    // MARK: Lazy Properties
    
    lazy var eventJSONObject: [String : AnyObject]? = {
        guard !self.eventJSON.isEmpty else { return nil }
        
        var eventJSONObject: [String : AnyObject]?
        do {
            eventJSONObject =  try JSONSerialization.jsonObject(with: self.eventJSON.data(using: String.Encoding.utf8)!, options: []) as? [String : AnyObject]
        } catch {
            // Unable to serialize eventJSON
            DebugLogError("Unable to serialize eventJSON: \(self.eventJSON)")
        }
        return eventJSONObject
    }()
    
    lazy var textMessage: TextMessage? = {
        guard self.eventType == .textMessage else { return nil }
        guard let eventJSONObject = self.eventJSONObject else { return nil }
        
        if let text = eventJSONObject["Text"] as? String {
            return TextMessage(text: text)
        }
        return nil
    }()
    
    lazy var pictureMessage: PictureMessage? = {
        guard self.eventType == .pictureMessage else { return nil }
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
        guard self.eventType == .none && self.ephemeralType == .typingStatus else { return nil }
        guard let eventJSONObject = self.eventJSONObject else { return nil }
        
        if let isTyping = eventJSONObject["IsTyping"] as? Bool {
            return TypingStatus(isTyping: isTyping)
        }
        return nil
    }()
    
    lazy var typingPreview: TypingPreview? = {
        guard self.eventType == .none && self.ephemeralType == .typingPreview else { return nil }
        guard let eventJSONObject = self.eventJSONObject else { return nil }
        
        if let previewText = eventJSONObject["Text"] as? String {
            return TypingPreview(previewText: previewText)
        }
        return nil
    }()
    
    lazy var connectionUpdate: ConnectionUpdate? = {
        guard self.eventType == .none && self.ephemeralType == .connectionUpdate else { return nil }

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
        guard self.eventType == .crmCustomerLinked else { return nil }
        
        if let linkedTime = self.eventJSONObject?["CRMCustomerLinkedTime"] as? Double {
            return CRMCustomerLinked(linkedTime: linkedTime)
        }
        
        return nil
    }()
    
    lazy var newIssue: Issue? = {
        guard self.eventType == .newIssue else { return nil }
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
        guard self.eventType == .newRep else { return nil }
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

    lazy var srsResponse: SRSResponse? = {
        guard self.eventType == .srsResponse else { return nil }
        
        return SRSResponse.instanceWithJSON(self.eventJSONObject) as? SRSResponse
    }()
    
    lazy var parentEventLogSeq: Int? = {
        guard let json = self.eventJSONObject else {
            return nil
        }
        return json["ParentEventLogSeq"] as? Int
    }()
    
    // MARK:- Initialization
    
    convenience init?(withJSON json: [String: Any]?) {
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
        if self.eventType == .srsAction {
            self.eventType = .srsResponse
        }
        self.ephemeralType = ephemeralType
        self.eventFlags = eventFlags
        self.eventJSON = eventJSON
        self.eventLogSeq = max(customerEventLogSeq, companyEventLogSeq)
        
        
        if DEMO_CONTENT_ENABLED && self.eventType == .srsEcho {
            var eventJSONObject: [String : AnyObject]?
            do {
                eventJSONObject =  try JSONSerialization.jsonObject(with: self.eventJSON.data(using: String.Encoding.utf8)!, options: []) as? [String : AnyObject]
            } catch {
                // ignore for now....
                
            }
            
            if let parsedEchoContent = eventJSONObject?["Echo"] as? String {
                self.eventType = .srsResponse
                self.eventJSON = parsedEchoContent
            }
        }
    }
}

// MARK:- Instance Methods

extension Event {
    func wasSentByUserWithCredentials(_ credentials: Credentials) -> Bool {
        
        // TODO: Check IDs of some sort... which IDs?
        
        if credentials.isCustomer {
            return isCustomerEvent
        } else {
            return !isCustomerEvent
        }
    }
    
    func imageURLForPictureMessage(_ pictureMessage: PictureMessage?) -> URL? {
        guard let pictureMessage = pictureMessage else { return nil }
        
        let imageSuffix = pictureMessage.mimeType.components(separatedBy: "/").last ?? "jpg"
        let urlString = "https://\(pictureMessage.fileBucket).s3.amazonaws.com/customer/\(customerId)/company/\(companyId)/\(pictureMessage.fileSecret)-\(pictureMessage.width)x\(pictureMessage.height).\(imageSuffix)"
        
        return URL(string: urlString)
    }
}

// MARK:- Sample Data

extension Event {
    
    // MARK: Generic
    
    class func sampleEvent(_ type: EventType, eventJSON: String, afterEvent: Event? = nil, eventLogSeq: Int? = nil) -> Event? {
        let eventTime: Double = Date().timeIntervalSince1970 * 1000000.0
        
        var companyEventLogSeq = 0
        var customerEventLogSeq = 0
        if let eventLogSeq = eventLogSeq {
            companyEventLogSeq = eventLogSeq
            customerEventLogSeq = eventLogSeq
        } else if let previousEventLogSeq = afterEvent?.eventLogSeq {
            companyEventLogSeq = previousEventLogSeq + 1
            customerEventLogSeq = companyEventLogSeq
        }
        
        let json = [
            "CreatedTime" : eventTime,
            "IssueId" :  afterEvent?.issueId ?? 350001,
            "CompanyId" : afterEvent?.companyId ?? 10001,
            "CustomerId" : afterEvent?.customerId ?? 130001,
            "RepId" : afterEvent?.repId ?? 20001,
            "EventTime" : eventTime,
            "EventType" : type.rawValue,
            "EphemeralType" : 0,
            "EventFlags" : 0,
            "CompanyEventLogSeq" : companyEventLogSeq,
            "CustomerEventLogSeq" : customerEventLogSeq,
            "EventJSON" : eventJSON
        ] as [String : Any]
        
        return Event(withJSON: json)
    }
    
    class func sampleEventWithJSONFile(_ fileName: String, afterEvent: Event? = nil, eventLogSeq: Int? = nil) -> Event? {
        if let jsonString = jsonStringForFile(fileName) {
            let event = sampleEvent(EventType.srsResponse, eventJSON: jsonString, afterEvent: afterEvent, eventLogSeq: eventLogSeq)
            return event
        }
        return nil
    }
    
    class func jsonStringForFile(_ fileName: String) -> String? {
        if let path = ASAPPBundle.path(forResource: fileName, ofType: "json") {
            if let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) {
                return jsonString
            }
        }
        return nil
    }
    
    
    // MARK: Specific
    
    class func sampleBillSummaryEvent(_ afterEvent: Event? = nil) -> Event? {
        if let path = ASAPPBundle.path(forResource: "sample_bill_data", ofType: "json") {
            if let eventJSONString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) {
                let event = sampleEvent(EventType.srsResponse, eventJSON: eventJSONString, afterEvent: afterEvent)
                return event
            }
        }
        return nil
    }
    
    class func sampleTroubleshooterEvent(_ afterEvent: Event? = nil) -> Event? {
        if let path = ASAPPBundle.path(forResource: "sample_troubleshoot_data", ofType: "json") {
            if let eventJSONString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) {
                let event = sampleEvent(EventType.srsResponse, eventJSON: eventJSONString, afterEvent: afterEvent)
                return event
            }
        }
        return nil
    }
    
    class func sampleDeviceRestartEvent(_ afterEvent: Event? = nil) -> Event? {
        if let path = ASAPPBundle.path(forResource: "sample_device_restart_data", ofType: "json") {
            if let eventJSONString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) {
                let event = sampleEvent(EventType.srsResponse, eventJSON: eventJSONString, afterEvent: afterEvent)
                return event
            }
        }
        return nil
    }
    
    class func sampleEquipmentReturnEvent(_ eventLogSeq: Int? = nil) -> Event? {
        if let path = ASAPPBundle.path(forResource: "sample_equipment_return_data", ofType: "json") {
            if let eventJSONString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) {
                let event = sampleEvent(EventType.srsResponse, eventJSON: eventJSONString, eventLogSeq: eventLogSeq)
                return event
            }
        }
        return nil
    }
    
    
    
    
    
    class func sampleTechLocationEvent(_ eventLogSeq: Int? = nil) -> Event? {
        return sampleEventWithJSONFile("sample_tech_location_data", eventLogSeq: eventLogSeq)
    }
    
    class func sampleCancelAppointmentPromptEvent(_ eventLogSeq: Int? = nil) -> Event? {
        return sampleEventWithJSONFile("sample_cancel_appointment_prompt_data", eventLogSeq: eventLogSeq)
    }
    
    class func sampleCancelAppointmentConfirmationEvent(_ eventLogSeq: Int? = nil) -> Event? {
        return sampleEventWithJSONFile("sample_cancel_appiontment_response_data", eventLogSeq: eventLogSeq)
    }
    
    
}
