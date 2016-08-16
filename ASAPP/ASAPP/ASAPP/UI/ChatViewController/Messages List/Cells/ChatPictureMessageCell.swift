//
//  ChatPictureMessageCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import SDWebImage

class ChatPictureMessageCell: ChatBubbleCell {
    
    var event: Event? {
        didSet {
            if let event = event, let pictureMessage = event.pictureMessage {
                pictureImageView.fixedImageSize = CGSize(width: pictureMessage.width, height: pictureMessage.height)
                if let imageURL = event.imageURLForPictureMessage(pictureMessage) {
                    pictureImageView.sd_setImageWithURL(imageURL)
                } else {
                    pictureImageView.image = nil
                }
            }
            setNeedsUpdateConstraints()
        }
    }
    
    let pictureImageView = FixedSizeImageView()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        pictureImageView.translatesAutoresizingMaskIntoConstraints = false
        pictureImageView.contentMode = .ScaleAspectFill
        pictureImageView.backgroundColor = Colors.lightGrayColor().colorWithAlphaComponent(0.5)
        pictureImageView.opaque = true

        contentView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.clipsToBubblePath = true
        bubbleView.addSubview(pictureImageView)
        
        setNeedsUpdateConstraints()
    }
    
    // MARK: Styles
    
    override func updateFontsAndColors() {
        super.updateFontsAndColors()
        
        bubbleView.strokeColor = nil
        bubbleView.fillColor = styles.backgroundColor2
        pictureImageView.backgroundColor = styles.backgroundColor2
    }
    
    // MARK: Layout
    
    override func updateConstraints() {
        guard maxMessageWidth > 0 else { return }
        
        var aspectRatio: Double = 1.0
        if let pictureMessage = event?.pictureMessage {
            aspectRatio = pictureMessage.aspectRatio
        }
        
        bubbleView.snp_updateConstraints { (make) in
            make.right.equalTo(pictureImageView.snp_right)
            make.bottom.equalTo(pictureImageView.snp_bottom)
        }
        
        pictureImageView.snp_remakeConstraints { (make) in
            make.left.equalTo(bubbleView.snp_left)
            make.top.equalTo(bubbleView.snp_top)
            make.width.lessThanOrEqualTo(bubbleView.snp_width)
            make.height.lessThanOrEqualTo(pictureImageView.snp_width).dividedBy(aspectRatio)
        }
        
        super.updateConstraints()
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pictureImageView.image = nil
    }
}
