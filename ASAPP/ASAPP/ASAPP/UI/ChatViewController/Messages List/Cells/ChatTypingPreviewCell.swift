//
//  ChatTypingPreviewCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/31/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatTypingPreviewCell: ChatTextMessageCell {

    // MARK: Styling
    
    override func updateFontsAndColors() {
        super.updateFontsAndColors()
        
        if isReply {
            textMessageLabel.textColor = styles.replyMessageTextColor.withAlphaComponent(0.6)
        } else {
            textMessageLabel.textColor = styles.messageTextColor.withAlphaComponent(0.6)
        }
    }
}
