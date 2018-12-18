//
//  TextAreaView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/12/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TextAreaView: BaseComponentView, InvalidatableInput {

    let textView = UITextView()
    
    let placeholderLabel = UILabel()
    
    let underlineView = UIView()
    
    let errorLabel = UILabel()
    
    lazy var errorIcon: UIImageView = {
        return UIImageView(image: ComponentIcon.getImage(.notificationAlert)?.tinted(UIColor.ASAPP.errorRed))
    }()
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            textView.text = nil
            placeholderLabel.text = nil
            
            if let textAreaItem = textAreaItem {
                textView.text = textAreaItem.value as? String
                placeholderText = textAreaItem.placeholder
                placeholderLabel.isHidden = !self.textView.text.isEmpty
                characterLimit = textAreaItem.maxLength
                isRequired = textAreaItem.isRequired ?? false
                underlineColorDefault = ASAPP.styles.colors.controlSecondary
                
                styleTextView(textView, for: textAreaItem, isPlaceholder: false)
            }
        }
    }
    
    var textAreaItem: TextAreaItem? {
        return component as? TextAreaItem
    }
    
    var isRequired = false {
        didSet {
            updatePlaceholderText()
        }
    }
    
    // Setting invalid shows the border error color until the text changes
    var isInvalid: Bool = false {
        didSet {
            updateUnderlineColor()
            updatePlaceholderText()
        }
    }
    
    // MARK: Placeholder
    
    var placeholderText: String? {
        didSet {
            updatePlaceholderText()
        }
    }
    
    let placeholderTextType = TextType.detail1
    
    var placeholderFont: UIFont = ASAPP.styles.textStyles.detail1.font
    
    var placeholderColor = ASAPP.styles.colors.dark.withAlphaComponent(0.5) {
        didSet {
            updatePlaceholderText()
        }
    }
    
    // MARK: Underline
    
    var underlineColorDefault = ASAPP.styles.colors.dark.withAlphaComponent(0.15) {
        didSet {
            updateUnderlineColor()
        }
    }
    
    var underlineColorHighlighted: UIColor? {
        didSet {
            updateUnderlineColor()
        }
    }
    
    var underlineColorError: UIColor? = UIColor.ASAPP.errorRed {
        didSet {
            updateUnderlineColor()
        }
    }
    
    var underlineMarginTop: CGFloat = 3.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var characterLimit: Int?
    private var previousTextContent: String?
    
    private var errorLabelHeight: CGFloat {
        let width = bounds.inset(by: component?.style.padding ?? .zero).width
        let errorLabelSize = errorLabel.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        return errorLabelSize.height
    }
    
    private let errorIconSize = CGSize(width: 19.5, height: 19.5)
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        textView.delegate = self
        textView.scrollsToTop = false
        textView.textContainerInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        textView.textContainer.lineFragmentPadding = .leastNonzeroMagnitude
        addSubview(textView)
        
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.font = placeholderFont
        placeholderLabel.adjustsFontSizeToFitWidth = true
        placeholderLabel.minimumScaleFactor = 0.5
        addSubview(placeholderLabel)
        
        updateUnderlineColor()
        addSubview(underlineView)
        
        errorLabel.isHidden = true
        addSubview(errorLabel)
        
        errorIcon.isHidden = true
        addSubview(errorIcon)
        
        isAccessibilityElement = false
        accessibilityElements = [textView, errorLabel]
    }
    
    deinit {
        textView.delegate = nil
    }
    
    // MARK: Styling
    
    func styleTextView(_ textView: UITextView, for textAreaItem: TextAreaItem, isPlaceholder: Bool) {
        textView.tintColor = ASAPP.styles.colors.controlTint
        textView.applyTextType(textAreaItem.style.textType, color: textAreaItem.style.color)
    }
    
    // MARK: Layout
    
    struct CalculatedLayout {
        let underlineViewFrame: CGRect
        let textViewFrame: CGRect
        let placeholderLabelFrame: CGRect
        let errorLabelFrame: CGRect
        let errorIconFrame: CGRect
        
        static var zero: CalculatedLayout {
            return CalculatedLayout(
                underlineViewFrame: .zero,
                textViewFrame: .zero,
                placeholderLabelFrame: .zero,
                errorLabelFrame: .zero,
                errorIconFrame: .zero)
        }
    }
    
    private func getFramesThatFit(_ size: CGSize) -> CalculatedLayout {
        guard let textAreaItem = textAreaItem else {
            return .zero
        }
        
        var padding = textAreaItem.style.padding
        padding.top = max(placeholderFont.lineHeight, padding.top)
        
        let maxWidth = max(0, (size.width > 0 ? size.width : CGFloat.greatestFiniteMagnitude) - padding.left - padding.right)
        var maxHeight = (size.height > 0 ? size.height : CGFloat.greatestFiniteMagnitude)
        if textAreaItem.numberOfLines > 0 {
            maxHeight = (textView.font?.lineHeight ?? 18.0) * CGFloat(textAreaItem.numberOfLines) + textView.textContainerInset.top + textView.textContainerInset.bottom
        }
        maxHeight = max(0, maxHeight)
        
        let fittedInputSize = textView.sizeThatFits(CGSize(width: maxWidth, height: maxHeight))
        guard fittedInputSize.width > 0 && fittedInputSize.height > 0 else {
            return .zero
        }
        
        let fittedHeight = min(maxHeight, fittedInputSize.height)
        
        let iconPadding = errorIcon.isHidden ? 0 : errorIconSize.width
        let textViewFrame = CGRect(x: padding.left, y: padding.top, width: maxWidth - iconPadding, height: fittedHeight)
        
        let lineLeft = padding.left
        let lineWidth = size.width - padding.right - lineLeft
        let lineStroke: CGFloat = 1
        let lineTop = textViewFrame.maxY //- padding.bottom - lineStroke
        let underlineViewFrame = CGRect(x: lineLeft, y: lineTop, width: lineWidth, height: lineStroke)
        
        let textBottom = lineTop - underlineMarginTop
        let placeholderTop: CGFloat
        if textView.text?.isEmpty ?? true {
            placeholderTop = textBottom - placeholderFont.lineHeight
        } else {
            placeholderTop = textViewFrame.minY - placeholderFont.lineHeight
        }
        let placeholderLabelFrame = CGRect(x: textViewFrame.minX, y: placeholderTop, width: textViewFrame.width, height: placeholderFont.lineHeight)
        
        let errorTop: CGFloat = underlineViewFrame.maxY
        let errorLabelSize = errorLabel.sizeThatFits(CGSize(width: lineWidth, height: CGFloat.greatestFiniteMagnitude))
        let errorLabelFrame = CGRect(x: textViewFrame.minX, y: errorTop, width: errorLabelSize.width, height: errorLabelSize.height)
        
        let errorIconLeft = underlineViewFrame.maxX - errorIconSize.width
        let errorIconTop = errorLabelFrame.minY - 5 - errorIconSize.height
        let errorIconFrame = CGRect(x: errorIconLeft, y: errorIconTop, width: errorIconSize.width, height: errorIconSize.height)
        
        return CalculatedLayout(
            underlineViewFrame: underlineViewFrame,
            textViewFrame: textViewFrame,
            placeholderLabelFrame: placeholderLabelFrame,
            errorLabelFrame: errorLabelFrame,
            errorIconFrame: errorIconFrame)
    }
    
    override func updateFrames() {
        let layout = getFramesThatFit(bounds.size)
        
        underlineView.frame = layout.underlineViewFrame
        textView.frame = layout.textViewFrame
        placeholderLabel.frame = layout.placeholderLabelFrame
        errorLabel.frame = layout.errorLabelFrame
        errorIcon.frame = layout.errorIconFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getFramesThatFit(size)
        
        let padding = textAreaItem?.style.padding ?? .zero
        let height = max(layout.errorLabelFrame.maxY, layout.underlineViewFrame.maxY) + padding.bottom
        return CGSize(width: size.width, height: height)
    }
    
    // MARK: Updating Color
    
    func updateUnderlineColor(animated: Bool = false) {
        func updateBlock() {
            var underlineColor: UIColor?
            if isInvalid {
                underlineColor = underlineColorError
            } else if textView.isFirstResponder {
                underlineColor = underlineColorHighlighted
            }
            
            underlineView.backgroundColor = underlineColor ?? underlineColorDefault
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: updateBlock)
        } else {
            updateBlock()
        }
    }
    
    // MARK: Updating Placeholder Text
    
    func updatePlaceholderText() {
        if var placeholderText = placeholderText {
            var plainPlaceholder = placeholderText
            let requiredSuffix = " *"
            if isRequired {
                if !placeholderText.hasSuffix(requiredSuffix) {
                    placeholderText.append(requiredSuffix)
                } else {
                    plainPlaceholder.removeLast(requiredSuffix.count)
                }
            } else {
                if placeholderText.hasSuffix(requiredSuffix) {
                    placeholderText.removeLast(requiredSuffix.count)
                    plainPlaceholder = placeholderText
                }
            }
            
            placeholderLabel.setAttributedText(placeholderText, textType: placeholderTextType, color: placeholderColor)
            placeholderFont = ASAPP.styles.textStyles.style(for: placeholderTextType).font
            
            let prefix = isRequired ? ASAPPLocalizedString("Required: ") : ""
            textView.accessibilityLabel = "\(prefix)\(plainPlaceholder)"
        } else {
            placeholderLabel.attributedText = nil
            textView.accessibilityLabel = ASAPPLocalizedString("Text area")
        }
        
    }
}

extension TextAreaView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        clearError()
        
        var text = textView.text
        
        if let characterLimit = characterLimit,
           textView.text.count > characterLimit {
            text = previousTextContent
        }
        
        textView.text = text
        component?.value = text
        
        UIView.animate(withDuration: 0.15) { [weak self] in
            let offset = self?.textView.contentOffset ?? .zero
            self?.updateFrames()
            self?.textView.setContentOffset(offset, animated: false)
        }
        
        contentHandler?.componentView(self, didUpdateContent: text, requiresLayoutUpdate: true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        previousTextContent = textView.text
        return true
    }
}
