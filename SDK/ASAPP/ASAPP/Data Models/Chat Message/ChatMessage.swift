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
    let buttons: [QuickReply]?
    let userCanTypeResponse: Bool?
    let suppressNewQuestionConfirmation: Bool
    let hideNewQuestionButton: Bool
    let metadata: EventMetadata
    
    var hasQuickReplies: Bool {
        return !(quickReplies?.isEmpty ?? true)
    }
    
    var hasButtons: Bool {
        return !(buttons?.isEmpty ?? true)
    }
   
    // MARK: Init
    
    init?(text: String?,
          notification: ChatMessageNotification?,
          attachment: ChatMessageAttachment?,
          buttons: [QuickReply]?,
          quickReplies: [QuickReply]?,
          userCanTypeResponse: Bool? = nil,
          suppressNewQuestionConfirmation: Bool = false,
          hideNewQuestionButton: Bool = false,
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
        
        let combinedButtons = filteredMessageActions.map {
            return QuickReply(title: $0.title, action: $0.action, icon: $0.icon, isTransient: true)
        } + (buttons ?? [])
        self.buttons = combinedButtons.isEmpty ? nil : combinedButtons.withoutDuplicates()
        
        self.metadata = metadata
        self.userCanTypeResponse = userCanTypeResponse
        self.suppressNewQuestionConfirmation = suppressNewQuestionConfirmation
        self.hideNewQuestionButton = hideNewQuestionButton
        
        super.init()
    }
}

// MARK: - Parsing

extension ChatMessage {
    
    enum JSONKey: String {
        case attachment
        case buttons
        case clientMessage = "ClientMessage"
        case hideNewQuestionButton
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
        
        var buttons: [QuickReply]?
        if let buttonDicts = messageDict.arrayOfDictionaries(for: JSONKey.buttons.rawValue) {
            buttons = QuickReply.arrayFromJSON(buttonDicts)
        }
        
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
        let hideNewQuestionButton = dict.bool(for: JSONKey.hideNewQuestionButton.rawValue) ?? false
        
        return ChatMessage(
            text: text,
            notification: notification,
            attachment: attachment,
            buttons: buttons,
            quickReplies: quickReplies,
            userCanTypeResponse: userCanTypeResponse,
            suppressNewQuestionConfirmation: suppressNewQuestionConfirmation,
            hideNewQuestionButton: hideNewQuestionButton,
            metadata: metadata)
    }
}
