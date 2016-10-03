//
//  ChatPictureMessageCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatPictureMessageCell: ChatBubbleCell {
    
    override var event: Event? {
        didSet {
            if let event = event, let pictureMessage = event.pictureMessage {
                pictureImageView.fixedImageSize = CGSize(width: pictureMessage.width, height: pictureMessage.height)
                if let imageURL = event.imageURLForPictureMessage(pictureMessage) {
                    if !disableImageLoading {
                        pictureImageView.sd_setImage(with: imageURL)
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
        
        pictureImageView.contentMode = .scaleAspectFill
        pictureImageView.backgroundColor = Colors.lightGrayColor().withAlphaComponent(0.5)
        pictureImageView.isOpaque = true

        bubbleView.clipsToBubblePath = true
        bubbleView.addSubview(pictureImageView)
    }
    
    // MARK: Image Downloading
    
    func setImageWithURL(_ imageURL: URL, forEvent eventForImage: Event) {
        SDWebImageManager
            .shared()
            .downloadImage(with: imageURL, options: .highPriority, progress: nil) { [weak self] (image, error, cacheType, completed, imageURL) in
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
    
    func imageViewSizeThatFitsBoundsSize(_ size: CGSize) -> CGSize {
        guard let event = event,
            let pictureMessage = event.pictureMessage else {
                return CGSize.zero
        }
        
        var imageWidth = maxBubbleWidthForBoundsSize(size)
        var imageHeight = imageWidth / CGFloat(pictureMessage.aspectRatio)
        let maxImageHeight = 0.6 * UIScreen.main.bounds.height
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
            bubbleLeft = bounds.width - contentInset.right - imageSize.width
        }
    
        bubbleView.frame = CGRect(x: bubbleLeft, y: contentInset.top, width: imageSize.width, height: imageSize.height)
        pictureImageView.frame = bubbleView.bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let imageHeight = ceil(imageViewSizeThatFitsBoundsSize(size).height)
        
        return CGSize(width: size.width, height: imageHeight + contentInset.top + contentInset.bottom)
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pictureImageView.image = nil
    }
}
