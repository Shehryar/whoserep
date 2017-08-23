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
    let _quickReplies: [String : [QuickReply]]?
    var quickReplies: [QuickReply]? {
        guard let _quickReplies = _quickReplies else {
            return nil
        }
        
        if let attachmentValue = attachment?.currentValue as? String,
            let attachmentQuickReplies = _quickReplies[attachmentValue] {
            return attachmentQuickReplies
        }
        
        return _quickReplies.first?.value
    }
    let metadata: EventMetadata
   
    // MARK: Init
    
    init?(text: String?,
          attachment: ChatMessageAttachment?,
          quickReplies: [String : [QuickReply]]?,
          metadata: EventMetadata) {
        guard text != nil || attachment != nil || quickReplies != nil else {
            return nil
        }
        
        self.text = text
        self.attachment = attachment
        self._quickReplies = quickReplies != nil && !quickReplies!.isEmpty ? quickReplies : nil
        self.metadata = metadata
        super.init()
    }
    
    // MARK: Updates
    
    func getAutoSelectQuickReply() -> QuickReply? {
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
        
        if jsonIsLikelyLegacy(messageJSON), let legacyMessage = fromLegacySRSJSON(messageJSON, with: metadata) {
            return legacyMessage
        }
        
        let text = messageJSON.string(for: JSONKey.text.rawValue)
        let attachment = ChatMessageAttachment.fromJSON(messageJSON[JSONKey.attachment.rawValue])
        
        var quickRepliesDictionary: [String : [QuickReply]]? = [String : [QuickReply]]()
        if let quickRepliesJSONDict = messageJSON[JSONKey.quickReplies.rawValue] as? [String : [[String : Any]]] {
            for (pageId, buttonsJSON) in quickRepliesJSONDict {
                var quickReplies = [QuickReply]()
                for buttonJSON in buttonsJSON {
                    if let quickReply = QuickReply.fromJSON(buttonJSON) {
                        quickReplies.append(quickReply)
                    }
                }
                if quickReplies.count > 0 {
                    quickRepliesDictionary?[pageId] = quickReplies
                }
            }
        }
        if (quickRepliesDictionary ?? [String : [QuickReply]]()).isEmpty {
            quickRepliesDictionary = nil
        }

        return ChatMessage(text: text, attachment: attachment, quickReplies: quickRepliesDictionary, metadata: metadata)
    }
}

