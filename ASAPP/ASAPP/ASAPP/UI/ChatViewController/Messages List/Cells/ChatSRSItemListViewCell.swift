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
            if let response = response,
                let itemList = response.itemList {
                messageText = itemList.title
                
                if response.displayType == .Inline {
                    if itemList.orientation == .Horizontal {
                        itemListView.orientation = .horizontal
                    } else {
                        itemListView.orientation = .vertical
                    }
                    itemListView.srsItems = itemList.contentItems
                } else {
                    itemListView.srsItems = nil
                }
            } else {
                messageText = nil
                itemListView.srsItems = nil
            }
            setNeedsLayout()
        }
    }
    
    let itemListView = SRSItemListView()
    
    let itemListViewMargin: CGFloat = 10.0
    
    // MARK: Init
    
    override func commonInit() {
        isReply = true
        super.commonInit()
        
        itemListView.contentInset = UIEdgeInsets(top: 25, left: 40, bottom: 25, right: 40)
        contentView.addSubview(itemListView)
    }
    
    // MARK: Styling
    
    override func updateFontsAndColors() {
        super.updateFontsAndColors()
        itemListView.backgroundColor = styles.backgroundColor2
        itemListView.layer.borderColor = styles.separatorColor1.cgColor
        itemListView.layer.borderWidth = 1
        itemListView.layer.cornerRadius = 4
        itemListView.applyStyles(styles)
        setNeedsLayout()
    }
    
    // MARK: Layout
    
    func itemListViewSizeThatFits(_ size: CGSize) -> CGSize {
        let maxWidth = size.width - contentInset.left - contentInset.right
        let insetSize = CGSize(width: maxWidth, height: 0)
        
        return itemListView.sizeThatFits(insetSize)
    }
    
    override func updateFrames() {
        super.updateFrames()
        
        var itemListTop = bubbleView.frame.maxY + itemListViewMargin
        if !detailLabelHidden && detailLabel.bounds.height > 0 {
            itemListTop = detailLabel.frame.maxY + itemListViewMargin
        }
        let itemListSize = itemListViewSizeThatFits(bounds.size)
        
        let itemListFrame = CGRect(x: contentInset.left, y: itemListTop, width: itemListSize.width, height: itemListSize.height)
        if itemListFrame.size == itemListView.frame.size {
            let itemListCenter = CGPoint(x: itemListFrame.midX, y: itemListFrame.midY)
            itemListView.center = itemListCenter
        } else {
            itemListView.frame = itemListFrame
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var contentHeight = super.sizeThatFits(size).height
        let itemListHeight = itemListViewSizeThatFits(size).height
        if itemListHeight > 0 {
            contentHeight += itemListHeight + itemListViewMargin
        }
        
        return CGSize(width: size.width, height: contentHeight)
    }
    
    // MARK: Animations

    override func prepareToAnimate() {
        super.prepareToAnimate()
        
        itemListView.alpha = 0.0
    }
    
    override func performAnimation() {
        super.performAnimation()
        
        UIView.animate(withDuration: 0.3, delay: 0.4, options: .curveEaseOut, animations: {
            self.itemListView.alpha = 1
            }, completion: nil)
    }
    
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        itemListView.delegate = nil
        itemListView.alpha = 1
    }
}
