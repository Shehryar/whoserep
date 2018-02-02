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
    
    let imageSize: CGFloat = 13
    
    var imageTintColor: UIColor = UIColor(red: 121.0 / 255.0, green: 127.0 / 255.0, blue: 144.0 / 255.0, alpha: 1.0) {
        didSet {
            if imageTintColor != oldValue {
                updateImageView()
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
        
        shadowView.backgroundColor = button.backgroundColor
        shadowView.layer.opacity = 1
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowView.layer.shadowRadius = 4
        shadowView.layer.shadowOpacity = 0.1
        shadowView.layer.cornerRadius = button.layer.cornerRadius
        contentView.addSubview(shadowView)
        
        contentView.bringSubview(toFront: button)
        
        imageView?.contentMode = .scaleAspectFit
        updateImageView()
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
    
    func updateImageView() {
        imageView?.image = Images.getImage(.iconExitLink)?.tinted(imageTintColor)
    }
    
    func update(for quickReply: QuickReply?, enabled: Bool) {
        guard let quickReply = quickReply else {
            imageView?.isHidden = true
            accessibilityTraits = UIAccessibilityTraitButton
            button.isEnabled = enabled
            return
        }
        
        if quickReply.action.type == .componentView {
            button.updateText(quickReply.title, textStyle: ASAPP.styles.textStyles.bodyBold, colors: ASAPP.styles.colors.quickReplyButton)
        } else {
            button.updateText(quickReply.title, textStyle: ASAPP.styles.textStyles.body, colors: ASAPP.styles.colors.quickReplyButton)
        }
        
        imageTintColor = ASAPP.styles.colors.quickReplyButton.textNormal
        
        // TODO: refactor and implement showing custom icon
        if quickReply.action.willExitASAPP {
            imageView?.isHidden = false
            accessibilityTraits = UIAccessibilityTraitLink
        } else {
            imageView?.isHidden = true
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
        let buttonLeft = floor((bounds.size.width - buttonSize.width) / 2.0)
        let buttonTop = floor((bounds.size.height - buttonSize.height) / 2.0)
        
        button.frame = CGRect(x: buttonLeft, y: buttonTop, width: buttonSize.width, height: buttonSize.height)
        button.contentEdgeInsets = QuickReplyCell.textInset
        
        let imageLeft = button.frame.maxX - QuickReplyCell.textInset.right - imageSize
        let imageTop = floor((bounds.size.height - imageSize) / 2.0)
        
        if imageView?.image != nil && !(imageView?.isHidden ?? false) {
            button.contentEdgeInsets.right += QuickReplyCell.textInset.right + imageSize
        }
        
        shadowView.frame = button.frame
        
        imageView?.frame = CGRect(x: imageLeft, y: imageTop, width: imageSize, height: imageSize)
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
