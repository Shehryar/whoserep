//
//  ChatSRSItemListViewCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatSRSItemListViewCell: ChatTextMessageCell {
    
    var response: SRSResponse? {
        didSet {
            if let response = response {
                if let itemList = response.itemList {
                    messageText = itemList.title
                    
                    if response.displayContent {
                        itemListView.itemList = itemList
                    } else {
                        itemListView.itemList = nil
                    }
                    
                    itemCarouselView.itemCarousel = nil
                } else if let itemCarousel = response.itemCarousel {
                    messageText = itemCarousel.message
                    itemCarouselView.itemCarousel = itemCarousel
                    
                    itemListView.itemList = nil
                }
            } else {
                messageText = nil
                itemListView.itemList = nil
            }
            
            // Update Visibility
            switch displayStyle {
            case .itemCarousel:
                itemCarouselView.isHidden = false
                itemListView.isHidden = true
                break
                
            case .itemList:
                itemCarouselView.isHidden = true
                itemListView.isHidden = false
                break
                
            case .message:
                itemCarouselView.isHidden = true
                itemListView.isHidden = true
                break
            }
            
            setNeedsLayout()
        }
    }
    
    let itemListView = SRSItemListView()
    
    let itemCarouselView = SRSItemCarouselView()
    
    // MARK: Private Properties
    
    fileprivate enum DisplayStyle {
        case message
        case itemList
        case itemCarousel
    }
    
    fileprivate var displayStyle: DisplayStyle {
        guard let response = response else {
            return .message
        }
        
        if response.itemList != nil {
            return .itemList
        } else if response.itemCarousel != nil {
            return .itemCarousel
        }
        return .message
    }
    
    fileprivate var srsContentView: UIView? {
        switch displayStyle {
        case .itemCarousel: return itemCarouselView
        case .itemList: return itemListView
        case .message: return nil
        }
    }
    
    fileprivate let srsContentViewMargin: CGFloat = 10.0
    
    // MARK: Init
    
    override func commonInit() {
        isReply = true
        super.commonInit()
        
        contentView.addSubview(itemListView)
        contentView.addSubview(itemCarouselView)
    }
    
    // MARK: Styling
    
    override func updateFontsAndColors() {
        super.updateFontsAndColors()
        itemListView.applyStyles(styles)
        itemCarouselView.applyStyles(styles)
        setNeedsLayout()
    }
    
    // MARK: Layout
    
    func srsContentViewSizeThatFits(_ size: CGSize) -> CGSize {
        let maxWidth = size.width - contentInset.left - contentInset.right
        let insetSize = CGSize(width: maxWidth, height: 0)
        if displayStyle == .itemCarousel {
            let maxPageWidth = maxBubbleWidthForBoundsSize(size)
            return itemCarouselView.sizeThatFits(size, maximumPageWidth: maxPageWidth)
        }
        if let srsContentView = srsContentView {
            return srsContentView.sizeThatFits(insetSize)
        }
        return CGSize.zero
    }
    
    override func updateFrames() {
        super.updateFrames()
        
        guard let srsContentView = srsContentView else {
            return
        }
        
        
        itemCarouselView.maxPageWidth = maxBubbleWidthForBoundsSize(bounds.size)
        var srsContentTop = bubbleView.frame.maxY + srsContentViewMargin
        if !detailLabelHidden && detailLabel.bounds.height > 0 {
            srsContentTop = detailLabel.frame.maxY + srsContentViewMargin
        }
        let srsContentSize = srsContentViewSizeThatFits(bounds.size)
        
        let srsContentFrame = CGRect(x: contentInset.left, y: srsContentTop, width: srsContentSize.width, height: srsContentSize.height)
        
        if srsContentFrame.size == srsContentView.frame.size {
            srsContentView.center = CGPoint(x: srsContentFrame.midX, y: srsContentFrame.midY)
        } else {
            srsContentView.frame = srsContentFrame
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var contentHeight = super.sizeThatFits(size).height    
        let srsContentViewHeight = srsContentViewSizeThatFits(size).height
        if srsContentViewHeight > 0 {
            contentHeight += srsContentViewHeight + srsContentViewMargin
        }
    
        return CGSize(width: size.width, height: contentHeight)
    }
    
    // MARK: Animations

    override func prepareToAnimate() {
        super.prepareToAnimate()
        
        srsContentView?.alpha = 0.0
    }
    
    override func performAnimation() {
        super.performAnimation()
        
        guard let srsContentView = srsContentView else {
            return
        }
        
        let centerFinish = srsContentView.center
        var centerBegin = srsContentView.center
        centerBegin.y += 12
        srsContentView.center = centerBegin
        
        UIView.animate(withDuration: 0.5, delay: 0.4, options: .curveEaseOut, animations: {
            srsContentView.center = centerFinish
            srsContentView.alpha = 1
            }, completion: { [weak self] (completed) in
                self?.setNeedsLayout()
        })
    }
    
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        itemListView.delegate = nil
        itemListView.alpha = 1
        
        itemCarouselView.alpha = 1
    }
}
