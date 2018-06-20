//
//  ChatComponentViewMessageCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/24/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ChatComponentViewMessageCell: ChatMessageCell {
    var shouldAnimate: Bool = false {
        didSet {
            cardView.shouldAnimate = shouldAnimate
        }
    }
    
    override var message: ChatMessage? {
        didSet {
            cardView.component = message?.attachment?.template
            cardView.message = message
            setNeedsLayout()
        }
    }
    
    let cardView = ComponentMessageCardView()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        cardView.interactionHandler = self
        cardView.contentHandler = self
        attachmentView = cardView
        cardView.delegate = self
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cardView.component = nil
        cardView.prepareForReuse()
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

extension ChatComponentViewMessageCell: ComponentViewContentHandler {
    
    func componentView(_ componentView: ComponentView,
                       didUpdateContent value: Any?,
                       requiresLayoutUpdate: Bool) {
        if requiresLayoutUpdate {
            updateFrames()
        }
    }
}
