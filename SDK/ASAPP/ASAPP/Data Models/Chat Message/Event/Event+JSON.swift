//
//  Event+JSON.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- JSON Keys

extension Event {
    
    enum JSONKey: String {
        // Base Event
        case companyEventLogSeq = "CompanyEventLogSeq"
        case companyId = "CompanyId"
        case customerEventLogSeq = "CustomerEventLogSeq"
        case customerId = "CustomerId"
        case echo = "Echo"
        case ephemeralType = "EphemeralType"
        case eventFlags = "EventFlags"
        case eventJSON = "EventJSON"
        case eventTime = "EventTime"
        case eventType = "EventType"
        case issueId = "IssueId"
        case parentEventLogSeq = "ParentEventLogSeq"
        case repId = "RepId"
        
        // Text Message Event
        case text = "Text"
        
        // Picture Message Event
        case fileBucket = "FileBucket"
        case fileSecret = "FileSecret"
        case mimeType = "MimeType"
        case picHeight = "PicHeight"
        case picWidth = "PicWidth"
        
        // Typing Status
        case isTyping = "IsTyping"
        
        //  SwitchChatToSRS
        case intent = "Intent"
    }
}

// MARK: Parsing JSON

extension Event {
    
    class func fromJSON(_ json: Any?) -> Event? {
        guard let json = json as? [String : Any] else {
            return nil
        }
        
        // Required Properties
        guard let originalEventType = EventType.from(json[JSONKey.eventType.rawValue]),
            let ephemeralType = EphemeralEventType.from(json[JSONKey.ephemeralType.rawValue]),
            let issueId = json[JSONKey.issueId.rawValue] as? Int,
            let companyId = json[JSONKey.companyId.rawValue] as? Int,
            let customerId = json[JSONKey.customerId.rawValue] as? Int,
            let repId = json[JSONKey.repId.rawValue] as? Int,
            let eventTimeInMicroSeconds = json[JSONKey.eventTime.rawValue] as? Double,
            let eventFlags = json[JSONKey.eventFlags.rawValue] as? Int,
            let customerEventLogSeq = json[JSONKey.customerEventLogSeq.rawValue] as? Int,
            let companyEventLogSeq = json[JSONKey.companyEventLogSeq.rawValue] as? Int
            else {
                DebugLog.d(caller: self, "Event missing required properties: \(json)")
                return nil
        }
        
        let (eventType, eventJSON) = getEventTypeAndContent(from: json,
                                                            eventType: originalEventType,
                                                            ephemeralType: ephemeralType)
        
        let parentEventLogSeq = json.int(for: JSONKey.parentEventLogSeq.rawValue) ??
            eventJSON?.int(for: JSONKey.parentEventLogSeq.rawValue)
        
        let event = Event(eventId: max(customerEventLogSeq, companyEventLogSeq),
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
        
        if event.ephemeralType == .typingStatus {
            event.typingStatus = getTypingStatus(from: eventJSON)
        } else if event.eventType == .switchChatToSRS {
            event.switchToSRSClassification = getSwitchChatToSRSIntent(from: eventJSON)
        } else {
            event.chatMessage = event.makeChatMessage(from: eventJSON)
        }
        
        return event
    }
}

// MARK:- Event Parsing Utilities

extension Event {
    
    // MARK: Class Methods
    
    fileprivate class func getEventTypeAndContent(from json: [String : Any],
                                                  eventType originalEventType: EventType,
                                                  ephemeralType: EphemeralEventType) -> (EventType, [String : Any]?) {
        var eventType = originalEventType
        var eventJSONString = json[JSONKey.eventJSON.rawValue] as? String
        
        // All actions & updates should be considered chat messages.
        if eventType == EventType.srsAction ||
            (ephemeralType == EphemeralEventType.eventStatus && eventType == .none) {
            eventType = .srsResponse
        }
        
        // Echo are messages, but the content is nested differently
        if eventType == EventType.srsEcho,
            let tempJSON = eventJSONString?.toJSONObject(),
            let echoJSONString = tempJSON.string(for: JSONKey.echo.rawValue) {
            eventType = .srsResponse
            eventJSONString = echoJSONString
        }
        
        let eventJSON = eventJSONString?.toJSONObject()
        
        return (eventType, eventJSON)
    }
    
    fileprivate class func getTypingStatus(from json: [String : Any]?) -> Bool? {
        guard let json = json,
            let typingStatus = json.bool(for: JSONKey.isTyping.rawValue)  else {
                return nil
        }
        return typingStatus
    }
    
    fileprivate class func getSwitchChatToSRSIntent(from json: Any?) -> String? {
        guard let json = json as? [String : Any] else {
            return nil
        }
        return json.string(for: JSONKey.intent.rawValue)
    }
    
    // MARK: Instance Methods
    
    fileprivate func getTextMessageText(from json: [String : Any]?) -> String? {
        return json?.string(for: JSONKey.text.rawValue)
    }
    
    fileprivate func getChatMessageImageFromPictureMessage(_ json: [String : Any]?) -> ChatMessageImage? {
        guard let json = json,
            let fileBucket = json.string(for: JSONKey.fileBucket.rawValue),
            let fileSecret = json.string(for: JSONKey.fileSecret.rawValue),
            let mimeType = json.string(for: JSONKey.mimeType.rawValue),
            let width = json.int(for: JSONKey.picWidth.rawValue),
            let height = json.int(for: JSONKey.picHeight.rawValue) else {
                return nil
        }
        
        let imageSuffix = mimeType.components(separatedBy: "/").last ?? "jpg"
        let urlString = "https://\(fileBucket).s3.amazonaws.com/customer/\(customerId)/company/\(companyId)/\(fileSecret)-\(width)x\(height).\(imageSuffix)"
        guard let imageURL = URL(string: urlString) else {
            return nil
        }
        
        return ChatMessageImage(url: imageURL,
                                width: CGFloat(width),
                                height: CGFloat(height))
    }
}

// MARK:- Chat Message

extension Event {
    
    func makeChatMessage(from json: [String : Any]?) -> ChatMessage? {
        guard let json = json else {
            return nil
        }
        
        let metadata = makeMetadata()
        switch eventType {
        case .textMessage:
            let text = getTextMessageText(from: json)
            return ChatMessage(text: text,
                               attachment: nil,
                               quickReplies: nil,
                               metadata: metadata)
            
        case .pictureMessage:
            if let image = getChatMessageImageFromPictureMessage(json) {
            let attachment = ChatMessageAttachment(content: image)
                return ChatMessage(text: nil,
                                   attachment: attachment,
                                   quickReplies: nil,
                                   metadata: metadata)
            }
            break
            
        default:
            return ChatMessage.fromJSON(json, with: metadata)
        }
        return nil
    }
}
