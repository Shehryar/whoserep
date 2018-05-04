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
    let notification: ChatMessageNotification?
    let attachment: ChatMessageAttachment?
    let quickReplies: [QuickReply]?
    let messageActions: [QuickReply]?
    let userCanTypeResponse: Bool?
    let suppressNewQuestionConfirmation: Bool
    let metadata: EventMetadata
    
    var hasQuickReplies: Bool {
        return !(quickReplies?.isEmpty ?? true)
    }
    
    var hasMessageActions: Bool {
        return !(messageActions?.isEmpty ?? true)
    }
   
    // MARK: Init
    
    init?(text: String?,
          notification: ChatMessageNotification?,
          attachment: ChatMessageAttachment?,
          quickReplies: [String: [QuickReply]]?,
          userCanTypeResponse: Bool? = nil,
          suppressNewQuestionConfirmation: Bool = false,
          metadata: EventMetadata) {
        guard (text != nil && !(text?.isEmpty == true)) || attachment != nil || quickReplies != nil else {
            return nil
        }
        
        self.text = text
        self.notification = notification
        self.attachment = attachment
        
        var quickRepliesArray: [QuickReply]?
        
        if let attachmentValue = attachment?.currentValue as? String,
           let attachmentQuickReplies = quickReplies?[attachmentValue] {
            quickRepliesArray = attachmentQuickReplies
        } else {
            quickRepliesArray = quickReplies?.first?.value
        }
        
        let (filteredMessageActions, filteredQuickReplies) = quickRepliesArray?.separate { quickReply -> Bool in
            return quickReply.action.isMessageAction
        } ?? ([], [])
        
        self.quickReplies = filteredQuickReplies.isEmpty ? nil : filteredQuickReplies
        self.messageActions = filteredMessageActions.isEmpty ? nil : filteredMessageActions
        
        self.metadata = metadata
        self.userCanTypeResponse = userCanTypeResponse
        self.suppressNewQuestionConfirmation = suppressNewQuestionConfirmation
        
        super.init()
    }
}

// MARK: - Parsing

extension ChatMessage {
    
    enum JSONKey: String {
        case attachment
        case clientMessage = "ClientMessage"
        case notification
        case quickReplies
        case suppressNewQuestionConfirmation
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
        
        let notification: ChatMessageNotification?
        if let notificationDict = messageJSON[JSONKey.notification.rawValue] as? [String: Any] {
            notification = ChatMessageNotification.fromDict(notificationDict)
        } else {
            notification = nil
        }
        
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
        
        let userCanTypeResponse = json.bool(for: JSONKey.userCanTypeResponse.rawValue)
        
        let suppressNewQuestionConfirmation = json.bool(for: JSONKey.suppressNewQuestionConfirmation.rawValue) ?? false

        return ChatMessage(text: text, notification: notification, attachment: attachment, quickReplies: quickRepliesDictionary, userCanTypeResponse: userCanTypeResponse, suppressNewQuestionConfirmation: suppressNewQuestionConfirmation, metadata: metadata)
    }
}
