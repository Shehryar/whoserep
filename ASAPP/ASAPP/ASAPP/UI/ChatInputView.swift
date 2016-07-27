//
//  ChatInputView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol ChatInputViewDelegate {
    func chatInputView(chatInputView: ChatInputView, didTapSendMessage message: String)
    func chatInputViewDidChangeContentSize(chatInputView: ChatInputView)
}

class ChatInputView: UIView {

    // MARK: Public Properties
    
    var delegate: ChatInputViewDelegate?
    
    var canSendMessage: Bool = true {
        didSet {
            updateSendButtonForCurrentState()
        }
    }
    
    // MARK: Properties: Data
    
    let inputMinHeight: CGFloat = 36
    let inputMaxHeight: CGFloat = 150
    var inputHeight: CGFloat = 0
    
    // MARK: Properties: UI
    
    let borderTopView = UIView()
    let textView = UITextView()
    let placeholderTextView = UITextView()
    
    let mediaButton = UIButton()
    let sendButton = UIButton()
    
    // MARK:- Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = Colors.whiteColor()
        translatesAutoresizingMaskIntoConstraints = false
        
        borderTopView.backgroundColor = Colors.lightGrayColor()
        addSubview(borderTopView)
        
        styleTextView()
        textView.delegate = self
        addSubview(textView)
        addSubview(placeholderTextView)
        
        styleMediaButton()
        addSubview(mediaButton)
        
        styleSendButton()
        updateSendButtonForCurrentState()
        addSubview(sendButton)
    }
    
    deinit {
        textView.delegate = nil
    }
    
    // MARK:- Appearance
    
    func styleTextView() {
        textView.backgroundColor = UIColor.whiteColor()
        textView.tintColor = Colors.grayColor()
        textView.font = Fonts.latoRegularFont(withSize: 16)
        textView.textColor = Colors.darkTextColor()
        textView.bounces = false
        textView.scrollEnabled = false
        textView.scrollsToTop = false
        textView.textContainer.lineFragmentPadding = 0

        textView.sizeToFit()
        inputHeight = textView.frame.size.height
        
        placeholderTextView.text = "Enter message here..." // TODO: Localization
        placeholderTextView.backgroundColor = UIColor.clearColor()
        placeholderTextView.font = textView.font
        placeholderTextView.textColor = textView.tintColor
        placeholderTextView.userInteractionEnabled = false
        placeholderTextView.scrollsToTop = false
        placeholderTextView.scrollEnabled = false
        placeholderTextView.textContainer.lineFragmentPadding = 0
    }
    
    func styleSendButton() {
        let normalAttributes = [
            NSKernAttributeName : 1.5,
            NSForegroundColorAttributeName : Colors.mediumTextColor(),
            NSFontAttributeName : Fonts.latoBlackFont(withSize: 13)
        ]
        let highlightedAttributes = [
            NSKernAttributeName : 1.5,
            NSForegroundColorAttributeName : Colors.mediumTextColor().colorWithAlphaComponent(0.7),
            NSFontAttributeName : Fonts.latoBlackFont(withSize: 13)
        ]
        let disabledAttributes = [
            NSKernAttributeName : 1.5,
            NSForegroundColorAttributeName : Colors.mediumTextColor().colorWithAlphaComponent(0.4),
            NSFontAttributeName : Fonts.latoBlackFont(withSize: 13)
        ]
        let buttonTitle = "SEND" // TODO: Localization
        sendButton.setAttributedTitle(NSAttributedString(string: buttonTitle, attributes: normalAttributes), forState: .Normal)
        sendButton.setAttributedTitle(NSAttributedString(string: buttonTitle, attributes: highlightedAttributes), forState: .Highlighted)
        sendButton.setAttributedTitle(NSAttributedString(string: buttonTitle, attributes: disabledAttributes), forState: .Disabled)
        sendButton.addTarget(self, action: #selector(ChatInputView.didTapSendButton(_:)), forControlEvents: .TouchUpInside)
    }
    
    func updateSendButtonForCurrentState() {
        sendButton.enabled = !textView.text.isEmpty && canSendMessage
    }
    
    func styleMediaButton() {
        mediaButton.setImage(Images.cameraIconDark(fillColor: Colors.mediumTextColor(), alpha: 1), forState: .Normal)
        mediaButton.setImage(Images.cameraIconDark(fillColor: Colors.mediumTextColor(), alpha: 0.7), forState: .Highlighted)
        mediaButton.setImage(Images.cameraIconDark(fillColor: Colors.mediumTextColor(), alpha: 0.4), forState: .Disabled)
    }
    
    // MARK:- Button Actions
    
    func didTapSendButton(sender: UIButton) {
        if let messageText = textView.text {
            delegate?.chatInputView(self, didTapSendMessage: messageText)
        }
    }
}

// MARK:- Layout

extension ChatInputView {
    override func updateConstraints() {
        borderTopView.snp_remakeConstraints { (make) in
            make.left.equalTo(self.snp_left)
            make.right.equalTo(self.snp_right)
            make.top.equalTo(self.snp_top)
            make.height.equalTo(1)
        }
        
        mediaButton.snp_remakeConstraints { (make) in
            make.leading.equalTo(self.snp_leading).offset(16)
            make.bottom.equalTo(self.snp_bottom).offset(-8)
            make.height.equalTo(inputMinHeight)
            make.width.equalTo(28)
        }
        
        sendButton.snp_remakeConstraints { (make) in
            make.bottom.equalTo(mediaButton.snp_bottom)
            make.trailing.equalTo(self.snp_trailing).offset(-16)
            make.height.equalTo(inputMinHeight)
            make.width.equalTo(40)
        }
        
        textView.snp_remakeConstraints { (make) in
            make.top.equalTo(self.snp_top).offset(8)
            make.leading.equalTo(mediaButton.snp_trailing).offset(16)
            make.bottom.equalTo(mediaButton.snp_bottom)
            make.trailing.equalTo(sendButton.snp_leading).offset(-16)
            make.width.greaterThanOrEqualTo(1)
            make.height.equalTo(inputHeight)
        }
        
        placeholderTextView.snp_remakeConstraints { (make) in
            make.edges.equalTo(textView)
        }
        
        super.updateConstraints()
    }
}

// MARK:- UITextViewDelegate

extension ChatInputView: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        resizeIfNeeded()
        updateSendButtonForCurrentState()
        
        placeholderTextView.hidden = !textView.text.isEmpty
    }
    
    func resizeIfNeeded() {
        var height = textView.sizeThatFits(CGSize(width: CGRectGetWidth(textView.bounds), height: inputMaxHeight)).height
        if height < inputMinHeight {
            height = inputMinHeight
        }
        if height > inputMaxHeight {
            height = inputMaxHeight
            textView.scrollEnabled = true
            textView.bounces = true
        } else {
            textView.scrollEnabled = false
            textView.bounces = false
        }
        
        if height != inputHeight {
            inputHeight = height
            
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
            UIView.animateWithDuration(0.2) {
                self.layoutIfNeeded()
            }
            
            delegate?.chatInputViewDidChangeContentSize(self)
        }
    }
}

// MARK:- Public Instance Methods

extension ChatInputView {
    func clear() {
        textView.text = ""
        resizeIfNeeded()
        updateSendButtonForCurrentState()
    }
}
