//
//  Button.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/15/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class Button: UIView {

    enum ButtonState {
        case normal
        case highlighted
    }
    
    // MARK: Public Properties
    
    var title: String? {
        didSet {
            label.text = title
            accessibilityLabel = title
            setNeedsLayout()
        }
    }
    
    var font: UIFont = Fonts.latoBoldFont(withSize: 14) {
        didSet {
            label.font = font
            setNeedsLayout()
        }
    }
    
    var image: UIImage? {
        didSet {
            updateButtonDisplay()
            setNeedsLayout()
        }
    }
    
    var foregroundImage: UIImage? {
        didSet {
            foregroundImageView.image = foregroundImage
            setNeedsLayout()
        }
    }
    
    var imageSize = CGSize(width: 20, height: 20) {
        didSet { setNeedsLayout() }
    }
    
    var foregroundImageSize = CGSize(width: 20, height: 20) {
        didSet { setNeedsLayout() }
    }

    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16) {
        didSet { setNeedsLayout() }
    }
    
    var insetRight: CGFloat {
        get { return contentInset.right }
        set {
            var tempInset = contentInset
            tempInset.right = newValue
            contentInset = tempInset
            setNeedsLayout()
        }
    }
    
    var insetLeft: CGFloat {
        get { return contentInset.left }
        set {
            var tempInset = contentInset
            tempInset.left = newValue
            contentInset = tempInset
            setNeedsLayout()
        }
    }
    
    var insetTop: CGFloat {
        get { return contentInset.top }
        set {
            var tempInset = contentInset
            tempInset.top = newValue
            contentInset = tempInset
            setNeedsLayout()
        }
    }
    
    var insetBottom: CGFloat {
        get { return contentInset.bottom }
        set {
            var tempInset = contentInset
            tempInset.bottom = newValue
            contentInset = tempInset
            setNeedsLayout()
        }
    }
    
    var imageTitleMargin: CGFloat = 12.0 {
        didSet { setNeedsLayout() }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            if let backgroundColor = backgroundColor {
                backgroundColors[.normal] = backgroundColor
                backgroundColors[.highlighted] = backgroundColor.highlightColor()
            } else {
                backgroundColors.removeAll()
            }
            updateButtonDisplay()
        }
    }
    
    var foregroundColor: UIColor? {
        set {
            foregroundColors[.normal] = newValue
            foregroundColors[.highlighted] = newValue?.highlightColor() ?? newValue
            updateButtonDisplay()
        }
        get { return foregroundColors[.normal] }
    }
    
    var imageIgnoresForegroundColor: Bool = false {
        didSet {
            updateButtonDisplay()
        }
    }
    
    var currentState: ButtonState {
        if isTouching {
            return .highlighted
        } else {
            return .normal
        }
    }
    
    var adjustsOpacityForState: Bool = false {
        didSet {
            updateButtonDisplay()
        }
    }
    
    var onTap: (() -> Void)?
    
    // MARK: Private Properties
    
    fileprivate let contentView = UIView()
    
    fileprivate let label = UILabel()
    
    fileprivate let imageView = UIImageView()
    
    fileprivate let foregroundImageView = UIImageView()
    
    fileprivate var isTouching = false {
        didSet {
            updateButtonDisplay()
        }
    }
    
    fileprivate var backgroundColors = [ButtonState: UIColor]()
    
    fileprivate var foregroundColors: [ButtonState: UIColor] = [
        .normal: UIColor(red: 0.226, green: 0.605, blue: 0.852, alpha: 1),
        .highlighted: UIColor(red: 0.226, green: 0.605, blue: 0.852, alpha: 1)
    ]
    
    // MARK: Initialization
    
    func commonInit() {
        self.isAccessibilityElement = true
        self.accessibilityTraits = UIAccessibilityTraitButton
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        foregroundImageView.contentMode = .scaleAspectFit
        foregroundImageView.clipsToBounds = true
        contentView.addSubview(foregroundImageView)
        
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .left
        label.clipsToBounds = true
        contentView.addSubview(label)
        
        addSubview(contentView)
        
        updateButtonDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Property Setters / Getters
    
    func setBackgroundColor(_ color: UIColor?, forState state: ButtonState) {
        backgroundColors[state] = color
        if state == currentState {
            updateButtonDisplay()
        }
    }
    
    func backgroundColorForState(_ state: ButtonState) -> UIColor? {
        return backgroundColors[state]
    }
    
    func setForegroundColor(_ color: UIColor?, forState state: ButtonState) {
        foregroundColors[state] = color
        if state == currentState {
            updateButtonDisplay()
        }
    }
    
    func foregroundColorForState(_ state: ButtonState) -> UIColor? {
        return foregroundColors[state]
    }
}

