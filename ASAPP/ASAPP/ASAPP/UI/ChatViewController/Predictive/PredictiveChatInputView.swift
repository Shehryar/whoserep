//
//  PredictiveChatInputView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class PredictiveChatInputView: UIView {
    
    private let contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

    private let textView = UITextView()
    
    private let placeholderTextView = UITextView()
    
    private var inputHeight: CGFloat = 0.0
    
    // MARK: Initialization
    
    func commonInit() {
        backgroundColor = Colors.steelDarkColor()
        layer.cornerRadius = 20
        
        styleTextView(textView)
        textView.delegate = self
        textView.sizeToFit()
        inputHeight = CGRectGetHeight(textView.bounds)
        addSubview(textView)
        
        styleTextView(placeholderTextView)
        placeholderTextView.userInteractionEnabled = false
        placeholderTextView.textColor = placeholderTextView.tintColor
        placeholderTextView.text = ASAPPLocalizedString("Ask a new question...")
        addSubview(placeholderTextView)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PredictiveChatInputView.beginTyping)))
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
        textView.delegate = nil
    }
    
    // MARK: Styles
    
    func styleTextView(textViewToStyle: UITextView) {
        textViewToStyle.backgroundColor = UIColor.clearColor()
        textViewToStyle.font = Fonts.latoRegularFont(withSize: 15)
        textViewToStyle.textColor = Colors.whiteColor()
        textViewToStyle.tintColor = Colors.whiteColor().colorWithAlphaComponent(0.7)
        textViewToStyle.bounces = false
        textViewToStyle.scrollEnabled = false
        textViewToStyle.scrollsToTop = false
        textViewToStyle.clipsToBounds = false
        textViewToStyle.textContainer.lineFragmentPadding = 0
        textViewToStyle.textContainerInset = UIEdgeInsetsZero
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentWidth = CGRectGetWidth(bounds) - contentInset.left - contentInset.right
        textView.frame = CGRect(x: contentInset.left, y: contentInset.top, width: contentWidth, height: inputHeight)
        placeholderTextView.frame = textView.frame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: inputHeight + contentInset.top + contentInset.bottom)
    }
    
    // MARK: Actions
    
    func beginTyping() {
        textView.becomeFirstResponder()
    }
}

extension PredictiveChatInputView: UITextViewDelegate {
    
}
