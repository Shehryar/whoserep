//
//  TextInputView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TextInputView: BaseComponentView {

    let textInputView = PlaceholderTextInputView()
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            textInputView.text = nil
            textInputView.placeholderText = nil
            
            if let textInputItem = textInputItem {
                textInputView.placeholderText = textInputItem.placeholder
                textInputView.textColor = textInputItem.style.color ?? TextInputItem.defaultColor
                textInputView.font = ASAPP.styles.font(with: textInputItem.style.fontWeight,
                                                       size: textInputItem.style.fontSize)
                
                textInputView.autocorrectionType = textInputItem.autocorrectionType
                textInputView.autocapitalizationType = textInputItem.autocapitalizationType
                textInputView.isSecureTextEntry = textInputItem.isSecure
                textInputView.keyboardType = textInputItem.keyboardType
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
        }
        addSubview(textInputView)
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding = component?.style.padding ?? .zero
        textInputView.frame = UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let component = component else {
            return .zero
        }
        let padding = component.style.padding
        
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
        let fittedHeight = min(fitToHeight, fittedInputSize.height + padding.top + padding.bottom)
        return CGSize(width: fittedWidth, height: fittedHeight)
    }
}
