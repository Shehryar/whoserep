//
//  ChatMessage.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/9/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- Chat Message

class ChatMessage: NSObject {
    
    // MARK: Message Content
    
    let text: String?
    let attachment: ChatMessageAttachment?
    let _quickReplies: [QuickReply]?
    var quickReplies: [QuickReply]? {
        return attachment?.quickReplies ?? _quickReplies
    }
    
    // MARK: Metadata
    
    let isReply: Bool
    let isAutomatedMessage: Bool
    let eventId: Int
    let eventType: EventType
    let issueId: Int
    let classification: String?
    fileprivate(set) var sendTime: Date

    // MARK: Init
    
    init(text: String?,
         attachment: ChatMessageAttachment?,
         quickReplies: [QuickReply]?,
         isReply: Bool,
         sendTime: Date,
         eventId: Int,
         eventType: EventType,
         issueId: Int,
         classification: String? = nil,
         isAutomatedMessage: Bool = false) {
        
        self.text = text
        self.attachment = attachment
        if let quickReplies = quickReplies, quickReplies.count > 0 {
            self._quickReplies = quickReplies
        } else {
            self._quickReplies = nil
        }
        self.isReply = isReply
        self.sendTime = sendTime
        self.eventId = eventId
        self.eventType = eventType
        self.issueId = issueId
        self.isAutomatedMessage = isAutomatedMessage
        self.classification = classification
        super.init()
    }
    
    // MARK:- Updates
    
    func updateSendTime(toMatch message: ChatMessage) {
        sendTime = message.sendTime
    }
    
    func getSendTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = sendTime.dateFormatForMostRecent()
        return dateFormatter.string(from: sendTime)
    }
    
    func getAutoSelectQuickReply() -> QuickReply? {
        guard let quickReplies = _quickReplies else {
            return nil
        }
        
        for quickReply in quickReplies {
            if quickReply.isAutoSelect {
                return quickReply
            }
        }
        return nil
    }
}

// MARK:- Parsing

extension ChatMessage {
    
    enum JSONKey: String {
        case attachment = "attachment"
        case clientMessage = "ClientMessage"
        case quickReplies = "quickReplies"
        case text = "text"
    }
    
    static func parseContent(from json: [String : Any]?) -> (String?, ChatMessageAttachment?, [QuickReply]?) {
        guard let json = json else {
            return (nil, nil, nil)
        }
        let messageJSON = json[JSONKey.clientMessage.rawValue] as? [String : Any] ?? json
        
        let text = messageJSON.string(for: JSONKey.text.rawValue)
        let attachment: ChatMessageAttachment? = ChatMessageAttachment.fromJSON(messageJSON[JSONKey.attachment.rawValue])
        var quickReplies: [QuickReply]?
        
        if let quickRepliesJSON = messageJSON[JSONKey.quickReplies.rawValue] as? [[String : Any]]   {
            quickReplies = [QuickReply]()
            for quickReplyJSON in quickRepliesJSON {
                if let quickReply = QuickReply.fromJSON(quickReplyJSON) {
                    quickReplies?.append(quickReply)
                }
            }
        }
        
        return (text, attachment, quickReplies)
    }
    
    
    // MARK: Event 
    
    static func fromEvent(_ event: Event?) -> ChatMessage? {
        guard let event = event else {
            return nil
        }
        
        var text: String?
        var attachment: ChatMessageAttachment?
        var quickReplies: [QuickReply]?
        var classification: String?
        
        switch event.eventType {
        case .textMessage:
            text = event.textMessage?.text
            break
            
        case .pictureMessage:
            if let pictureMessage = event.pictureMessage {
                attachment = ChatMessageAttachment(content: pictureMessage)
            }
            break
            
        default:
            text = event.srsResponse?.messageText
            if let itemList = event.srsResponse?.itemList {
                attachment = ChatMessageAttachment(content: itemList)
            } else if let itemCarousel = event.srsResponse?.itemCarousel {
                attachment = ChatMessageAttachment(content: itemCarousel)
            }
            quickReplies = SRSButtonItem.getQuickReplies(from: event.srsResponse?.buttonItems)
            classification = event.srsResponse?.classification
            break
        }
        
        if (text == nil && attachment == nil && quickReplies == nil) {
            (text, attachment, quickReplies) = parseContent(from: event.eventJSON)
        }
        
        // Do not return a message without any sort of content
        if text != nil || attachment != nil || quickReplies != nil {
            
            let eventId: Int
            if event.ephemeralType == .eventStatus, let parentId = event.parentEventLogSeq {
                eventId = parentId
            } else {
                eventId = event.eventLogSeq
            }
            
            return ChatMessage(text: text,
                               attachment: attachment,
                               quickReplies: quickReplies,
                               isReply: event.isReply,
                               sendTime: event.eventDate,
                               eventId: eventId,
                               eventType: event.eventType,
                               issueId: event.issueId,
                               classification: classification,
                               isAutomatedMessage: event.srsResponse != nil)
        }
        return nil
    }
}

