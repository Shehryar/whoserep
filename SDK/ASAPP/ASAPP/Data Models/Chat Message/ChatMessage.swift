//
//  ChatMessage.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/9/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK: - Chat Message

class ChatMessage: NSObject {
    
    let text: String?
    let attachment: ChatMessageAttachment?
    let quickReplies: [QuickReply]?
    let userCanTypeResponse: Bool
    let metadata: EventMetadata
    
    var hasQuickReplies: Bool {
        return !(quickReplies?.isEmpty ?? true)
    }
   
    // MARK: Init
    
    init?(text: String?,
          attachment: ChatMessageAttachment?,
          quickReplies: [String: [QuickReply]]?,
          userCanTypeResponse: Bool = false,
          metadata: EventMetadata) {
        guard text != nil || attachment != nil || quickReplies != nil else {
            return nil
        }
        
        self.text = text
        self.attachment = attachment
        
        if let attachmentValue = attachment?.currentValue as? String,
           let attachmentQuickReplies = quickReplies?[attachmentValue] {
            self.quickReplies = attachmentQuickReplies
        } else {
            self.quickReplies = quickReplies?.first?.value
        }
        
        self.metadata = metadata
        self.userCanTypeResponse = userCanTypeResponse
        
        super.init()
    }
}

// MARK: - Parsing

extension ChatMessage {
    
    enum JSONKey: String {
        case attachment
        case clientMessage = "ClientMessage"
        case quickReplies
        case text
        case userCanTypeResponse
    }
    
    class func fromJSON(_ json: Any?, with metadata: EventMetadata) -> ChatMessage? {
        guard let json = json as? [String: Any] else {
            return nil
        }
        
        let messageJSON = json.jsonObject(for: JSONKey.clientMessage.rawValue) ?? json
        
        if jsonIsLikelyLegacy(messageJSON), let legacyMessage = fromLegacySRSJSON(messageJSON, with: metadata) {
            return legacyMessage
        }
        
        let text = messageJSON.string(for: JSONKey.text.rawValue)
        let attachment = ChatMessageAttachment.fromJSON(messageJSON[JSONKey.attachment.rawValue])
        
        var quickRepliesDictionary: [String: [QuickReply]]? = [String: [QuickReply]]()
        if let quickRepliesJSONDict = messageJSON[JSONKey.quickReplies.rawValue] as? [String: [[String: Any]]] {
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
        
        if (quickRepliesDictionary ?? [String: [QuickReply]]()).isEmpty {
            quickRepliesDictionary = nil
        }
        
        let userCanTypeResponse = json.bool(for: JSONKey.userCanTypeResponse.rawValue) ?? false

        return ChatMessage(text: text, attachment: attachment, quickReplies: quickRepliesDictionary, userCanTypeResponse: userCanTypeResponse, metadata: metadata)
    }
}
