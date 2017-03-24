//
//  ChatItemListMessageCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ChatItemListMessageCell: ChatMessageCell {

    override var message: ChatMessage? {
        didSet {
            itemListView.itemList = message?.attachment?.itemList
            setNeedsLayout()
        }
    }
    
    let itemListView = SRSItemListView()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        itemListView.delegate = self
        attachmentView = itemListView
    }
    
    deinit {
        itemListView.delegate = nil
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        itemListView.event = nil
    }
}

// MARK:- SRSItemListViewDelegate

extension ChatItemListMessageCell: SRSItemListViewDelegate {
    
    func itemListView(_ itemListView: SRSItemListView, didSelectButtonItem buttonItem: SRSButtonItem) {
        delegate?.chatMessageCell(self, withItemListView: itemListView, didSelectButtonItem: buttonItem)
    }
}
