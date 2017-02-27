//
//  ChatPictureMessageCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ChatPictureMessageCell: ChatMessageCell {

    override var event: Event? {
        didSet {
            pictureView.event = event
            setNeedsLayout()
        }
    }

    override var attachmentViewMaxWidthPercentage: CGFloat {
        return 0.85
    }
    
    let pictureView = ChatPictureView()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        attachmentView = pictureView
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pictureView.event = nil
    }
}
