//
//  TextInputView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TextInputView: BaseComponentView, InvalidatableInput {

    let textInputView = PlaceholderTextInputView()
    
    let errorLabel = UILabel()
    
    lazy var errorIcon: UIImageView = {
        return UIImageView(image: ComponentIcon.getImage(.notificationAlert)?.tinted(UIColor.ASAPP.errorRed))
    }()
    
    var isInvalid: Bool = false {
        didSet {
            textInputView.invalid = isInvalid
        }
    }
    
    private var errorLabelHeight: CGFloat {
        let width = UIEdgeInsetsInsetRect(bounds, component?.style.padding ?? .zero).width
        let errorLabelSize = errorLabel.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        return errorLabelSize.height
    }
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            textInputView.text = nil
            textInputView.placeholderText = nil
            
            if let textInputItem = textInputItem {
                if let value = textInputItem.value as? NSNumber {
                    let formatter = NumberFormatter()
                    formatter.minimumFractionDigits = 0
                    formatter.maximumFractionDigits = 2
                    textInputView.text = formatter.string(from: value)
                } else {
                    textInputView.text = textInputItem.value as? String
                }
                
                textInputView.placeholderText = textInputItem.placeholder
                textInputView.textColor = textInputItem.style.color ?? ASAPP.styles.colors.textPrimary
                textInputView.font = ASAPP.styles.textStyles.style(for: textInputItem.style.textType).font
                textInputView.underlineColorDefault = ASAPP.styles.colors.controlSecondary
                textInputView.underlineStrokeWidth = 1
                textInputView.tintColor = ASAPP.styles.colors.controlTint
                textInputView.autocorrectionType = textInputItem.autocorrectionType
                textInputView.autocapitalizationType = textInputItem.autocapitalizationType
                textInputView.isSecureTextEntry = textInputItem.isSecure
                textInputView.keyboardType = textInputItem.keyboardType
                textInputView.characterLimit = textInputItem.maxLength
                textInputView.isRequired = textInputItem.isRequired ?? false
            }
        }
    }
    
    var textInputItem: TextInputItem? {
        return component as? TextInputItem
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        textInputView.onTextChange = { [weak self] (text) in
            self?.component?.value = text
            self?.clearError()
        }
        addSubview(textInputView)
        
        errorLabel.isHidden = true
        addSubview(errorLabel)
        
        errorIcon.isHidden = true
        addSubview(errorIcon)
    }
    
    // MARK: Layout
    
    private func bottomPaddingWithError(_ padding: UIEdgeInsets) -> CGFloat {
        return errorLabel.numberOfVisibleLines > 1
            ? errorLabelHeight + max(padding.bottom, errorLabel.font.lineHeight) - errorLabel.font.lineHeight
            : max(padding.bottom, errorLabelHeight)
    }
    
    override func updateFrames() {
        let errorIconSize = CGSize(width: 20, height: 20)
        
        var padding = component?.style.padding ?? .zero
        padding.bottom = bottomPaddingWithError(padding)
        
        textInputView.contentInset.right = errorIcon.isHidden ? 0 : errorIconSize.width
        textInputView.frame = UIEdgeInsetsInsetRect(bounds, padding)
        
        let errorLabelSize = errorLabel.sizeThatFits(CGSize(width: textInputView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        errorLabel.frame = CGRect(x: textInputView.frame.minX, y: textInputView.frame.maxY - textInputView.underlineMarginTop, width: errorLabelSize.width, height: errorLabelSize.height)
        
        let errorIconLeft = textInputView.frame.maxX - errorIconSize.width
        let errorIconTop = errorLabel.frame.minY - 5 - errorIconSize.height
        errorIcon.frame = CGRect(x: errorIconLeft, y: errorIconTop, width: errorIconSize.width, height: errorIconSize.height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let component = component else {
            return .zero
        }
        let padding = component.style.padding
        let bottom = bottomPaddingWithError(padding)
        
        let fitToWidth = max(0, (size.width > 0 ? size.width : CGFloat.greatestFiniteMagnitude) - padding.left - padding.right)
        let fitToHeight = max(0, (size.height > 0 ? size.height : CGFloat.greatestFiniteMagnitude) - padding.top - padding.bottom)
        guard fitToWidth > 0 && fitToHeight > 0 else {
            return .zero
        }
        
        let fittedInputSize = textInputView.sizeThatFits(CGSize(width: fitToWidth, height: fitToHeight))
        guard fittedInputSize.width > 0 && fittedInputSize.height > 0 else {
            return .zero
        }
        
        let fittedWidth = min(fitToWidth, fittedInputSize.width + padding.left + padding.right)
        let fittedHeight = min(fitToHeight - padding.bottom, fittedInputSize.height + padding.top) + bottom
        
        return CGSize(width: fittedWidth, height: fittedHeight)
    }
}
