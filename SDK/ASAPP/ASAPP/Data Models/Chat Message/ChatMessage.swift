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
          quickReplies: [QuickReply]?,
          userCanTypeResponse: Bool? = nil,
          suppressNewQuestionConfirmation: Bool = false,
          metadata: EventMetadata) {
        guard (text != nil && !(text?.isEmpty == true)) || attachment != nil || quickReplies != nil else {
            return nil
        }
        
        self.text = text
        self.notification = notification
        self.attachment = attachment
        
        let (filteredMessageActions, filteredQuickReplies) = quickReplies?.separate { quickReply -> Bool in
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
    
    class func fromJSON(_ dict: Any?, with metadata: EventMetadata) -> ChatMessage? {
        guard let dict = dict as? [String: Any] else {
            return nil
        }
        
        let messageDict = dict.jsonObject(for: JSONKey.clientMessage.rawValue) ?? dict
        
        if jsonIsLikelyLegacy(messageDict),
           let legacyMessage = fromLegacySRSJSON(messageDict, with: metadata) {
            return legacyMessage
        }
        
        let text = messageDict.string(for: JSONKey.text.rawValue)
        
        let notification: ChatMessageNotification?
        if let notificationDict = messageDict[JSONKey.notification.rawValue] as? [String: Any] {
            notification = ChatMessageNotification.fromDict(notificationDict)
        } else {
            notification = nil
        }
        
        let attachment = ChatMessageAttachment.fromJSON(messageDict[JSONKey.attachment.rawValue])
        
        var quickReplies: [QuickReply]?
        if let quickReplyDicts = messageDict.arrayOfDictionaries(for: JSONKey.quickReplies.rawValue) {
            quickReplies = QuickReply.arrayFromJSON(quickReplyDicts)
        }
        
        // fall back to parsing a dictionary of arrays of quick replies
        if quickReplies?.isEmpty ?? true,
           let quickRepliesDict = messageDict[JSONKey.quickReplies.rawValue] as? [String: [[String: Any]]] {
            quickReplies = QuickReply.arrayFromJSON(quickRepliesDict.first?.value)
        }
        
        let userCanTypeResponse = dict.bool(for: JSONKey.userCanTypeResponse.rawValue)
        
        let suppressNewQuestionConfirmation = dict.bool(for: JSONKey.suppressNewQuestionConfirmation.rawValue) ?? false

        return ChatMessage(text: text, notification: notification, attachment: attachment, quickReplies: quickReplies, userCanTypeResponse: userCanTypeResponse, suppressNewQuestionConfirmation: suppressNewQuestionConfirmation, metadata: metadata)
    }
}
