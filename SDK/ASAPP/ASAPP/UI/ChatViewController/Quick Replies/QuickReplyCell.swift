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
        return UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    }
    
    static let contentInset = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
    
    let button = BubbleButton()
    
    let leftIcon = UIImageView()
    
    var leftIconSize = CGSize(width: 16, height: 16)
    
    var leftIconImage: UIImage?
    
    let exitIcon = UIImageView()
    
    let exitIconSize = CGSize(width: 16, height: 16)
    
    var iconTintColor: UIColor = UIColor(red: 121.0 / 255.0, green: 127.0 / 255.0, blue: 144.0 / 255.0, alpha: 1.0) {
        didSet {
            if iconTintColor != oldValue {
                updateIcons()
            }
        }
    }
    
    class func approximateButtonHeight(with font: UIFont) -> CGFloat {
        return 10 /* insetTop */ + 10 /* insetBottom */ + ceil(font.lineHeight)
    }
    
    class func approximateHeight(with font: UIFont) -> CGFloat {
        return 18 /* insetTop */ + 18 /* insetBottom */ + ceil(font.lineHeight)
    }
    
    private var exitIconVisible: Bool {
        return exitIcon.image != nil && !exitIcon.isHidden
    }
    
    private var leftIconVisible: Bool {
        return leftIcon.image != nil && !leftIcon.isHidden
    }
    
    // MARK: Init
    
    func commonInit() {
        accessibilityTraits = UIAccessibilityTraitButton
        selectionStyle = .none
        backgroundColor = .clear
        
        button.isUserInteractionEnabled = false
        button.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        button.label.textAlignment = .right
        button.contentAlignment = .right
        button.label.numberOfLines = 1
        button.label.lineBreakMode = .byTruncatingTail
        button.label.adjustsFontSizeToFitWidth = false
        button.label.font = ASAPP.styles.textStyles.body.font
        button.bubble.strokeColor = ASAPP.styles.colors.quickReplyButton.border
        button.setForegroundColor(ASAPP.styles.colors.quickReplyButton.textNormal, forState: .normal)
        button.setForegroundColor(ASAPP.styles.colors.quickReplyButton.textHighlighted, forState: .highlighted)
        button.setBackgroundColor(ASAPP.styles.colors.quickReplyButton.backgroundNormal, forState: .normal)
        button.setBackgroundColor(ASAPP.styles.colors.quickReplyButton.backgroundHighlighted, forState: .highlighted)
        button.layer.masksToBounds = false
        contentView.addSubview(button)
        
        exitIcon.contentMode = .scaleAspectFit
        contentView.addSubview(exitIcon)
        
        leftIcon.contentMode = .scaleAspectFit
        contentView.addSubview(leftIcon)
        
        updateIcons()
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
    
    func updateIcons() {
        leftIcon.image = leftIconImage?.tinted(iconTintColor)
        exitIcon.image = Images.getImage(.iconExitLink)?.tinted(iconTintColor)
    }
    
    func update(for quickReply: QuickReply?, enabled: Bool) {
        guard let quickReply = quickReply else {
            leftIcon.isHidden = true
            exitIcon.isHidden = true
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
            leftIcon.isHidden = false
            updateIcons()
        } else {
            leftIcon.isHidden = true
        }
        
        if quickReply.action.willExitASAPP {
            exitIcon.isHidden = false
            accessibilityTraits = UIAccessibilityTraitLink
        } else {
            exitIcon.isHidden = true
            accessibilityTraits = UIAccessibilityTraitButton
        }
        
        button.isEnabled = enabled
    }
}

// MARK: - Layout

extension QuickReplyCell {
    
    func buttonSizeThatFits(size: CGSize) -> CGSize {
        let maxButtonWidth = size.width - QuickReplyCell.contentInset.left - QuickReplyCell.contentInset.right
        let buttonSize = button.sizeThatFits(CGSize(width: maxButtonWidth, height: 0))
        let totalLeftIconWidth = leftIconVisible ? textInset.left + leftIconSize.width : 0
        let totalExitIconWidth = exitIconVisible ? textInset.right + exitIconSize.width : 0
        let totalSize = CGSize(width: buttonSize.width + totalLeftIconWidth + totalExitIconWidth, height: buttonSize.height)
        
        return CGSize(width: min(maxButtonWidth, ceil(totalSize.width)), height: max(40, ceil(totalSize.height)))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let buttonSize = buttonSizeThatFits(size: CGSize(width: bounds.size.width - buttonInsets.left - buttonInsets.right, height: bounds.size.height))
        let buttonLeft = floor((bounds.size.width - buttonSize.width)) - buttonInsets.right
        let buttonTop = floor((bounds.size.height - buttonSize.height) / 2)
        
        button.frame = CGRect(x: buttonLeft, y: buttonTop, width: buttonSize.width, height: buttonSize.height)
        button.contentInset = textInset
        
        if exitIconVisible {
            button.contentInset.right = textInset.right + exitIconSize.width + 10
        }
        
        if leftIconVisible {
            button.contentInset.left = textInset.left + leftIconSize.width + 2
        }
        
        let leftIconLeft = button.frame.minX + textInset.left
        let leftIconTop = floor((bounds.size.height - leftIconSize.height) / 2)
        leftIcon.frame = CGRect(x: leftIconLeft, y: leftIconTop, width: leftIconSize.width, height: leftIconSize.height)
        
        let exitIconLeft = button.frame.maxX - textInset.right - exitIconSize.width
        let exitIconTop = floor((bounds.size.height - exitIconSize.height) / 2)
        exitIcon.frame = CGRect(x: exitIconLeft, y: exitIconTop, width: exitIconSize.width, height: exitIconSize.height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let buttonSize = buttonSizeThatFits(size: size)
        var contentHeight = buttonSize.height
        if contentHeight > 0 {
            contentHeight += QuickReplyCell.contentInset.top + QuickReplyCell.contentInset.bottom
        }
        
        return CGSize(width: size.width, height: contentHeight)
    }
}
