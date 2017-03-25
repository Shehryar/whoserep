//
//  ChatComponentViewMessageCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/24/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ChatComponentViewMessageCell: ChatMessageCell {
    
    override var message: ChatMessage? {
        didSet {
            cardView.component = message?.attachment?.template
            setNeedsLayout()
        }
    }
    
    let cardView = ComponentCardView()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        attachmentView = cardView
    }
    
    deinit {
        cardView.interactionHandler = nil
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cardView.component = nil
    }
}
