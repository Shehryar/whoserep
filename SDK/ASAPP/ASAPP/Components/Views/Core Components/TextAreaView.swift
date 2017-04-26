//
//  TextAreaView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/12/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TextAreaView: BaseComponentView {

    let textView = UITextView()
    
    let placeholderTextView = UITextView()
    
    let underlineView = UIView()
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            textView.text = nil
            placeholderTextView.text = nil
            
            if let textAreaItem = textAreaItem {
                textView.text = textAreaItem.value as? String
                placeholderTextView.text = textAreaItem.placeholder
                
                styleTextView(textView, for: textAreaItem, isPlaceholder: false)
                styleTextView(placeholderTextView, for: textAreaItem, isPlaceholder: true)
            }
        }
    }
    
    var textAreaItem: TextAreaItem? {
        return component as? TextAreaItem
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
        
        underlineView.backgroundColor = ASAPP.styles.colors.controlSecondary
        addSubview(underlineView)
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
    
    override func updateFrames() {
        guard let component = component else {
            return
        }
        
        let padding = component.style.padding
        let textViewFrame = UIEdgeInsetsInsetRect(bounds, padding)
        let offset = textView.contentOffset
        textView.frame = textViewFrame
        textView.setContentOffset(offset, animated: false)
        placeholderTextView.frame = textViewFrame
        
        let lineLeft = padding.left
        let lineWidth = bounds.width - padding.right - lineLeft
        let lineStroke: CGFloat = 1
        let lineTop = bounds.height - padding.bottom - lineStroke
        underlineView.frame = CGRect(x: lineLeft, y: lineTop, width: lineWidth, height: lineStroke)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let textAreaItem = textAreaItem else {
            return .zero
        }
        let padding = textAreaItem.style.padding
    
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
        let fittedHeight = min(fitToHeight, fittedInputSize.height + padding.top + padding.bottom)
        return CGSize(width: fittedWidth, height: fittedHeight)
    }
}

extension TextAreaView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        component?.value = textView.text
        
        placeholderTextView.isHidden = !self.textView.text.isEmpty
        contentHandler?.componentView(self,
                                      didUpdateContent: textView.text,
                                      requiresLayoutUpdate: true)
    }
}
