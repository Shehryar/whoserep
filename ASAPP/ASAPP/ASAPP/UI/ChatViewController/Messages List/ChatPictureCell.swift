//
//  ChatPictureCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatPictureCell: ChatBubbleCell {
    
    var imageURL: NSURL? {
        didSet {
            if let imageURL = imageURL {
                
            } else {
                imageView?.image = nil
            }
        }
    }
    
    private let pictureImageView = UIImageView()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()

        pictureImageView.contentMode = .ScaleAspectFill
        pictureImageView.removeFromSuperview()
        pictureImageView.image = Images.testImage(withAlpha: 0.7)

        bubbleView.clipsToBubblePath = true
        bubbleView.strokeColor = Colors.bluishGray()
        bubbleView.addSubview(pictureImageView)
        
        setNeedsUpdateConstraints()
    }
    
    // MARK: Layout
    
    override func updateConstraints() {
        super.updateConstraints()
        
        let imageAspectRatio = 6.0 / 9.0
        
        bubbleView.snp_updateConstraints { (make) in
            make.width.equalTo(pictureImageView.snp_width)
            make.height.equalTo(pictureImageView.snp_height)
        }
        
        pictureImageView.snp_updateConstraints { (make) in
            make.left.equalTo(bubbleView.snp_left)
            make.top.equalTo(bubbleView.snp_top)
            make.width.equalTo(bubbleView.snp_width)
            make.height.equalTo(pictureImageView.snp_width).multipliedBy(imageAspectRatio)
        }
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        pictureImageView.image = nil
    }
}
