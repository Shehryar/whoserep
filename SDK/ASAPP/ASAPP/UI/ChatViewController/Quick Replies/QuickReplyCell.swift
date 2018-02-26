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
    
    static var textInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    
    static var contentInset = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
    
    class func approximateHeight(withFont font: UIFont) -> CGFloat {
        return 20.0 /* insetTop */ + 20.0 /* insetBottom */ + ceil(font.lineHeight)
    }
    
    let button = UIButton()
    
    let shadowView = UIView()
    
    let leftIcon = UIImageView()
    
    var leftIconSize = CGSize(width: 16, height: 16)
    
    var leftIconImage: UIImage?
    
    let exitIcon = UIImageView()
    
    let exitIconSize = CGSize(width: 13, height: 13)
    
    var iconTintColor: UIColor = UIColor(red: 121.0 / 255.0, green: 127.0 / 255.0, blue: 144.0 / 255.0, alpha: 1.0) {
        didSet {
            if iconTintColor != oldValue {
                updateIcons()
            }
        }
    }
    
    // MARK: Init
    
    func commonInit() {
        accessibilityTraits = UIAccessibilityTraitButton
        selectionStyle = .none
        backgroundColor = .clear
        
        button.isUserInteractionEnabled = false
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.titleLabel?.font = ASAPP.styles.textStyles.body.font
        button.setTitleColor(ASAPP.styles.colors.quickReplyButton.textNormal, for: .normal)
        
        button.backgroundColor = UIColor.white
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        contentView.addSubview(button)
        
        exitIcon.contentMode = .scaleAspectFit
        contentView.addSubview(exitIcon)
        
        leftIcon.contentMode = .scaleAspectFit
        contentView.addSubview(leftIcon)
        
        shadowView.backgroundColor = button.backgroundColor
        shadowView.layer.opacity = 1
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowView.layer.shadowRadius = 4
        shadowView.layer.shadowOpacity = 0.1
        shadowView.layer.cornerRadius = button.layer.cornerRadius
        contentView.insertSubview(shadowView, belowSubview: button)
        
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        button.isSelected = selected
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        button.isHighlighted = highlighted
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
        
        if quickReply.action.type == .componentView {
            button.updateText(quickReply.title, textStyle: ASAPP.styles.textStyles.bodyBold, colors: ASAPP.styles.colors.quickReplyButton)
        } else {
            button.updateText(quickReply.title, textStyle: ASAPP.styles.textStyles.body, colors: ASAPP.styles.colors.quickReplyButton)
        }
        
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
        
        return CGSize(width: min(maxButtonWidth, ceil(buttonSize.width)), height: max(40, ceil(buttonSize.height)))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonSize = buttonSizeThatFits(size: bounds.size)
        let buttonLeft = floor((bounds.size.width - buttonSize.width) / 2)
        let buttonTop = floor((bounds.size.height - buttonSize.height) / 2)
        
        button.frame = CGRect(x: buttonLeft, y: buttonTop, width: buttonSize.width, height: buttonSize.height)
        button.contentEdgeInsets = QuickReplyCell.textInset
        
        if exitIcon.image != nil && !exitIcon.isHidden {
            button.contentEdgeInsets.right += QuickReplyCell.textInset.right / 2 + exitIconSize.width
        }
        
        if leftIcon.image != nil && !leftIcon.isHidden {
            button.contentEdgeInsets.left += QuickReplyCell.textInset.left / 2 + leftIconSize.width
        }
        
        shadowView.frame = button.frame
        
        let leftIconLeft = button.frame.minX + QuickReplyCell.textInset.left
        let leftIconTop = floor((bounds.size.height - leftIconSize.height) / 2)
        leftIcon.frame = CGRect(x: leftIconLeft, y: leftIconTop, width: leftIconSize.width, height: leftIconSize.height)
        
        let exitIconLeft = button.frame.maxX - QuickReplyCell.textInset.right - exitIconSize.width
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
