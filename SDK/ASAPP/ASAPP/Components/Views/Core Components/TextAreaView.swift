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
    
    let placeholderTextView = UITextView()
    
    let underlineView = UIView()
    
    let errorLabel = UILabel()
    
    lazy var errorIcon: UIImageView = {
        return UIImageView(image: ComponentIcon.getImage(.alertError))
    }()
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            textView.text = nil
            placeholderTextView.text = nil
            
            if let textAreaItem = textAreaItem {
                textView.text = textAreaItem.value as? String
                placeholderText = textAreaItem.placeholder
                placeholderTextView.isHidden = !self.textView.text.isEmpty
                characterLimit = textAreaItem.maxLength
                isRequired = textAreaItem.isRequired ?? false
                underlineColorDefault = ASAPP.styles.colors.controlSecondary
                
                styleTextView(textView, for: textAreaItem, isPlaceholder: false)
                styleTextView(placeholderTextView, for: textAreaItem, isPlaceholder: true)
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
    
    var placeholderFont: UIFont = Fonts.default.bold.withSize(12) {
        didSet {
            updatePlaceholderText()
            setNeedsLayout()
        }
    }
    
    var placeholderColor: UIColor = UIColor(red: 0.663, green: 0.682, blue: 0.729, alpha: 1) {
        didSet {
            updatePlaceholderText()
        }
    }
    
    // MARK: Underline
    
    var underlineColorDefault: UIColor = UIColor(red: 0.663, green: 0.682, blue: 0.729, alpha: 1) {
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
    
    private var characterLimit: Int?
    private var previousTextContent: String?
    
    private var errorLabelHeight: CGFloat {
        let width = UIEdgeInsetsInsetRect(bounds, component?.style.padding ?? .zero).width
        let errorLabelSize = errorLabel.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        return errorLabelSize.height
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        textView.delegate = self
        textView.scrollsToTop = false
        addSubview(textView)
        
        placeholderTextView.backgroundColor = UIColor.clear
        placeholderTextView.scrollsToTop = false
        placeholderTextView.isUserInteractionEnabled = false
        addSubview(placeholderTextView)
        
        updateUnderlineColor()
        addSubview(underlineView)
        
        errorLabel.isHidden = true
        addSubview(errorLabel)
        
        errorIcon.isHidden = true
        addSubview(errorIcon)
    }
    
    deinit {
        textView.delegate = nil
    }
    
    // MARK: Styling
    
    func styleTextView(_ textView: UITextView, for textAreaItem: TextAreaItem, isPlaceholder: Bool) {
        textView.tintColor = ASAPP.styles.colors.controlTint
        
        let color = isPlaceholder ? ASAPP.styles.colors.textSecondary : textAreaItem.style.color
        textView.applyTextType(textAreaItem.style.textType, color: color)
    }
    
    // MARK: Layout
    
    private func bottomPaddingWithError(_ padding: UIEdgeInsets) -> CGFloat {
        return errorLabel.numberOfVisibleLines > 1
            ? errorLabelHeight + max(padding.bottom, errorLabel.font.lineHeight) - errorLabel.font.lineHeight + 3
            : max(padding.bottom, errorLabelHeight)
    }
    
    override func updateFrames() {
        guard let component = component else {
            return
        }
        
        let errorIconSize = CGSize(width: 20.5, height: 18)
        
        var padding = component.style.padding
        padding.bottom = bottomPaddingWithError(padding)
        
        let lineLeft = padding.left
        let lineWidth = bounds.width - padding.right - lineLeft
        let lineStroke: CGFloat = 1
        let lineTop = bounds.height - padding.bottom - lineStroke
        underlineView.frame = CGRect(x: lineLeft, y: lineTop, width: lineWidth, height: lineStroke)
        
        textView.contentInset.right = errorIcon.isHidden ? 0 : errorIconSize.width
        let textViewFrame = UIEdgeInsetsInsetRect(bounds, padding)
        let offset = textView.contentOffset
        textView.frame = textViewFrame
        textView.setContentOffset(offset, animated: false)
        placeholderTextView.frame = textViewFrame
        
        let errorTop: CGFloat = textView.frame.maxY + lineStroke
        let errorLabelSize = errorLabel.sizeThatFits(CGSize(width: lineWidth, height: CGFloat.greatestFiniteMagnitude))
        errorLabel.frame = CGRect(x: textView.frame.minX, y: errorTop, width: errorLabelSize.width, height: errorLabelSize.height)
        
        let errorIconLeft = underlineView.frame.maxX - errorIconSize.width
        let errorIconTop = errorLabel.frame.minY - 5 - errorIconSize.height
        errorIcon.frame = CGRect(x: errorIconLeft, y: errorIconTop, width: errorIconSize.width, height: errorIconSize.height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let textAreaItem = textAreaItem else {
            return .zero
        }
        let padding = textAreaItem.style.padding
        let bottom = bottomPaddingWithError(padding)
        
        let fitToWidth = max(0, (size.width > 0 ? size.width : CGFloat.greatestFiniteMagnitude) - padding.left - padding.right)
        var fitToHeight = max(0, (size.height > 0 ? size.height : CGFloat.greatestFiniteMagnitude) - padding.top - padding.bottom)
        if textAreaItem.numberOfLines > 0 {
            let maxHeight: CGFloat = (textView.font?.lineHeight ?? 18.0) * 3 + textView.textContainerInset.top + textView.textContainerInset.bottom
            fitToHeight = min(fitToHeight, maxHeight - padding.top - padding.bottom)
        }
        
        guard fitToWidth > 0 && fitToHeight > 0 else {
            return .zero
        }
        
        let fittedInputSize = textView.sizeThatFits(CGSize(width: fitToWidth, height: fitToHeight))
        guard fittedInputSize.width > 0 && fittedInputSize.height > 0 else {
            return .zero
        }
        
        let fittedWidth = min(fitToWidth, fittedInputSize.width + padding.left + padding.right)
        let fittedHeight = min(fitToHeight - padding.bottom, fittedInputSize.height + padding.top) + bottom
        
        return CGSize(width: fittedWidth, height: fittedHeight)
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
            let requiredSuffix = " *"
            if isRequired {
                if !placeholderText.hasSuffix(requiredSuffix) {
                    placeholderText.append(requiredSuffix)
                }
            } else {
                if placeholderText.hasSuffix(requiredSuffix) {
                    placeholderText.removeLast(requiredSuffix.count)
                }
            }
            placeholderTextView.setAttributedText(placeholderText, textType: .detail1, color: placeholderColor)
        } else {
            placeholderTextView.attributedText = nil
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
        
        placeholderTextView.isHidden = !(text ?? "").isEmpty
        contentHandler?.componentView(self,
                                      didUpdateContent: text,
                                      requiresLayoutUpdate: true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        previousTextContent = textView.text
        return true
    }
}
