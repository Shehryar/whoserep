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
    
    var contentAlignment: NSTextAlignment = .center {
        didSet {
            setNeedsLayout()
        }
    }
    
    var title: String? {
        didSet {
            label.text = title
            accessibilityLabel = title
            setNeedsLayout()
        }
    }
    
    var font: UIFont = Fonts.default.bold.changingOnlySize(14) {
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
        if isTouching || isHighlighted {
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
    
    var isHighlighted = false
    
    var contentView: UIView
    
    let label = UILabel()
    
    let imageView = UIImageView()
    
    // MARK: Private Properties
    
    private let foregroundImageView = UIImageView()
    
    private var isTouching = false {
        didSet {
            updateButtonDisplay()
        }
    }
    
    private var backgroundColors = [ButtonState: UIColor]()
    
    private var foregroundColors: [ButtonState: UIColor] = [
        .normal: UIColor(red: 0.226, green: 0.605, blue: 0.852, alpha: 1),
        .highlighted: UIColor(red: 0.226, green: 0.605, blue: 0.852, alpha: 1)
    ]
    
    // MARK: Initialization
    
    func commonInit() {
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraits.button
        
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        
        foregroundImageView.contentMode = .scaleAspectFit
        foregroundImageView.clipsToBounds = true
        contentView.addSubview(foregroundImageView)
        
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .left
        contentView.addSubview(label)
        
        addSubview(contentView)
        
        updateButtonDisplay()
    }
    
    override init(frame: CGRect) {
        contentView = UIView()
        
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        contentView = UIView()
        
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
    
    func updateBackgroundColor() {
        if let bgColor = backgroundColorForState(currentState) {
            contentView.backgroundColor = bgColor
        }
    }
    
    func touchesInBounds(_ touches: Set<UITouch>) -> Bool {
        guard let touch = touches.first else { return false }

        let touchLocation = touch.location(in: self)
        let extendedTouchRange: CGFloat = 30.0
        let touchableArea = bounds.insetBy(dx: -extendedTouchRange, dy: -extendedTouchRange)

        return touchableArea.contains(touchLocation)
    }
}

// MARK: - Display

extension Button {
    func updateButtonDisplay() {
        updateBackgroundColor()
        
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

// MARK: - Layout

extension Button {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = bounds
        
        let layout = getFramesThatFit(bounds.size)
        imageView.frame = layout.imageFrame
        foregroundImageView.frame = layout.foregroundImageFrame
        label.frame = layout.labelFrame
    }
    
    private struct CalculatedLayout {
        let imageFrame: CGRect
        let foregroundImageFrame: CGRect
        let labelFrame: CGRect
    }
    
    private func getFramesThatFit(_ size: CGSize) -> CalculatedLayout {
        let width = size.width
        let maxContentWidth = width - contentInset.left - contentInset.right
        let maxContentHeight = size.height - contentInset.top - contentInset.bottom
        
        var imageWidth: CGFloat = 0.0
        var imageMargin: CGFloat = 0.0
        if image != nil {
            imageWidth = imageSize.width
            imageMargin = imageTitleMargin
        }
        let imageTop = floor((size.height - imageSize.height) / 2.0)
        
        let maxTitleWidth = maxContentWidth - imageWidth - imageMargin
        let titleSize = label.sizeThatFits(CGSize(width: maxTitleWidth, height: maxContentHeight))
        let titleWidth = min(maxTitleWidth, ceil(titleSize.width))
        
        let titleHeight = ceil(titleSize.height)
        let titleTop = floor((size.height - titleHeight) / 2.0)
        
        let contentWidth = titleWidth + imageWidth + imageMargin
        let contentLeft: CGFloat
        switch contentAlignment {
        case .left:
            contentLeft = contentInset.left
        case .right:
            contentLeft = max(contentInset.left, size.width - contentInset.right - contentWidth)
        case .justified, .natural, .center:
            contentLeft = floor((size.width - contentWidth) / 2)
        }
        
        let imageFrame = CGRect(x: contentLeft, y: imageTop, width: imageWidth, height: imageSize.height)
        
        let foregroundImageFrame = CGRect(x: (imageFrame.width - foregroundImageSize.width) / 2, y: (imageFrame.height - foregroundImageSize.height) / 2, width: foregroundImageSize.width, height: foregroundImageSize.height)
        
        let labelLeft = contentLeft + imageWidth + imageMargin
        let labelFrame = CGRect(x: labelLeft, y: titleTop, width: titleWidth, height: titleHeight)
        
        return CalculatedLayout(imageFrame: imageFrame, foregroundImageFrame: foregroundImageFrame, labelFrame: labelFrame)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getFramesThatFit(size)
        return CGSize(width: layout.labelFrame.maxX + contentInset.right, height: max(layout.imageFrame.height, layout.labelFrame.height) + contentInset.vertical)
    }
}

// MARK: - Touches

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
    
    // MARK: Public Methods
    
    func cancelTouches() {
        if isTouching {
            isTouching = false
        }
    }
}

// MARK: - Actions

extension Button {
    func didTap() {
        onTap?()
    }
}
