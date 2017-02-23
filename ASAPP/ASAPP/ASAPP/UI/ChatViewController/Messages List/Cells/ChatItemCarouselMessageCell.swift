//
//  ChatItemCarouselMessageCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ChatItemCarouselMessageCell: ChatMessageCell {

    override var event: Event? {
        didSet {
            itemCarouselView.itemCarousel = event?.srsResponse?.itemCarousel
            setNeedsLayout()
        }
    }
    
    let itemCarouselView = SRSItemCarouselView()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        itemCarouselView.delegate = self
        attachmentView = itemCarouselView
    }
    
    deinit {
        itemCarouselView.delegate = nil
    }

    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        itemCarouselView.event = nil
    }
    
    // MARK: Layout
    
    func getMaxPageWidthThatFits(_ size: CGSize) -> CGFloat {
        return floor(size.width * 0.7)
    }
    
    override func getAttachmentViewSizeThatFits(_ size: CGSize) -> CGSize {
        let maxPageWidth = getMaxPageWidthThatFits(size)
        return itemCarouselView.sizeThatFits(size, maximumPageWidth: maxPageWidth)
    }
    
    override func updateFrames() {
        itemCarouselView.maxPageWidth = getMaxPageWidthThatFits(bounds.size)
        super.updateFrames()
    }
}

// MARK:- SRSItemCarouselViewDelegate

extension ChatItemCarouselMessageCell: SRSItemCarouselViewDelegate {
    
    func itemCarouselView(_ itemCarouselView: SRSItemCarouselView, didScrollToPage page: Int) {
        delegate?.chatMessageCell(self, withItemCarouselView: itemCarouselView, didScrollToPage: page)
    }
    
    func itemCarouselView(_ itemCarouselView: SRSItemCarouselView, didSelectButtonItem buttonItem: SRSButtonItem) {
        delegate?.chatMessageCell(self, withItemCarouselView: itemCarouselView, didSelectButtonItem: buttonItem)
    }
}
