//
//  ChatPictureMessageCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ChatPictureMessageCell: ChatMessageCell {

    override var message: ChatMessage? {
        didSet {
            pictureView.message = message
            setNeedsLayout()
        }
    }
    
    let pictureView = ChatPictureView()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        attachmentView = pictureView
        pictureView.delegate = self
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pictureView.message = nil
    }
}
