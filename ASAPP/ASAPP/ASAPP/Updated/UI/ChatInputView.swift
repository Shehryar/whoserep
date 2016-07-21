//
//  ChatInputView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatInputView: UIView {

    // MARK: Public Properties
    
    public var onSendButtonTap: ((messageText: String) -> ())?
    
    // MARK: Properties: Data
    
    let inputMinHeight: CGFloat = 32
    let inputMaxHeight: CGFloat = 150
    var inputHeight: CGFloat = 0
    
    // MARK: Properties: UI
    
    let borderTopView = UIView()
    let textView = UITextView()
    let mediaButton = UIButton()
    let sendButton = UIButton()
    
    // MARK:- Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Colors.offWhiteColor()
        translatesAutoresizingMaskIntoConstraints = false
        
        borderTopView.backgroundColor = Colors.lightGrayColor()
        addSubview(borderTopView)
        
        styleTextView()
        textView.delegate = self
        addSubview(textView)
        
        styleMediaButton()
        addSubview(mediaButton)
        
        styleSendButton()
        addSubview(sendButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        textView.delegate = nil
    }
    
    // MARK:- Appearance
    
    func styleTextView() {
        textView.layer.cornerRadius = 4
        textView.layer.borderColor = Colors.lightGrayColor().CGColor
        textView.layer.borderWidth = 1
        textView.backgroundColor = UIColor.whiteColor()
        textView.tintColor = Colors.grayColor()
        textView.font = Fonts.latoRegularFont(withSize: 16)
        textView.textColor = Colors.mediumTextColor()
        textView.bounces = false
        textView.scrollEnabled = false
        textView.scrollsToTop = false
        textView.sizeToFit()
        inputHeight = textView.frame.size.height
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
    
    func styleMediaButton() {
        mediaButton.setImage(Images.cameraIconDark(fillColor: Colors.mediumTextColor(), alpha: 1), forState: .Normal)
        mediaButton.setImage(Images.cameraIconDark(fillColor: Colors.mediumTextColor(), alpha: 0.7), forState: .Highlighted)
        mediaButton.setImage(Images.cameraIconDark(fillColor: Colors.mediumTextColor(), alpha: 0.4), forState: .Disabled)
    }
    
    // MARK:- Button Actions
    
    func didTapSendButton(sender: UIButton) {
        if let onSendButtonTap = onSendButtonTap, let messageText = textView.text {
            onSendButtonTap(messageText: messageText)
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
        
        super.updateConstraints()
    }
}

// MARK:- UITextViewDelegate

extension ChatInputView: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        resizeIfNeeded()
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
        }
    }
}

// MARK:- Public Instance Methods

extension ChatInputView {
    public func clear() {
        textView.text = ""
        resizeIfNeeded()
    }
}
