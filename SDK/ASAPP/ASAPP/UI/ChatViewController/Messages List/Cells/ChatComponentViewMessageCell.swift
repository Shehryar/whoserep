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
        
        cardView.interactionHandler = self
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

extension ChatComponentViewMessageCell: InteractionHandler {
    
    func didTapButtonView(_ buttonView: ButtonView, with buttonItem: ButtonItem) {
        guard let message = message else {
            return
        }
        
        delegate?.chatMessageCell(self, didTap: buttonItem, from: message)
    }
}
