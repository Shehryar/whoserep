//
//  ChatInputView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatInputView: UIView {

    // MARK: Properties: Data
    
    let INPUT_MIN_HEIGHT = 32
    let INPUT_MAX_HEIGHT = 80
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
        
        // TODO: call delegate or perform action
        
        textView.text = ""
        resizeIfNeeded(textView)
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
            make.height.equalTo(INPUT_MIN_HEIGHT)
            make.width.equalTo(28)
        }
        
        sendButton.snp_remakeConstraints { (make) in
            make.bottom.equalTo(mediaButton.snp_bottom)
            make.trailing.equalTo(self.snp_trailing).offset(-16)
            make.height.equalTo(INPUT_MIN_HEIGHT)
            make.width.equalTo(40)
        }
        
        textView.snp_remakeConstraints { (make) in
            make.top.equalTo(self.snp_top).offset(8)
            make.leading.equalTo(mediaButton.snp_trailing).offset(16)
            make.bottom.equalTo(mediaButton.snp_bottom)
            make.trailing.equalTo(sendButton.snp_leading).offset(-16)
            make.width.greaterThanOrEqualTo(1)
            make.height.greaterThanOrEqualTo(INPUT_MIN_HEIGHT)
            make.height.lessThanOrEqualTo(INPUT_MAX_HEIGHT)
            make.height.equalTo(inputHeight)
        }
        
        super.updateConstraints()
    }
}

// MARK:- UITextViewDelegate

extension ChatInputView: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        textView.backgroundColor = UIColor.whiteColor()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.backgroundColor = UIColor.clearColor()
        } else {
            textView.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        resizeIfNeeded(textView)
    }
    
    func resizeIfNeeded(textView: UITextView) {
        let temp = UITextView()
        temp.font = textView.font
        temp.bounces = false
        temp.scrollEnabled = false
        temp.text = textView.text
        
        let origWidth: CGFloat = textView.frame.size.width
        var size = temp.sizeThatFits(CGSize(width: origWidth, height: CGFloat.max))
        inputHeight = size.height
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
        
        UIView.animateWithDuration(0.3) {
            self.layoutIfNeeded()
        }
    }
}
