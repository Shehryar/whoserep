//
//  ButtonView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ButtonView: UIButton, ComponentView {
    
    let defaultContentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                spinnerView.startAnimating()
            } else {
                spinnerView.stopAnimating()
            }
            isEnabled = !isLoading
        }
    }
    
    private let spinnerView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    // MARK: ComponentView Properties
    
    var component: Component? {
        didSet {
            isLoading = false
            
            if let buttonItem = buttonItem {
                updateText(buttonItem.title, buttonType: buttonItem.style.buttonType)
                
                var contentEdgeInsets = defaultContentEdgeInsets
                if buttonItem.style.padding != .zero {
                    contentEdgeInsets = buttonItem.style.padding
                }
                self.contentEdgeInsets = contentEdgeInsets
                
                if let iconItem = buttonItem.icon, let iconImage = iconItem.icon.getImage() {
                    let buttonColors = ASAPP.styles.colors.getButtonColors(for: buttonItem.style.buttonType)
                    setImage(iconImage.tinted(buttonColors.textNormal), for: .normal)
                    setImage(iconImage.tinted(buttonColors.textHighlighted), for: .highlighted)
                    setImage(iconImage.tinted(buttonColors.textDisabled), for: .disabled)
                } else {
                    setImage(nil, for: .normal)
                }
            } else {
                setTitle(nil, for: .normal)
            }
        }
    }
    
    var nestedComponentViews: [ComponentView]? {
        return nil
    }
    
    weak var interactionHandler: InteractionHandler?
    
    weak var contentHandler: ComponentViewContentHandler?
    
    var buttonItem: ButtonItem? {
        return component as? ButtonItem
    }
    
    // MARK: Init
    
    func commonInit() {
        clipsToBounds = true
        contentEdgeInsets = defaultContentEdgeInsets
        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = .byWordWrapping
        
        imageView?.contentMode = .scaleAspectFit
        
        spinnerView.hidesWhenStopped = true
        addSubview(spinnerView)
        
        addTarget(self, action: #selector(ButtonView.onTap), for: .touchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Layout
    
    /// Returns TitleLabelFrame, ImageViewFrame
    func getFramesThatFit(_ size: CGSize) -> (CGRect, CGRect) {
        var titleLabelFrame = CGRect.zero
        var imageViewFrame = CGRect.zero
        guard let buttonItem = buttonItem else {
            return (titleLabelFrame, imageViewFrame)
        }
        
        // Max Size
        let padding = contentEdgeInsets
        var fitToSize = CGSize(width: size.width > 0 ? size.width : CGFloat.greatestFiniteMagnitude,
                               height: size.height > 0 ? size.height : CGFloat.greatestFiniteMagnitude)
        fitToSize.width -= padding.left + padding.right
        fitToSize.height -= padding.top + padding.bottom
        
        // Spacing
        var imageTitleSpacing: CGFloat = 0.0
        
        // Size image view
        if let iconItem = buttonItem.icon {
            imageViewFrame.size = iconItem.size
            if iconItem.style.margin.right > 0 {
                imageTitleSpacing += iconItem.style.margin.right
            } else {
                imageTitleSpacing += ButtonItem.defaultIconSpacing
            }
        }
        
        // Size title label
        if let titleLabel = titleLabel {
            let maxTitleWidth = fitToSize.width - imageViewFrame.width - imageTitleSpacing
            let maxSize = CGSize(width: maxTitleWidth, height: fitToSize.height)
            
            var titleSize = titleLabel.sizeThatFits(maxSize)
            titleSize.width = ceil(titleSize.width)
            titleSize.height = ceil(titleSize.height)
            titleLabelFrame.size = titleSize
        }
        if titleLabelFrame.isEmpty {
            imageTitleSpacing = 0.0
        }
        
        // Vertically align image + title
        imageViewFrame.origin.y = floor((size.height - imageViewFrame.height) / 2.0)
        titleLabelFrame.origin.y = floor((size.height - titleLabelFrame.height) / 2.0)
        
        // Horizontally align content
        let contentWidth = imageViewFrame.width + titleLabelFrame.width + imageTitleSpacing
        
        // Center content by default
        imageViewFrame.origin.x = floor((size.width - contentWidth) / 2.0)
        if buttonItem.style.textAlign == .left {
            imageViewFrame.origin.x = padding.left
        } else if buttonItem.style.textAlign == .right {
            imageViewFrame.origin.x = size.width - contentWidth - padding.right
        }
        titleLabelFrame.origin.x = imageViewFrame.maxX + imageTitleSpacing
        
        return (titleLabelFrame, imageViewFrame)
    }
    
    func updateFrames() {
        let (titleLabelFrame, imageViewFrame) = getFramesThatFit(bounds.size)
        titleLabel?.frame = titleLabelFrame
        imageView?.frame = imageViewFrame
        
        spinnerView.sizeToFit()
        if titleLabelFrame.isEmpty {
            spinnerView.center = CGPoint(x: imageViewFrame.midX, y: imageViewFrame.midY)
        } else {
            spinnerView.center = CGPoint(x: titleLabelFrame.midX, y: titleLabelFrame.midY)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
        
        self.layer.cornerRadius = ASAPP.styles.primaryButtonsRounded ? self.bounds.size.height / 2 : 0
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard buttonItem != nil else {
            return .zero
        }
    
        let (titleLabelFrame, imageViewFrame) = getFramesThatFit(bounds.size)
        let padding = contentEdgeInsets
        let spacing = titleLabelFrame.minX - imageViewFrame.maxX
        let width = padding.left + imageViewFrame.width + spacing + titleLabelFrame.width + padding.right
        let height = padding.top + max(imageViewFrame.height, titleLabelFrame.height) + padding.bottom
        
        return CGSize(width: width, height: height)
    }
    
    // MARK: Action
    
    @objc func onTap() {
        if let buttonItem = buttonItem {
            interactionHandler?.didTapButtonView(self, with: buttonItem)
        }
    }
}
