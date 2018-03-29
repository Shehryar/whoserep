//
//  QuickReplyCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/15/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class QuickReplyCell: UITableViewCell {
    class var reuseIdentifier: String {
        return "QuickReplyCell"
    }
    
    var textInset: UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
    
    static let contentInset = UIEdgeInsets(top: 4, left: 24, bottom: 4, right: 24)
    
    let button = BubbleButton()
    
    let buttonMinHeight: CGFloat = 40
    
    var leftIconSize = CGSize(width: 16, height: 16)
    
    var leftIconImage: UIImage?
    
    var iconTintColor: UIColor = UIColor(red: 121.0 / 255.0, green: 127.0 / 255.0, blue: 144.0 / 255.0, alpha: 1.0) {
        didSet {
            if iconTintColor != oldValue {
                updateIcon()
            }
        }
    }
    
    class func approximateButtonHeight(with font: UIFont) -> CGFloat {
        return 10 /* insetTop */ + 10 /* insetBottom */ + ceil(font.lineHeight)
    }
    
    class func approximateHeight(with font: UIFont) -> CGFloat {
        return 14 /* insetTop */ + 14 /* insetBottom */ + ceil(font.lineHeight)
    }
    
    private var leftIconVisible: Bool {
        return leftIconImage != nil
    }
    
    // MARK: Init
    
    func commonInit() {
        accessibilityTraits = UIAccessibilityTraitButton
        selectionStyle = .none
        backgroundColor = .clear
        
        button.isUserInteractionEnabled = false
        button.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        button.label.textAlignment = .left
        button.contentAlignment = .left
        button.label.numberOfLines = 0
        button.label.lineBreakMode = .byWordWrapping
        button.label.allowsDefaultTighteningForTruncation = true
        button.label.adjustsFontSizeToFitWidth = false
        button.label.font = ASAPP.styles.textStyles.body.font
        button.bubble.strokeColor = ASAPP.styles.colors.quickReplyButton.border
        button.setForegroundColor(ASAPP.styles.colors.quickReplyButton.textNormal, forState: .normal)
        button.setForegroundColor(ASAPP.styles.colors.quickReplyButton.textHighlighted, forState: .highlighted)
        button.setBackgroundColor(ASAPP.styles.colors.quickReplyButton.backgroundNormal, forState: .normal)
        button.setBackgroundColor(ASAPP.styles.colors.quickReplyButton.backgroundHighlighted, forState: .highlighted)
        button.layer.masksToBounds = false
        contentView.addSubview(button)
        
        updateIcon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    // MARK: Selected / Highlighted
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        button.isHighlighted = highlighted
        button.updateButtonDisplay()
    }
    
    // MARK: Content
    
    func updateIcon() {
        button.imageSize = leftIconSize
        button.image = leftIconImage?.tinted(iconTintColor)
    }
    
    func update(for quickReply: QuickReply?, enabled: Bool) {
        guard let quickReply = quickReply else {
            accessibilityTraits = UIAccessibilityTraitButton
            button.isEnabled = enabled
            return
        }
        
        button.title = quickReply.title
        button.font = ASAPP.styles.textStyles.body.font
        
        iconTintColor = ASAPP.styles.colors.quickReplyButton.textNormal
        
        if let notificationIcon = quickReply.icon {
            leftIconSize = notificationIcon.size
            leftIconImage = notificationIcon.icon.getImage()
        } else {
            leftIconImage = nil
        }
        updateIcon()
        
        button.isEnabled = enabled
    }
}

// MARK: - Layout

extension QuickReplyCell {
    private struct CalculatedLayout {
        let buttonFrame: CGRect
    }
    
    private func buttonSizeThatFits(size: CGSize) -> CGSize {
        let buttonSize = button.sizeThatFits(CGSize(width: size.width, height: 0))
        let totalSize = CGSize(width: buttonSize.width, height: buttonSize.height)
        
        return CGSize(width: ceil(totalSize.width), height: max(buttonMinHeight, ceil(totalSize.height)))
    }
    
    private func getFramesThatFit(_ size: CGSize) -> CalculatedLayout {
        let buttonInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let buttonSize = buttonSizeThatFits(size: CGSize(width: bounds.size.width - buttonInsets.left - buttonInsets.right, height: bounds.size.height))
        let buttonLeft = floor((bounds.size.width - buttonSize.width)) - buttonInsets.right
        let buttonTop = floor((bounds.size.height - buttonSize.height) / 2)
        let buttonFrame = CGRect(x: buttonLeft, y: buttonTop, width: buttonSize.width, height: buttonSize.height)
        
        return CalculatedLayout(buttonFrame: buttonFrame)
    }
    
    func updateFrames() {
        let layout = getFramesThatFit(bounds.size)
        button.frame = layout.buttonFrame
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.contentInset = textInset
        updateFrames()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getFramesThatFit(bounds.size)
        var height = layout.buttonFrame.height
        if height > 0 {
            height += QuickReplyCell.contentInset.top + QuickReplyCell.contentInset.bottom
        }
        
        return CGSize(width: size.width, height: height)
    }
}
