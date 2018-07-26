//
//  QuickReplyView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/15/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol QuickReplyViewDelegate: class {
    func didTapQuickReplyView(_ quickReplyView: QuickReplyView)
}

class QuickReplyView: UIView {
    weak var delegate: QuickReplyViewDelegate?
    
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
    
    private(set) var gestureRecognizer: UIGestureRecognizer?
    
    var canBeHighlighted = true
    
    // MARK: Init
    
    func commonInit() {
        accessibilityTraits = UIAccessibilityTraitButton
        backgroundColor = .clear
        isUserInteractionEnabled = true
        
        button.imageIgnoresForegroundColor = true
        button.isUserInteractionEnabled = false
        button.contentInset = textInset
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
        addSubview(button)
        
        updateIcon()
        
        let press = UILongPressGestureRecognizer(target: self, action: #selector(didPress))
        press.minimumPressDuration = 0
        addGestureRecognizer(press)
        gestureRecognizer = press
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        if let recognizer = gestureRecognizer {
            removeGestureRecognizer(recognizer)
        }
    }
    
    // MARK: Selected / Highlighted
    
    func setHighlighted(_ highlighted: Bool, animated: Bool) {
        button.isHighlighted = highlighted
        button.updateButtonDisplay()
    }
    
    // MARK: Content
    
    func updateIcon() {
        button.imageSize = leftIconSize
        button.image = leftIconImage
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
            leftIconImage = notificationIcon.icon.getImage()?.tinted(iconTintColor)
        } else {
            leftIconImage = nil
        }
        updateIcon()
        
        button.isEnabled = enabled
    }
    
    func update(enabled: Bool) {
        button.isEnabled = enabled
    }
    
    @objc func didPress(recognizer: UIGestureRecognizer) {
        let isInView = bounds.contains(recognizer.location(in: self))
        let highlighted = ![.ended, .cancelled].contains(recognizer.state)
        Dispatcher.delay(.milliseconds(100)) { [weak self] in
            let shouldStillHighlight = ![.ended, .cancelled].contains(recognizer.state) && isInView
            self?.setHighlighted(highlighted && shouldStillHighlight && (self?.canBeHighlighted ?? false), animated: true)
        }
        
        if recognizer.state == .ended && isInView {
            delegate?.didTapQuickReplyView(self)
        }
    }
}

// MARK: - Layout

extension QuickReplyView {
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
        let buttonSize = buttonSizeThatFits(size: CGSize(width: size.width - buttonInsets.left - buttonInsets.right, height: size.height))
        let buttonLeft = floor((size.width - buttonSize.width)) - buttonInsets.right
        let buttonFrame = CGRect(x: buttonLeft, y: 0, width: buttonSize.width, height: buttonSize.height)
        
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
        let layout = getFramesThatFit(size)
        var height = layout.buttonFrame.height
        if height > 0 {
            height += QuickReplyView.contentInset.top + QuickReplyView.contentInset.bottom
        }
        
        return CGSize(width: size.width, height: height)
    }
}
