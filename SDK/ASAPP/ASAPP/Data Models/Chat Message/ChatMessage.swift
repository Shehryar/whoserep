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
    let quickReplies: [SRSButtonItem]?
    
    // MARK: Metadata
    
    let isReply: Bool
    let isAutomatedMessage: Bool
    let eventId: Int
    let eventType: EventType
    let issueId: Int
    fileprivate(set) var sendTime: Date
    
    // MARK: Init
    
    init(text: String?,
         attachment: Any?,
         quickReplies: [SRSButtonItem]?,
         isReply: Bool,
         sendTime: Date,
         eventId: Int,
         eventType: EventType,
         issueId: Int,
         isAutomatedMessage: Bool = false) {
        
        self.text = text
        if let attachment = attachment {
            if let messageAttachment = attachment as? ChatMessageAttachment {
                self.attachment = messageAttachment
            } else {
                self.attachment = ChatMessageAttachment(content: attachment)
            }
        } else {
            self.attachment = nil
        }
        if let quickReplies = quickReplies, quickReplies.count > 0 {
            self.quickReplies = quickReplies
        } else {
            self.quickReplies = nil
        }
        self.isReply = isReply
        self.sendTime = sendTime
        self.eventId = eventId
        self.eventType = eventType
        self.issueId = issueId
        self.isAutomatedMessage = isAutomatedMessage
        
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
    
    func getAutoSelectQuickReply() -> SRSButtonItem? {
        guard let quickReplies = quickReplies else {
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
    
    /// Returns text, attachment, quickReplies
    static func parseContent(from json: [String : Any]?) -> (String?, Any?, [SRSButtonItem]?) {
        guard let json = json else {
            return (nil, nil, nil)
        }
        let messageJSON = json["ClientMessage"] as? [String : Any] ?? json
        
        
        let text = messageJSON["text"] as? String
        
        var attachment: Any?
        let attachmentJSON = messageJSON["attachment"] as? [String : Any]
        if let attachmentType = attachmentJSON?.string(for: "type"),
            let attachmentContent = attachmentJSON?["content"] as? [String : Any] {
            switch attachmentType {
            case "componentView":
                if let viewContainer = ComponentViewContainer.from(attachmentContent) {
                    attachment = viewContainer.root
                }
                break
                
            default:
                break
            }
        }
        
        var quickReplies = [SRSButtonItem]()
        if let quickRepliesJSON = (messageJSON["quick_replies"] ?? messageJSON["quickReplies"]) as? [[String : AnyObject]]   {
            for quickReplyJSON in quickRepliesJSON {
                if let button = SRSButtonItem.fromJSON(quickReplyJSON) {
                    quickReplies.append(button)
                }
            }
        }
        
        return (text, attachment as AnyObject?, quickReplies)
    }
    
    static func fromEvent(_ event: Event?) -> ChatMessage? {
        guard let event = event else {
            return nil
        }
        
        var text: String?
        var attachment: Any?
        var quickReplies: [SRSButtonItem]?
        
        switch event.eventType {
        case .textMessage:
            text = event.textMessage?.text
            break
            
        case .pictureMessage:
            attachment = event.pictureMessage
            break
            
        default:
            text = event.srsResponse?.messageText
            attachment = event.srsResponse?.itemList ?? event.srsResponse?.itemCarousel
            quickReplies = event.srsResponse?.buttonItems
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
                               isAutomatedMessage: event.srsResponse != nil)
        }
        return nil
    }
}

