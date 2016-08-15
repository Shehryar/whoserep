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
        case Normal
        case Highlighted
    }
    
    // MARK: Public Properties
    
    var title: String? {
        didSet {
            label.text = title
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
    
    var imageSize = CGSize(width: 20, height: 20) {
        didSet { setNeedsLayout() }
    }
    
    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16) {
        didSet { setNeedsLayout() }
    }
    
    var imageTitleMargin: CGFloat = 12.0 {
        didSet { setNeedsLayout() }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            if let backgroundColor = backgroundColor {
                backgroundColors[.Normal] = backgroundColor
                backgroundColors[.Highlighted] = backgroundColor.highlightColor()
            } else {
                backgroundColors.removeAll()
            }
            updateButtonDisplay()
        }
    }
    
    var foregroundColor: UIColor? {
        set {
            foregroundColors[.Normal] = newValue
            foregroundColors[.Highlighted] = newValue
            updateButtonDisplay()
        }
        get { return foregroundColors[.Normal] }
    }
    
    var imageIgnoresForegroundColor: Bool = false {
        didSet {
            updateButtonDisplay()
        }
    }
    
    var currentState: ButtonState {
        if isTouching {
            return .Highlighted
        } else {
            return .Normal
        }
    }
    
    var onTap: (() -> Void)?
    
    // MARK: Private Properties
    
    private let contentView = UIView()
    
    private let label = UILabel()
    
    private let imageView = UIImageView()
    
    private var isTouching = false {
        didSet {
            updateButtonDisplay()
        }
    }
    
    private var backgroundColors = [ButtonState : UIColor]()
    
    private var foregroundColors: [ButtonState : UIColor] = [
        .Normal : Colors.blueColor(),
        .Highlighted : Colors.blueColor()
    ]
    
    // MARK: Initialization
    
    func commonInit() {
        imageView.contentMode = .ScaleAspectFit
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        label.numberOfLines = 1
        label.textAlignment = .Left
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
    
    func setBackgroundColor(color: UIColor?, forState state: ButtonState) {
        backgroundColors[state] = color
        if state == currentState {
            updateButtonDisplay()
        }
    }
    
    func backgroundColorForState(state: ButtonState) -> UIColor? {
        return backgroundColors[state]
    }
    
    func setForegroundColor(color: UIColor?, forState state: ButtonState) {
        foregroundColors[state] = color
        if state == currentState {
            updateButtonDisplay()
        }
    }
    
    func foregroundColorForState(state: ButtonState) -> UIColor? {
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
                imageView.image = image?.fillAlpha(fgColor)
            }
        }
    }
}

// MARK:- Layout

extension Button {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = bounds
        
        let width = CGRectGetWidth(bounds)
        let maxContentWidth = width - contentInset.left - contentInset.right
        let maxContentHeight = CGRectGetHeight(bounds) - contentInset.top - contentInset.bottom
        
        var imageWidth: CGFloat = 0.0
        var imageMargin: CGFloat  = 0.0
        if image != nil {
            imageWidth = imageSize.width
            imageMargin = imageTitleMargin
        }
        let imageTop = floor((CGRectGetHeight(bounds) - imageSize.height) / 2.0)
        
        let maxTitleWidth = maxContentWidth - imageWidth - imageMargin
        let titleSize = label.sizeThatFits(CGSize(width: maxTitleWidth, height: maxContentHeight))
        let titleWidth = ceil(titleSize.width)
        let titleHeight = ceil(titleSize.height)
        let titleTop = floor((CGRectGetHeight(bounds) - titleHeight) / 2.0)
        
        let contentWidth = titleWidth + imageWidth + imageMargin
        let contentLeft = floor((CGRectGetWidth(bounds) - contentWidth) / 2.0)
        
        imageView.frame = CGRect(x: contentLeft, y: imageTop, width: imageWidth, height: imageSize.height)
        label.frame = CGRect(x: contentLeft + imageWidth + imageMargin, y: titleTop, width: titleWidth, height: titleHeight)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        var maxContentWidth: CGFloat
        if size.width.isZero {
            maxContentWidth = CGFloat.max
        } else {
            maxContentWidth = max(0, size.width - contentInset.left - contentInset.right)
        }
        
        var maxContentHeight: CGFloat
        if size.height.isZero {
            maxContentHeight = CGFloat.max
        } else {
            maxContentHeight = max(0, size.height - contentInset.top - contentInset.bottom)
        }
        
        var contentWidth: CGFloat = 0.0
        var contentHeight: CGFloat = 0.0
        if image != nil {
            contentWidth += imageSize.width + imageTitleMargin
            contentHeight = imageSize.height
        }
        
        let maxTitleWidth = max(0, maxContentWidth - contentWidth)
        let titleSize = label.sizeThatFits(CGSize(width: maxTitleWidth, height: maxContentHeight))
        
        contentWidth += ceil(titleSize.width)
        contentHeight = max(contentHeight, ceil(titleSize.height))
        
        return CGSize(width: contentWidth + contentInset.left + contentInset.right,
                      height: contentHeight + contentInset.top + contentInset.bottom)
    }
}

// MARK:- Touches

extension Button {
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touchesInBounds(touches) {
            isTouching = true
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isTouching && !touchesInBounds(touches) {
            touchesCancelled(touches, withEvent: event)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isTouching && touchesInBounds(touches) {
            didTap()
        }
        isTouching = false
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        isTouching = false
    }
    
    // MARK: Utilies
    
    func touchesInBounds(touches: Set<UITouch>) -> Bool {
        guard let touch = touches.first else { return false }
        
        let touchLocation = touch.locationInView(self)
        let extendedTouchRange: CGFloat = 30.0
        let touchableArea = CGRectInset(bounds, -extendedTouchRange, -extendedTouchRange)
        
        return CGRectContainsPoint(touchableArea, touchLocation)
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
