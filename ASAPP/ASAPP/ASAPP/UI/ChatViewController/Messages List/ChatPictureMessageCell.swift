//
//  ChatPictureMessageCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import KFSwiftImageLoader

class ChatPictureMessageCell: ChatBubbleCell {
    
    var event: Event? {
        didSet {
            if let imageURL = event?.imageURLForPictureMessage(event?.pictureMessage) {
                pictureImageView.loadImageFromURL(imageURL, placeholderImage: nil, completion: { (finished, error) in
                    self.setNeedsUpdateConstraints()
                })
            } else {
                pictureImageView.image = nil
            }
            setNeedsUpdateConstraints()
        }
    }
    
    private let pictureImageView = UIImageView()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()

        ignoresReplyBubbleStyling = true
        
        pictureImageView.contentMode = .ScaleAspectFill
        pictureImageView.removeFromSuperview()

        bubbleView.clipsToBubblePath = true
        bubbleView.strokeColor = Colors.bluishGray()
        bubbleView.fillColor = Colors.lightGrayColor()
        bubbleView.addSubview(pictureImageView)
        
        setNeedsUpdateConstraints()
    }
    
    // MARK: Layout
    
    override func updateConstraints() {
        super.updateConstraints()
        
        var aspectRatio: Double = 1.0
        if let pictureMessage = event?.pictureMessage {
            aspectRatio = pictureMessage.aspectRatio
        }
        
        bubbleView.snp_updateConstraints { (make) in
            make.width.equalTo(pictureImageView.snp_width)
            make.height.equalTo(pictureImageView.snp_height)
        }
        
        pictureImageView.snp_remakeConstraints { (make) in
            make.left.equalTo(bubbleView.snp_left)
            make.top.equalTo(bubbleView.snp_top)
            make.width.equalTo(bubbleView.snp_width)
            make.height.equalTo(pictureImageView.snp_width).dividedBy(aspectRatio)
        }
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pictureImageView.image = nil
    }
}
