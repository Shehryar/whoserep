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
    case newRep = 3
    case conversationEnd = 4
    case pictureMessage = 5
    case srsResponse = 22
    case srsEcho = 23
    case srsAction = 24
    case scheduleAppointment = 27
    case switchSRSToChat = 28
}

@objc enum EphemeralType: Int {
    case none = 0
    case typingStatus = 1
    case eventStatus = 6
}

// MARK:- Event

class Event: NSObject {
    
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
    var messageText: String? {
        switch eventType {
        case .textMessage: return textMessage?.text
        case .pictureMessage: return nil
            
        default: return srsResponse?.messageText
        }
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
    
    lazy var srsResponse: SRSResponse? = {
        if self.eventType == .srsResponse {
            return SRSResponse.instanceWithJSON(self.eventJSONObject) as? SRSResponse
        }
        
        if let messageBody = self.eventJSONObject?["ClientMessage"] as? [String : AnyObject] {
            return SRSResponse.instanceWithJSON(messageBody) as? SRSResponse
        }
        return nil
    }()
    
    lazy var parentEventLogSeq: Int? = {
        guard let json = self.eventJSONObject else {
            return nil
        }
        return json["ParentEventLogSeq"] as? Int
    }()
    
    lazy var sendTimeString: String? = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.eventDate.dateFormatForMostRecent()
        return dateFormatter.string(from: self.eventDate as Date)
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
        
        
        if self.eventType == .srsEcho {
            var eventJSONObject: [String : AnyObject]?
            do {
                eventJSONObject =  try JSONSerialization.jsonObject(with: self.eventJSON.data(using: String.Encoding.utf8)!, options: []) as? [String : AnyObject]
            } catch {}
            
            if let parsedEchoContent = eventJSONObject?["Echo"] as? String {
                self.eventType = .srsResponse
                self.eventJSON = parsedEchoContent
            }
        }
        
        if ASAPP.isDemoContentEnabled() {
            if self.eventType == .scheduleAppointment {
                if let scheduleApptJSON = Event.getDemoEventJsonString(eventType: .scheduleAppointment, company: nil) {
                    self.eventType = .srsResponse
                    self.eventJSON = scheduleApptJSON
                }
                
            }
        }
        
        
        if ASAPP.isDemoContentEnabled() {
            if self.eventType == .newRep || self.eventType == .switchSRSToChat {
                if let liveChatBeginJson = Event.getDemoEventJsonString(eventType: .liveChatBegin, company: nil) {
                    self.eventJSON = liveChatBeginJson
                }
            } else if self.eventType == .conversationEnd {
                if let liveChatEndJson = Event.getDemoEventJsonString(eventType: .liveChatEnd, company: nil) {
                    self.eventJSON = liveChatEndJson
                }
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

