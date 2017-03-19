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
