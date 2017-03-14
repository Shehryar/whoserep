//
//  ChatMessage.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/9/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum ChatMessageType: String {
    case text           = "ChatMessageTypeText"
    case itemList       = "ChatMessageTypeItemList"
    case itemCarousel   = "ChatMessageTypeItemCarousel"
    case picture        = "ChatMessageTypePicture"
}

// MARK:- Chat Message

class ChatMessage: NSObject {
    
    // MARK: Message Content
    
    let type: ChatMessageType
    let text: String?
    let attachment: AnyObject?
    let quickReplies: [SRSButtonItem]?
    
    // MARK: Metadata
    
    let isReply: Bool
    let sendTime: Date
    let eventId: Int
    let isAutomatedMessage: Bool
    
    // MARK: Init
    
    init(text: String?,
         attachment: AnyObject?,
         quickReplies: [SRSButtonItem]?,
         isReply: Bool,
         sendTime: Date,
         eventId: Int,
         isAutomatedMessage: Bool = false) {
        
        self.text = text
        self.attachment = attachment
        self.quickReplies = quickReplies
        self.isReply = isReply
        self.sendTime = sendTime
        self.eventId = eventId
        self.isAutomatedMessage = isAutomatedMessage
        
        // Determine type based on content
        var type: ChatMessageType?
        if let attachment = attachment {
            if attachment.isKind(of: SRSItemList.self) {
                type = .itemList
            } else if attachment.isKind(of: SRSItemCarousel.self) {
                type = .itemCarousel
            } else if attachment.isKind(of: SRSImageItem.self) {
                type = .picture
            }
        }
        self.type = type ?? .text
        
        super.init()
    }
}

// MARK:- Parsing

extension ChatMessage {

    /// Returns text, attachment, quickReplies
    static func parseContent(from json: [String : AnyObject]?) -> (String?, AnyObject?, [SRSButtonItem]?) {
        guard let json = json else {
            return (nil, nil, nil)
        }
        
        let text = json["text"] as? String
        let attachmentJSON = json["attachment"] as? [String : AnyObject]
        let attachment = ComponentFactory.component(with: attachmentJSON)
        var quickReplies = [SRSButtonItem]()
        if let quickRepliesJSON = json["quick_replies"] as? [[String : AnyObject]] {
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
        var attachment: AnyObject?
        var quickReplies: [SRSButtonItem]?
        
        switch event.eventType {
        case .textMessage:
            text = event.textMessage?.text
            break
            
        case .pictureMessage:
            attachment = event.pictureMessage as AnyObject
            break
            
        default:
            text = event.srsResponse?.messageText
            attachment = event.srsResponse?.itemList ?? event.srsResponse?.itemCarousel
            quickReplies = event.srsResponse?.buttonItems
            break
        }
        
        if (text == nil && attachment == nil && quickReplies == nil) {
            (text, attachment, quickReplies) = parseContent(from: event.eventJSON)
            
            DebugLog.i("\n\n\n\n\n\n\nParsed \(text), \(attachment), \(quickReplies)\n\n\n\n")
        }
        
        // Do not return a message without any sort of content
        if text != nil || attachment != nil || quickReplies != nil {
            
            let sendTime = Date(timeIntervalSince1970: event.eventTime / 1000)
            return ChatMessage(text: text,
                               attachment: attachment,
                               quickReplies: quickReplies,
                               isReply: event.isReply,
                               sendTime: event.eventDate,
                               eventId: event.eventLogSeq,
                               isAutomatedMessage: event.srsResponse != nil)
        }
        return nil
    }
}

