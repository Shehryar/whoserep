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
                    if !disableImageLoading {
                        pictureImageView.sd_setImageWithURL(imageURL)
                    } else {
                        pictureImageView.image = nil
                    }
                } else {
                    pictureImageView.image = nil
                }
            }
            setNeedsLayout()
        }
    }
    
    var disableImageLoading: Bool = false
    
    let pictureImageView = FixedSizeImageView()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        pictureImageView.contentMode = .ScaleAspectFill
        pictureImageView.backgroundColor = Colors.lightGrayColor().colorWithAlphaComponent(0.5)
        pictureImageView.opaque = true

        bubbleView.clipsToBubblePath = true
        bubbleView.addSubview(pictureImageView)
    }
    
    // MARK: Styles
    
    override func updateFontsAndColors() {
        super.updateFontsAndColors()
        
        bubbleView.strokeColor = nil
        bubbleView.fillColor = styles.backgroundColor2
        pictureImageView.backgroundColor = styles.backgroundColor2
    }
    
    // MARK: Layout
    
    func imageViewSizeThatFitsBoundsSize(size: CGSize) -> CGSize {
        guard let event = event,
            let pictureMessage = event.pictureMessage else {
                return CGSizeZero
        }
        
        var imageWidth = maxBubbleWidthForBoundsSize(size)
        var imageHeight = imageWidth / CGFloat(pictureMessage.aspectRatio)
        let maxImageHeight = 0.6 * CGRectGetHeight(UIScreen.mainScreen().bounds)
        if imageHeight > maxImageHeight {
            imageHeight = maxImageHeight
            imageWidth = imageHeight * CGFloat(pictureMessage.aspectRatio)
        }
        
        print("\n\nAspect Ratio: \(pictureMessage.aspectRatio)\nWidth: \(imageWidth), height: \(imageHeight)\nBounds Size: \(size)\n\n")
        
        return CGSize(width: ceil(imageWidth), height: ceil(imageHeight))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize = imageViewSizeThatFitsBoundsSize(bounds.size)
        var bubbleLeft = contentInset.left
        if !isReply {
            bubbleLeft = CGRectGetWidth(bounds) - contentInset.right - imageSize.width
        }
        
        let bubbleHeight = CGRectGetHeight(bounds) - contentInset.top - contentInset.bottom
        bubbleView.frame = CGRect(x: bubbleLeft, y: contentInset.top, width: imageSize.width, height: bubbleHeight)
        pictureImageView.frame = bubbleView.bounds
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let imageHeight = ceil(imageViewSizeThatFitsBoundsSize(size).height)
        
        print("\n\nSizeThatFits = \(imageHeight) for size: \(size), aspect \(event?.pictureMessage?.aspectRatio ?? 1)\n\n")
        
        return CGSize(width: size.width, height: imageHeight + contentInset.top + contentInset.bottom)
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pictureImageView.image = nil
    }
}
