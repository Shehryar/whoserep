//
//  ChatMessageAttachmentCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ChatMessageAttachmentCell: ChatMessageCell {

    override var message: ChatMessage? {
        didSet {
            attachmentView = getView(for: message)
        }
    }

    func getView(for message: ChatMessage?) -> UIView? {
        guard let message = message else {
            return nil
        }
        
        return  nil
    }
}

// MARK:- Reuse Identifierss

extension ChatMessageAttachmentCell {
    
    class func getAllReuseIds() -> [String] {
        var reuseIds = [String]()
        for attachmentType in ChatMessageAttachment.AttachmentType.all {
            let reuseId = getReuseId(forMessageAttachmentType: attachmentType)
            reuseIds.append(reuseId)
        }
        return reuseIds
    }
    
    class func getReuseId(forMessageAttachmentType type: ChatMessageAttachment.AttachmentType) -> String {
        return "MessageCellReuseId_" + type.rawValue
    }
    
    class func getReuseId(forMessageAttachment messageAttachment: ChatMessageAttachment?) -> String {
        guard let messageAttachment = messageAttachment else {
            return getReuseId(forMessageAttachmentType: .none)
        }
        return getReuseId(forMessageAttachmentType: messageAttachment.type)
    }
    
    class func getReuseId(forMessage message: ChatMessage) -> String {
        return getReuseId(forMessageAttachment: message.attachment)
    }
}
