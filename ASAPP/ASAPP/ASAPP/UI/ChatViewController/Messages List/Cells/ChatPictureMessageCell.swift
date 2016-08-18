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
//                        setImageWithURL(imageURL, forEvent: event)
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
    
    // MARK: Image Downloading
    
    func setImageWithURL(imageURL: NSURL, forEvent eventForImage: Event) {
        SDWebImageManager
            .sharedManager()
            .downloadImageWithURL(imageURL, options: .HighPriority, progress: nil) { [weak self] (image, error, cacheType, completed, imageURL) in
                if error == nil {
                
                    Dispatcher.performOnMainThread({
                        if self?.event == eventForImage {
                            self?.pictureImageView.image = image
                        }
                    })
                }
        }
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

        return CGSize(width: ceil(imageWidth),
                      height: ceil(imageHeight))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize = imageViewSizeThatFitsBoundsSize(bounds.size)
        var bubbleLeft = contentInset.left
        if !isReply {
            bubbleLeft = CGRectGetWidth(bounds) - contentInset.right - imageSize.width
        }
        
        let bubbleHeight = CGRectGetHeight(bounds) - contentInset.top - contentInset.bottom
        bubbleView.frame = CGRect(x: bubbleLeft, y: contentInset.top, width: imageSize.width, height: imageSize.height)
        pictureImageView.frame = bubbleView.bounds
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let imageHeight = ceil(imageViewSizeThatFitsBoundsSize(size).height)
        
        return CGSize(width: size.width, height: imageHeight + contentInset.top + contentInset.bottom)
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pictureImageView.image = nil
    }
}
