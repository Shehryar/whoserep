//
//  ChatPictureView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ChatPictureView: BubbleView, MessageButtonsViewContainer {
    weak var delegate: MessageButtonsViewContainerDelegate?

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
    
    var messageButtonsView: MessageButtonsView? {
        didSet {
            if let view = messageButtonsView, oldValue == nil {
                view.contentInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
                view.delegate = self
                addSubview(view)
            }
        }
    }
    
    private var picture: ChatMessageImage? {
        return message?.attachment?.image
    }
    
    // MARK: Initialization
    
    func commonInit() {
        clipsToBounds = true
        
        fillColor = .white
        strokeColor = ASAPP.styles.colors.replyMessageBorder
        strokeLineWidth = 1
        
        imageView.backgroundColor = ASAPP.styles.colors.backgroundSecondary
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        
        isAccessibilityElement = false
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

// MARK: - Layout + Sizing

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
        
        let messageButtonsHeight = getMessageButtonsViewSizeThatFits(bounds.width).height
        messageButtonsView?.frame = CGRect(x: 0, y: bounds.height - messageButtonsHeight, width: bounds.width, height: messageButtonsHeight)
        
        imageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - messageButtonsHeight)
        
        imageView.isAccessibilityElement = true
        var elements: [Any] = [imageView]
        if let messageButtonsView = messageButtonsView {
            elements.append(messageButtonsView)
        }
        accessibilityElements = elements
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fittedSize = imageViewSizeThatFits(size)
        let messageButtonsSize = getMessageButtonsViewSizeThatFits(size.width)
        return CGSize(width: size.width, height: fittedSize.height + messageButtonsSize.height)
    }
}

extension ChatPictureView: MessageButtonsViewDelegate {
    func messageButtonsView(_ messageButtonsView: MessageButtonsView, didTap button: QuickReply) {
        delegate?.messageButtonsViewContainer(self, didTap: button)
    }
}
