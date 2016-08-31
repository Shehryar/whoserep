//
//  ChatInputView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol ChatInputViewDelegate {
    func chatInputView(chatInputView: ChatInputView, didTypeMessageText text: String?)
    func chatInputView(chatInputView: ChatInputView, didTapSendMessage message: String)
    func chatInputView(chatInputView: ChatInputView, didTapMediaButton mediaButton: UIButton)
    func chatInputView(chatInputView: ChatInputView, didUpdateInputFrame inputFrame: CGRect)
    func chatInputViewDidChangeContentSize(chatInputView: ChatInputView)
}

class ChatInputView: UIView, ASAPPStyleable {

    // MARK: Public Properties
    
    var delegate: ChatInputViewDelegate?
    
    var canSendMessage: Bool = true {
        didSet {
            updateSendButtonForCurrentState()
        }
    }
    
    var contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16) {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: Properties: Data
    
    var inputMinHeight: CGFloat = 36
    let inputMaxHeight: CGFloat = 150
    let mediaButtonWidth: CGFloat = 44
    var inputHeight: CGFloat = 0
    
    // MARK: Properties: UI

    private let borderTopView = UIView()
    private let textView = UITextView()
    private let keyboardFrameTrackingView = FrameTrackingInputAccessoryView()
    private let placeholderTextView = UITextView()
    
    private let mediaButton = UIButton()
    private let sendButton = UIButton()
    
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
        clipsToBounds = true
        
        borderTopView.backgroundColor = Colors.lighterGrayColor()
        addSubview(borderTopView)
        
        // Text View
        
        textView.backgroundColor = UIColor.whiteColor()
        textView.tintColor = Colors.grayColor()
        textView.font = Fonts.latoRegularFont(withSize: 16)
        textView.textColor = Colors.darkTextColor()
        textView.bounces = false
        textView.scrollEnabled = false
        textView.scrollsToTop = false
        textView.clipsToBounds = false
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        textView.sizeToFit()
        inputHeight = textView.frame.size.height
        
        keyboardFrameTrackingView.frame = CGRectMake(0, 0, 0, 0)
        keyboardFrameTrackingView.backgroundColor = UIColor.blueColor()
        keyboardFrameTrackingView.onFrameChange = { [weak self] (updatedFrame) in
            if let strongSelf = self {
                self?.delegate?.chatInputView(strongSelf, didUpdateInputFrame: updatedFrame)
            }
        }
        textView.inputAccessoryView = keyboardFrameTrackingView
        
        
        placeholderTextView.text = ASAPPLocalizedString("Craft a message...")
        placeholderTextView.backgroundColor = UIColor.clearColor()
        placeholderTextView.font = textView.font
        placeholderTextView.textColor = Colors.mediumTextColor()
        placeholderTextView.userInteractionEnabled = false
        placeholderTextView.scrollsToTop = false
        placeholderTextView.scrollEnabled = false
        placeholderTextView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        addSubview(textView)
        addSubview(placeholderTextView)
        
        // Media Button
        
        let imageSize: CGFloat = 20
        let insetX: CGFloat = (mediaButtonWidth - imageSize) / 2.0
        mediaButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
        mediaButton.imageView?.contentMode = .ScaleAspectFit
        applyMediaButtonColor(Colors.mediumTextColor())
        mediaButton.addTarget(self,
                              action: #selector(ChatInputView.didTapMediaButton),
                              forControlEvents: .TouchUpInside)
        addSubview(mediaButton)
        
        // Send Button
        
        sendButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        applySendButtonStyle(withFont: Fonts.latoBlackFont(withSize: 13),
                             color: Colors.mediumTextColor())
        sendButton.addTarget(self,
                             action: #selector(ChatInputView.didTapSendButton(_:)),
                             forControlEvents: .TouchUpInside)
        addSubview(sendButton)
        
        updateSendButtonForCurrentState()
        
        addGestureRecognizer(UITapGestureRecognizer(target: textView, action: #selector(UIView.becomeFirstResponder)))
    }
    
    deinit {
        textView.delegate = nil
        keyboardFrameTrackingView.removeObserver(self, forKeyPath: "frame")
    }
    
    // MARK:- Appearance
    
    func updateSendButtonForCurrentState() {
        if textView.text.isEmpty {
            placeholderTextView.hidden = false
            sendButton.hidden = true
            mediaButton.hidden = false
        } else {
            placeholderTextView.hidden = true
            sendButton.hidden = false
            mediaButton.hidden = true
        }
        
        sendButton.enabled = canSendMessage
        mediaButton.enabled = canSendMessage
    }
    
    // MARK:- Button Colors
    
    func applySendButtonStyle(withFont font: UIFont, color: UIColor) {
        let normalAttributes = [
            NSKernAttributeName : 1.5,
            NSForegroundColorAttributeName : color,
            NSFontAttributeName : font
        ]
        let highlightedAttributes = [
            NSKernAttributeName : 1.5,
            NSForegroundColorAttributeName : color.colorWithAlphaComponent(0.7),
            NSFontAttributeName : font
        ]
        let disabledAttributes = [
            NSKernAttributeName : 1.5,
            NSForegroundColorAttributeName : color.colorWithAlphaComponent(0.4),
            NSFontAttributeName : font
        ]
        let buttonTitle = ASAPPLocalizedString("SEND")
        sendButton.setAttributedTitle(NSAttributedString(string: buttonTitle, attributes: normalAttributes), forState: .Normal)
        sendButton.setAttributedTitle(NSAttributedString(string: buttonTitle, attributes: highlightedAttributes), forState: .Highlighted)
        sendButton.setAttributedTitle(NSAttributedString(string: buttonTitle, attributes: disabledAttributes), forState: .Disabled)
    }
    
    func applyMediaButtonColor(color: UIColor) {
        mediaButton.setImage(Images.paperclipIcon(fillColor: color, alpha: 1), forState: .Normal)
        mediaButton.setImage(Images.paperclipIcon(fillColor: color, alpha: 0.7), forState: .Highlighted)
        mediaButton.setImage(Images.paperclipIcon(fillColor: color, alpha: 0.4), forState: .Disabled)
    }
    
    // MARK:- Button Actions
    
    func didTapSendButton(sender: UIButton) {
        if let messageText = textView.text {
            delegate?.chatInputView(self, didTapSendMessage: messageText)
        }
    }
    
    func didTapMediaButton() {
        delegate?.chatInputView(self, didTapMediaButton: mediaButton)
    }
    
    // MARK:- ASAPPStyleable
    
    private(set) var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
        
        backgroundColor = styles.inputBackgroundColor
        textView.backgroundColor = backgroundColor
        borderTopView.backgroundColor = styles.inputBorderTopColor
        
        textView.font = styles.inputFont
        textView.tintColor = styles.inputTintColor
        textView.textColor = styles.inputTextColor
        placeholderTextView.font = textView.font
        placeholderTextView.textColor = styles.inputPlaceholderColor
        
        applySendButtonStyle(withFont: styles.inputSendButtonFont, color: styles.inputSendButtonColor)
        applyMediaButtonColor(styles.inputImageButtonColor)
        
        let textViewText = textView.text
        textView.text = nil
        resizeIfNeeded(false)
        inputMinHeight = inputHeight
        textView.text = textViewText
    }
}

