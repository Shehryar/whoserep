//
//  Event+JSON.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK: - JSON Keys

extension Event {
    
    enum JSONKey: String {
        // Base Event
        case companyEventLogSeq = "CompanyEventLogSeq"
        case companyId = "CompanyId"
        case customerEventLogSeq = "CustomerEventLogSeq"
        case customerId = "CustomerId"
        case ephemeralType = "EphemeralType"
        case eventFlags = "EventFlags"
        case eventJSON = "EventJSON"
        case eventTime = "EventTime"
        case eventType = "EventType"
        case issueId = "IssueId"
        case parentEventLogSeq = "parentEventLogSeq"
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
    
    class func fromJSON(_ json: [String: Any]) -> Event? {
        let originalEventType = EventType.from(json[JSONKey.eventType.rawValue])
        let ephemeralType = EphemeralEventType.from(json[JSONKey.ephemeralType.rawValue])
        
        // Required Properties
        guard let issueId = json[JSONKey.issueId.rawValue] as? Int,
              let companyId = json[JSONKey.companyId.rawValue] as? Int,
              let customerId = json[JSONKey.customerId.rawValue] as? Int,
              let repId = json[JSONKey.repId.rawValue] as? Int,
              let eventTimeInMicroSeconds = json[JSONKey.eventTime.rawValue] as? Double,
              let eventFlags = json[JSONKey.eventFlags.rawValue] as? Int,
              let customerEventLogSeq = json[JSONKey.customerEventLogSeq.rawValue] as? Int,
              let companyEventLogSeq = json[JSONKey.companyEventLogSeq.rawValue] as? Int else {
            return nil
        }
        
        let (eventType, eventJSON) = getEventTypeAndContent(
            from: json,
            eventType: originalEventType,
            ephemeralType: ephemeralType)
        
        let parentEventLogSeq = json.int(for: JSONKey.parentEventLogSeq.rawValue) ??
            eventJSON?.int(for: JSONKey.parentEventLogSeq.rawValue)
        
        let event = Event(
            eventId: max(customerEventLogSeq, companyEventLogSeq),
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
        
        if event.ephemeralType == .partnerEvent {
            event.partnerEvent = getPartnerEvent(from: eventJSON)
        } else if event.ephemeralType == .continue {
            event.continuePrompt = getContinuePrompt(from: eventJSON)
        } else if event.ephemeralType == .typingStatus {
            event.typingStatus = getTypingStatus(from: eventJSON)
        } else if event.ephemeralType == .notificationBanner {
            event.notification = getNotification(from: eventJSON)
        } else if event.eventType == .switchChatToSRS {
            event.switchToSRSClassification = getSwitchChatToSRSIntent(from: eventJSON)
        } else {
            event.chatMessage = event.makeChatMessage(from: eventJSON)
        }
        
        return event
    }
}

// MARK: - Event Parsing Utilities

extension Event {
    
    // MARK: Class Methods
    
    private class func getEventTypeAndContent(from json: [String: Any], eventType originalEventType: EventType, ephemeralType: EphemeralEventType) -> (EventType, [String: Any]?) {
        var eventType = originalEventType
        let eventJSONString = json[JSONKey.eventJSON.rawValue] as? String
        
        // All actions & updates should be considered chat messages.
        if eventType == EventType.srsAction {
            eventType = .srsResponse
        }
        
        let eventJSON = eventJSONString?.toJSONObject()
        
        return (eventType, eventJSON)
    }
    
    private class func getPartnerEvent(from dict: [String: Any]?) -> PartnerEvent? {
        return PartnerEvent.fromDict(dict ?? [:])
    }
    
    private class func getTypingStatus(from dict: [String: Any]?) -> Bool? {
        return dict?.bool(for: JSONKey.isTyping.rawValue)
    }
    
    private class func getSwitchChatToSRSIntent(from dict: [String: Any]?) -> String? {
        return dict?.string(for: JSONKey.intent.rawValue)
    }
    
    private class func getContinuePrompt(from dict: [String: Any]?) -> ContinuePrompt? {
        return ContinuePrompt.fromDict(dict ?? [:])
    }
    
    private class func getNotification(from dict: [String: Any]?) -> ChatNotification? {
        return ChatNotification.fromDict(dict ?? [:])
    }
    
    // MARK: Instance Methods
    
    private func getTextMessageText(from dict: [String: Any]?) -> String? {
        return dict?.string(for: JSONKey.text.rawValue)
    }
    
    private func getChatMessageImageFromPictureMessage(_ json: [String: Any]?) -> ChatMessageImage? {
        guard let json = json,
              let fileBucket = json.string(for: JSONKey.fileBucket.rawValue),
              let fileSecret = json.string(for: JSONKey.fileSecret.rawValue),
              let mimeType = json.string(for: JSONKey.mimeType.rawValue),
              let imageSuffix = mimeType.components(separatedBy: "/").last,
              let width = json.int(for: JSONKey.picWidth.rawValue),
              let height = json.int(for: JSONKey.picHeight.rawValue) else {
            return nil
        }
        
        let urlString = "https://\(fileBucket).s3.amazonaws.com/customer/\(customerId)/company/\(companyId)/\(fileSecret)-\(width)x\(height).\(imageSuffix)"
        guard let imageURL = URL(string: urlString) else {
            return nil
        }
        
        return ChatMessageImage(url: imageURL,
                                width: CGFloat(width),
                                height: CGFloat(height))
    }
}

// MARK: - Chat Message

extension Event {
    
    func makeChatMessage(from json: [String: Any]?) -> ChatMessage? {
        guard let json = json else {
            return nil
        }
        
        let metadata = makeMetadata()
        switch eventType {
        case .textMessage:
            let text = getTextMessageText(from: json)
            return ChatMessage(text: text,
                               attachment: nil,
                               buttons: nil,
                               quickReplies: nil,
                               metadata: metadata)
            
        case .pictureMessage:
            if let image = getChatMessageImageFromPictureMessage(json) {
                let attachment = ChatMessageAttachment(content: image)
                return ChatMessage(text: nil,
                                   attachment: attachment,
                                   buttons: nil,
                                   quickReplies: nil,
                                   metadata: metadata)
            }
            
        default:
            return ChatMessage.fromJSON(json, with: metadata)
        }
        return nil
    }
}
