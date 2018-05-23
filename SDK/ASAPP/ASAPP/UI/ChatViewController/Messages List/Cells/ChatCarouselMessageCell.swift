//
//  ChatCarouselMessageCell.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 5/17/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

protocol ChatCarouselMessageCellDelegate: class {
    func chatCarouselMessageCell(_ cell: ChatCarouselMessageCell,
                                 didChangeCurrentPage page: Int,
                                 message: ChatMessage)
}

class ChatCarouselMessageCell: ChatMessageCell {
    weak var carouselDelegate: ChatCarouselMessageCellDelegate?
    
    private let carouselView = ChatCarouselView()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        carouselView.interactionHandler = self
        carouselView.contentHandler = self
        carouselView.delegate = self
        attachmentView = carouselView
    }
    
    override func update(_ message: ChatMessage?, showTransientButtons: Bool) {
        self.message = message
        
        carouselView.update(for: message?.attachment?.carousel)
        let topLevelButtons = message?.buttons ?? []
        let predicate: ((QuickReply) -> Bool) = showTransientButtons ? { _ in return true } : { !$0.isTransient }
        carouselView.updateCardButtons(message?.attachment?.carousel?.elements.map { ($0.buttons?.filter(predicate) ?? []) + topLevelButtons })
        
        updateFrames()
    }
    
    func showPage(_ page: Int) {
        carouselView.showPage(page)
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        carouselView.update(for: nil)
    }
}

extension ChatCarouselMessageCell: InteractionHandler {
    func didTapButtonView(_ buttonView: ButtonView, with buttonItem: ButtonItem) {
        guard let message = message else {
            return
        }
        
        delegate?.chatMessageCell(self, didTap: buttonItem, from: message)
    }
}

extension ChatCarouselMessageCell: ComponentViewContentHandler {
    func componentView(_ componentView: ComponentView, didUpdateContent value: Any?, requiresLayoutUpdate: Bool) {
        if requiresLayoutUpdate {
            updateFrames()
            if let message = message {
                delegate?.chatMessageCell(self, didChangeHeightWith: message)
            }
        }
    }
}

extension ChatCarouselMessageCell: ChatCarouselViewDelegate {
    func chatCarouselView(_ view: ChatCarouselView, didChangeCurrentPage page: Int) {
        guard let message = message else {
            return
        }
        
        carouselDelegate?.chatCarouselMessageCell(self, didChangeCurrentPage: page, message: message)
    }
    
    func chatCarouselView(_ view: ChatCarouselView, didTapButtonWith action: Action) {
        delegate?.chatMessageCell(self, didTapButtonWith: action)
    }
}
