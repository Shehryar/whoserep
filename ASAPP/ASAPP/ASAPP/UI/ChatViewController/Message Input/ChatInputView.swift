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
    
    var contentInset = UIEdgeInsets(top: 18, left: 35, bottom: 18, right: 35) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var displayMediaButton = true {
        didSet {
            mediaButton.alpha = displayMediaButton ? 1 : 0
            updateSendButtonForCurrentState()
            setNeedsLayout()
        }
    }
    
    var displayBorderTop = true {
        didSet {
            borderTopView.hidden = !displayBorderTop
        }
    }
    
    var placeholderText: String = ASAPPLocalizedString("Enter a message...") {
        didSet {
            placeholderTextView.text = placeholderText
        }
    }
    
    var font = Fonts.latoRegularFont(withSize: 15) {
        didSet {
            textView.font = font
            placeholderTextView.font = font
            updateInputMinHeight()
            setNeedsLayout()
        }
    }
    
    var textColor = Colors.whiteColor() {
        didSet {
            textView.textColor = textColor
        }
    }
    
    var placeholderColor = Colors.whiteColor().colorWithAlphaComponent(0.7) {
        didSet {
            placeholderTextView.textColor = placeholderColor
            textView.tintColor = placeholderColor
        }
    }
    
    var separatorColor: UIColor? {
        didSet {
            applySeparatorColor()
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
    private let placeholderTextView = UITextView()
    
    private let mediaButton = UIButton()
    private let sendButton = UIButton()
    private let buttonSeparator = VerticalGradientView()
    
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
        
        textView.backgroundColor = UIColor.clearColor()
        textView.tintColor = placeholderColor
        textView.font = font
        textView.textColor = textColor
        textView.bounces = false
        textView.scrollEnabled = false
        textView.scrollsToTop = false
        textView.clipsToBounds = false
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        textView.returnKeyType = .Send
        textView.sizeToFit()
        inputHeight = textView.frame.size.height
        
        placeholderTextView.text = placeholderText
        placeholderTextView.backgroundColor = UIColor.clearColor()
        placeholderTextView.font = textView.font
        placeholderTextView.textColor = placeholderColor
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
        updateMediaButtonColor(Colors.mediumTextColor())
        mediaButton.addTarget(self,
                              action: #selector(ChatInputView.didTapMediaButton),
                              forControlEvents: .TouchUpInside)
        addSubview(mediaButton)
        
        // Send Button
        
        sendButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        updateSendButtonStyle(withFont: Fonts.latoBlackFont(withSize: 13),
                             color: Colors.mediumTextColor())
        sendButton.addTarget(self,
                             action: #selector(ChatInputView.didTapSendButton),
                             forControlEvents: .TouchUpInside)
        addSubview(sendButton)
        addSubview(buttonSeparator)
        
        updateSendButtonForCurrentState()
        
        addGestureRecognizer(UITapGestureRecognizer(target: textView, action: #selector(UIView.becomeFirstResponder)))
        
        updateInputMinHeight()
    }
    
    deinit {
        textView.delegate = nil
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
        buttonSeparator.hidden = (mediaButton.hidden || mediaButton.alpha == 0) && sendButton.hidden
    }
    
    // MARK:- Button Colors
    
    func updateSendButtonStyle(withFont font: UIFont, color: UIColor) {
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
    
    func updateMediaButtonColor(color: UIColor) {
        mediaButton.setImage(Images.paperclipIcon(fillColor: color, alpha: 1), forState: .Normal)
        mediaButton.setImage(Images.paperclipIcon(fillColor: color, alpha: 0.7), forState: .Highlighted)
        mediaButton.setImage(Images.paperclipIcon(fillColor: color, alpha: 0.4), forState: .Disabled)
    }
    
    // MARK:- Button Actions
    
    func didTapSendButton() {
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
        
        font = styles.bodyFont
        textColor = styles.inputTextColor
        placeholderColor = styles.inputTextColor.colorWithAlphaComponent(0.7)
        separatorColor = styles.separatorColor1
        
        updateSendButtonStyle(withFont: styles.buttonFont, color: styles.inputSendButtonColor)
        updateMediaButtonColor(styles.inputImageButtonColor)
        
        updateInputMinHeight()
    }
    
    func updateInputMinHeight() {
        let textViewText = textView.text
        textView.text = nil
        resizeIfNeeded(false)
        inputMinHeight = inputHeight
        textView.text = textViewText
        setNeedsLayout()
    }
    
    func applySeparatorColor() {
        borderTopView.backgroundColor = separatorColor
        buttonSeparator.update(separatorColor?.colorWithAlphaComponent(0.0),
                               middleColor: separatorColor,
                               bottomColor: separatorColor?.colorWithAlphaComponent(0.0))
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
        mediaButton.frame = CGRect(x: mediaButtonLeft, y: buttonTop, width: buttonWidth, height: inputMinHeight)
        
        let separatorStroke: CGFloat = 1.0
        let separatorLeft = CGRectGetMinX(sendButton.frame) - separatorStroke
        buttonSeparator.frame = CGRect(x: separatorLeft, y: buttonTop, width: separatorStroke, height: inputMinHeight)
        
        let textViewWidth = sendButtonLeft - 8.0 - contentInset.left
        let textViewHeight = inputHeight //CGRectGetHeight(bounds) - contentInset.top - contentInset.bottom
        let calculatedTextViewHeight = ceil(textView.sizeThatFits(CGSize(width: textViewWidth, height: 0)).height)
        
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
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView.text.isEmpty {
                textView.resignFirstResponder()
            } else {
                didTapSendButton()
            }
            return false
        }
        return true
    }
    
    func resizeIfNeeded(animated: Bool, notifyDelegateOfChange: Bool = false) {
        var height = textView.sizeThatFits(CGSize(width: CGRectGetWidth(textView.bounds), height: inputMaxHeight)).height
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