// MARK:- Display

extension Button {
    func updateButtonDisplay() {
        if let bgColor = backgroundColorForState(currentState) {
            contentView.backgroundColor = bgColor
        }
        
        if let fgColor = foregroundColorForState(currentState) {
            label.textColor = fgColor
            
            if imageIgnoresForegroundColor {
                imageView.image = image
            } else {
                imageView.image = image?.tinted(fgColor)
            }
        }
        
        if adjustsOpacityForState {
            if currentState == .highlighted {
                contentView.alpha = 0.5
            } else {
                contentView.alpha = 1.0
            }
        } else {
            contentView.alpha = 1.0
        }
    }
}

// MARK:- Layout

extension Button {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = bounds
        
        let width = bounds.width
        let maxContentWidth = width - contentInset.left - contentInset.right
        let maxContentHeight = bounds.height - contentInset.top - contentInset.bottom
        
        var imageWidth: CGFloat = 0.0
        var imageMargin: CGFloat  = 0.0
        if image != nil {
            imageWidth = imageSize.width
        }
        let imageTop = floor((bounds.height - imageSize.height) / 2.0)
        
        let maxTitleWidth = maxContentWidth - imageWidth - imageMargin
        let titleSize = label.sizeThatFits(CGSize(width: maxTitleWidth, height: maxContentHeight))
        let titleWidth = min(maxTitleWidth, ceil(titleSize.width))
        if titleWidth > 0 && imageWidth > 0 {
            imageMargin = imageTitleMargin
        }
        let titleHeight = ceil(titleSize.height)
        let titleTop = floor((bounds.height - titleHeight) / 2.0)
        
        let contentWidth = titleWidth + imageWidth + imageMargin
        let contentLeft = floor((bounds.width - contentWidth) / 2.0)
        
        imageView.frame = CGRect(x: contentLeft, y: imageTop, width: imageWidth, height: imageSize.height)
        foregroundImageView.frame = CGRect(x: 0, y: 0, width: foregroundImageSize.width, height: foregroundImageSize.height)
        foregroundImageView.center = CGPoint(x: imageView.frame.midX,
                                             y: imageView.frame.midY)
        label.frame = CGRect(x: contentLeft + imageWidth + imageMargin, y: titleTop, width: titleWidth, height: titleHeight)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var maxContentWidth: CGFloat
        if size.width.isZero {
            maxContentWidth = CGFloat.greatestFiniteMagnitude
        } else {
            maxContentWidth = max(0, size.width - contentInset.left - contentInset.right)
        }
        
        var maxContentHeight: CGFloat
        if size.height.isZero {
            maxContentHeight = CGFloat.greatestFiniteMagnitude
        } else {
            maxContentHeight = max(0, size.height - contentInset.top - contentInset.bottom)
        }
        
        var contentWidth: CGFloat = 0.0
        var contentHeight: CGFloat = 0.0
        if image != nil {
            contentWidth += imageSize.width
            contentHeight = imageSize.height
        }
        
        let maxTitleWidth = max(0, maxContentWidth - contentWidth)
        var titleSize = label.sizeThatFits(CGSize(width: maxTitleWidth, height: maxContentHeight))
        titleSize.width = ceil(min(maxTitleWidth, titleSize.width))
        
        contentWidth += ceil(titleSize.width)
        if titleSize.width > 0 && image != nil {
            contentWidth += imageTitleMargin
        }
        contentHeight = max(contentHeight, ceil(titleSize.height))
        
        return CGSize(width: contentWidth + contentInset.left + contentInset.right,
                      height: contentHeight + contentInset.top + contentInset.bottom)
    }
}

// MARK:- Touches

extension Button {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchesInBounds(touches) {
            isTouching = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTouching && !touchesInBounds(touches) {
            touchesCancelled(touches, with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTouching && touchesInBounds(touches) {
            didTap()
        }
        isTouching = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        isTouching = false
    }
    
    // MARK: Utilies
    
    func touchesInBounds(_ touches: Set<UITouch>) -> Bool {
        guard let touch = touches.first else { return false }
        
        let touchLocation = touch.location(in: self)
        let extendedTouchRange: CGFloat = 30.0
        let touchableArea = bounds.insetBy(dx: -extendedTouchRange, dy: -extendedTouchRange)
        
        return touchableArea.contains(touchLocation)
    }
    
    // MARK: Public Methods
    
    func cancelTouches() {
        if isTouching {
            isTouching = false
        }
    }
}

// MARK:- Actions

extension Button {
    func didTap() {
        onTap?()
    }
}