// MARK:- First Responder

extension ChatInputView {
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder() || super.becomeFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return textView.canBecomeFirstResponder() || super.canBecomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder() || super.resignFirstResponder()
    }
    
    override func canResignFirstResponder() -> Bool {
        return textView.canResignFirstResponder() || super.canResignFirstResponder()
    }
    
    override func isFirstResponder() -> Bool {
        return textView.isFirstResponder() || super.isFirstResponder()
    }
}

// MARK:- Layout

extension ChatInputView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        borderTopView.frame = CGRect(x: 0, y: 0, width: CGRectGetWidth(bounds), height: 1)
        
        let buttonWidth = ceil(sendButton.sizeThatFits(CGSizeZero).width) + sendButton.titleEdgeInsets.left + sendButton.titleEdgeInsets.right
        let sendButtonLeft = CGRectGetWidth(bounds) - buttonWidth - contentInset.right + sendButton.titleEdgeInsets.right
        let buttonTop = CGRectGetHeight(bounds) - inputMinHeight - contentInset.bottom
        sendButton.frame = CGRect(x: sendButtonLeft, y: buttonTop, width: buttonWidth, height: inputMinHeight)
        
        let mediaButtonLeft = CGRectGetWidth(bounds) - mediaButtonWidth + mediaButton.imageEdgeInsets.right - contentInset.right
        mediaButton.frame = CGRect(x: mediaButtonLeft, y: buttonTop, width: mediaButtonWidth, height: inputMinHeight)
        
        let textViewWidth = sendButtonLeft - 8.0 - contentInset.left
        let textViewHeight = inputHeight //CGRectGetHeight(bounds) - contentInset.top - contentInset.bottom
        textView.frame = CGRectMake(contentInset.left, contentInset.top, textViewWidth, textViewHeight)
        placeholderTextView.frame = textView.frame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: inputHeight + contentInset.top + contentInset.bottom)
    }

}

// MARK:- UITextViewDelegate

extension ChatInputView: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        resizeIfNeeded(true, notifyDelegateOfChange: true)
        updateSendButtonForCurrentState()
        delegate?.chatInputView(self, didTypeMessageText: textView.text)
    }
    
    func resizeIfNeeded(animated: Bool, notifyDelegateOfChange: Bool = false) {
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
            if notifyDelegateOfChange {
                delegate?.chatInputViewDidChangeContentSize(self)
            }
        }
    }
}

// MARK:- Public Instance Methods

extension ChatInputView {
    func clear() {
        textView.text = ""
        resizeIfNeeded(false, notifyDelegateOfChange: true)
        updateSendButtonForCurrentState()
        
        delegate?.chatInputView(self, didTypeMessageText: nil)
    }
}
