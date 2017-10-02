//
//  TextViewAutoExpanding.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/11/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol TextViewAutoExpanding: class {
    var inputMaxHeight: CGFloat { get }
    var inputMinHeight: CGFloat { get set }
    var inputHeight: CGFloat { get set }
    var textView: UITextView { get }
    
    func updateInputMinHeight()
    func textViewHeightDidChange()
    func resizeIfNeeded(animated: Bool, notifyOfHeightChange: Bool)
}

extension TextViewAutoExpanding where Self: UIView {
    func updateInputMinHeight() {
        let textViewText = textView.text
        textView.text = nil
        resizeIfNeeded(animated: false)
        inputMinHeight = inputHeight
        textView.text = textViewText
        setNeedsLayout()
    }
    
    func textViewHeightDidChange() {}
    
    func resizeIfNeeded(animated: Bool, notifyOfHeightChange: Bool = false) {
        var height = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: inputMaxHeight)).height
        if height > inputMaxHeight {
            height = inputMaxHeight
            textView.isScrollEnabled = true
            textView.bounces = true
        } else {
            textView.isScrollEnabled = false
            textView.bounces = false
        }
        
        if height != inputHeight {
            inputHeight = height
            
            if notifyOfHeightChange {
                textViewHeightDidChange()
            }
        }
    }
}
