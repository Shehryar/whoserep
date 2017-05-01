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
    
    let text: String?
    let attachment: ChatMessageAttachment?
    let _quickReplies: [QuickReply]?
    var quickReplies: [QuickReply]? {
        return attachment?.quickReplies ?? _quickReplies
    }
    let metadata: EventMetadata
   
    // MARK: Init
    
    init?(text: String?,
          attachment: ChatMessageAttachment?,
          quickReplies: [QuickReply]?,
          metadata: EventMetadata) {
        guard text != nil || attachment != nil || quickReplies != nil else {
            return nil
        }
        
        self.text = text
        self.attachment = attachment
        self._quickReplies = quickReplies != nil && quickReplies!.count > 0 ? quickReplies : nil
        self.metadata = metadata
        super.init()
    }
    
    // MARK: Updates
    
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
    
    class func fromJSON(_ json: Any?, with metadata: EventMetadata) -> ChatMessage? {
        guard let json = json as? [String : Any] else {
            return nil
        }
        let messageJSON = json.jsonObject(for: JSONKey.clientMessage.rawValue) ?? json
        
        let text = messageJSON.string(for: JSONKey.text.rawValue)
        let attachment = ChatMessageAttachment.fromJSON(messageJSON[JSONKey.attachment.rawValue])
        let quickReplies = QuickReply.arrayFromJSON(messageJSON[JSONKey.quickReplies.rawValue])
       
        return ChatMessage(text: text, attachment: attachment, quickReplies: quickReplies, metadata: metadata)
    }
}

