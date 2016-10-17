//
//  ChatInputView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol ChatInputViewDelegate {
    func chatInputView(_ chatInputView: ChatInputView, didTypeMessageText text: String?)
    func chatInputView(_ chatInputView: ChatInputView, didTapSendMessage message: String)
    func chatInputView(_ chatInputView: ChatInputView, didTapMediaButton mediaButton: UIButton)
    func chatInputViewDidChangeContentSize(_ chatInputView: ChatInputView)
}

class ChatInputView: UIView {

    // MARK: Public Properties
    
    let styles: ASAPPStyles
    
    let strings: ASAPPStrings
    
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
            borderTopView.isHidden = !displayBorderTop
        }
    }
    
    var placeholderText: String {
        didSet {
            placeholderTextView.text = placeholderText
        }
    }
    
    var font: UIFont {
        didSet {
            textView.font = font
            placeholderTextView.font = font
            updateInputMinHeight()
            setNeedsLayout()
        }
    }
    
    var textColor: UIColor {
        didSet {
            textView.textColor = textColor
        }
    }
    
    var placeholderColor: UIColor {
        didSet {
            placeholderTextView.textColor = placeholderColor
            textView.tintColor = placeholderColor
        }
    }
    
    var sendButtonText: String {
        didSet {
            updateSendButtonText()
        }
    }
    
    var sendButtonFont: UIFont {
        didSet {
            updateSendButtonText()
        }
    }
    
    var sendButtonColor: UIColor {
        didSet {
            updateSendButtonText()
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

    fileprivate let borderTopView = UIView()
    fileprivate let textView = UITextView()
    fileprivate let placeholderTextView = UITextView()
    
    fileprivate let mediaButton = UIButton()
    fileprivate let sendButton = UIButton()
    fileprivate let buttonSeparator = VerticalGradientView()
    
    // MARK:- Initialization
    
    required init(styles: ASAPPStyles, strings: ASAPPStrings) {
        self.styles = styles
        self.strings = strings
        self.font = styles.bodyFont
        self.textColor = styles.inputTextColor
        self.placeholderText = strings.chatInputPlaceholder
        self.placeholderColor = styles.inputTextColor.withAlphaComponent(0.7)
        self.sendButtonText = strings.chatInputSend
        self.sendButtonFont = styles.buttonFont
        self.sendButtonColor = styles.inputSendButtonColor
        self.separatorColor = styles.separatorColor1
        super.init(frame: .zero)
        
        backgroundColor = Colors.whiteColor()
        clipsToBounds = true
        
        // Subviews
        
        borderTopView.backgroundColor = separatorColor
        addSubview(borderTopView)
        
        // Text View
        
        textView.backgroundColor = UIColor.clear
        textView.tintColor = placeholderColor
        textView.font = font
        textView.textColor = textColor
        textView.bounces = false
        textView.isScrollEnabled = false
        textView.scrollsToTop = false
        textView.clipsToBounds = false
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        textView.returnKeyType = .send
        textView.sizeToFit()
        inputHeight = textView.frame.size.height
        
        placeholderTextView.text = placeholderText
        placeholderTextView.backgroundColor = UIColor.clear
        placeholderTextView.font = textView.font
        placeholderTextView.textColor = placeholderColor
        placeholderTextView.isUserInteractionEnabled = false
        placeholderTextView.scrollsToTop = false
        placeholderTextView.isScrollEnabled = false
        placeholderTextView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        addSubview(textView)
        addSubview(placeholderTextView)
        
        // Media Button
        
        let imageSize: CGFloat = 20
        let insetX: CGFloat = (mediaButtonWidth - imageSize) / 2.0
        mediaButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
        mediaButton.imageView?.contentMode = .scaleAspectFit
        updateMediaButtonColor(styles.inputImageButtonColor)
        mediaButton.addTarget(self,
                              action: #selector(ChatInputView.didTapMediaButton),
                              for: .touchUpInside)
        addSubview(mediaButton)
        
        // Send Button
        
        sendButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        sendButton.addTarget(self,
                             action: #selector(ChatInputView.didTapSendButton),
                             for: .touchUpInside)
        updateSendButtonText()
        addSubview(sendButton)
        
        applySeparatorColor()
        addSubview(buttonSeparator)
        
        addGestureRecognizer(UITapGestureRecognizer(target: textView, action: #selector(UIView.becomeFirstResponder)))
        
        updateSendButtonForCurrentState()
        updateInputMinHeight()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    deinit {
        textView.delegate = nil
    }
    
    // MARK:- Appearance
    
    func updateSendButtonForCurrentState() {
        if textView.text.isEmpty {
            placeholderTextView.isHidden = false
            sendButton.isHidden = true
            mediaButton.isHidden = false
        } else {
            placeholderTextView.isHidden = true
            sendButton.isHidden = false
            mediaButton.isHidden = true
        }
        
        sendButton.isEnabled = canSendMessage
        mediaButton.isEnabled = canSendMessage
        buttonSeparator.isHidden = (mediaButton.isHidden || mediaButton.alpha == 0) && sendButton.isHidden
    }
    
    // MARK:- Button Colors
    
    func updateSendButtonText() {
        let font = sendButtonFont
        let color = sendButtonColor
        let normalAttributes = [
            NSKernAttributeName : 1.5,
            NSForegroundColorAttributeName : color,
            NSFontAttributeName : font
        ] as [String : Any]
        let highlightedAttributes = [
            NSKernAttributeName : 1.5,
            NSForegroundColorAttributeName : color.withAlphaComponent(0.7),
            NSFontAttributeName : font
        ] as [String : Any]
        let disabledAttributes = [
            NSKernAttributeName : 1.5,
            NSForegroundColorAttributeName : color.withAlphaComponent(0.4),
            NSFontAttributeName : font
        ] as [String : Any]
        let buttonTitle = sendButtonText
        sendButton.setAttributedTitle(NSAttributedString(string: buttonTitle, attributes: normalAttributes), for: UIControlState())
        sendButton.setAttributedTitle(NSAttributedString(string: buttonTitle, attributes: highlightedAttributes), for: .highlighted)
        sendButton.setAttributedTitle(NSAttributedString(string: buttonTitle, attributes: disabledAttributes), for: .disabled)
    }
    
    func updateMediaButtonColor(_ color: UIColor) {
        mediaButton.setImage(Images.paperclipIcon(fillColor: color, alpha: 1), for: UIControlState())
        mediaButton.setImage(Images.paperclipIcon(fillColor: color, alpha: 0.7), for: .highlighted)
        mediaButton.setImage(Images.paperclipIcon(fillColor: color, alpha: 0.4), for: .disabled)
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
        buttonSeparator.update(separatorColor?.withAlphaComponent(0.0),
                               middleColor: separatorColor,
                               bottomColor: separatorColor?.withAlphaComponent(0.0))
    }
}

// MARK:- First Responder

extension ChatInputView {
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder() || super.becomeFirstResponder()
    }
    
    override var canBecomeFirstResponder : Bool {
        return textView.canBecomeFirstResponder || super.canBecomeFirstResponder
    }
    
    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder() || super.resignFirstResponder()
    }
    
    override var canResignFirstResponder : Bool {
        return textView.canResignFirstResponder || super.canResignFirstResponder
    }
    
    override var isFirstResponder : Bool {
        return textView.isFirstResponder || super.isFirstResponder
    }
}

// MARK:- Layout

extension ChatInputView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        borderTopView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 1)
        
        let buttonWidth = ceil(sendButton.sizeThatFits(CGSize.zero).width) + sendButton.titleEdgeInsets.left + sendButton.titleEdgeInsets.right
        let sendButtonLeft = bounds.width - buttonWidth - contentInset.right + sendButton.titleEdgeInsets.right
        let buttonTop = bounds.height - inputMinHeight - contentInset.bottom
        sendButton.frame = CGRect(x: sendButtonLeft, y: buttonTop, width: buttonWidth, height: inputMinHeight)
        
        let mediaButtonLeft = bounds.width - mediaButtonWidth + mediaButton.imageEdgeInsets.right - contentInset.right
        mediaButton.frame = CGRect(x: mediaButtonLeft, y: buttonTop, width: buttonWidth, height: inputMinHeight)
        
        let separatorStroke: CGFloat = 1.0
        let separatorLeft = sendButton.frame.minX - separatorStroke
        buttonSeparator.frame = CGRect(x: separatorLeft, y: buttonTop, width: separatorStroke, height: inputMinHeight)
        
        let textViewWidth = sendButtonLeft - 8.0 - contentInset.left
        let textViewHeight = inputHeight
        
        textView.frame = CGRect(x: contentInset.left, y: contentInset.top, width: textViewWidth, height: textViewHeight)
        
        placeholderTextView.frame = textView.frame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: inputHeight + contentInset.top + contentInset.bottom)
    }
}

// MARK:- UITextViewDelegate

extension ChatInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        resizeIfNeeded(true, notifyDelegateOfChange: true)
        updateSendButtonForCurrentState()
        delegate?.chatInputView(self, didTypeMessageText: textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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
    
    func resizeIfNeeded(_ animated: Bool, notifyDelegateOfChange: Bool = false) {
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
