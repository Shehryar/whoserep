//
//  ChatPictureView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ChatPictureView: UIView {

    var message: ChatMessage? {
        didSet {
            if let picture = picture {
                imageView.fixedImageSize = CGSize(width: picture.width, height: picture.height)
                if !disableImageLoading {
                    imageView.sd_setImage(with: picture.url)
                } else {
                    imageView.image = nil
                }
            } else {
                imageView.image = nil
            }
        }
    }
    
    var disableImageLoading: Bool = false

    let imageView = FixedSizeImageView()
    
    private var picture: ChatMessageImage? {
        return message?.attachment?.image
    }
    
    // MARK: Initialization
    
    func commonInit() {
        clipsToBounds = true
        
        imageView.backgroundColor = ASAPP.styles.colors.backgroundSecondary
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6.0
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}

// MARK:- Layout + Sizing

extension ChatPictureView {
    
    func imageViewSizeThatFits(_ size: CGSize) -> CGSize {
        guard let picture = picture, picture.width > 0 && picture.height > 0 else {
                return CGSize.zero
        }
        
        var imageWidth = size.width
        var imageHeight = imageWidth / CGFloat(picture.aspectRatio)
        let maxImageHeight = 0.6 * UIScreen.main.bounds.height
        if imageHeight > maxImageHeight {
            imageHeight = maxImageHeight
            imageWidth = imageHeight * CGFloat(picture.aspectRatio)
        }
        
        return CGSize(width: ceil(imageWidth), height: ceil(imageHeight))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return imageViewSizeThatFits(size)
    }
}
