//
//  ChatInputView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol ChatInputViewDelegate: class {
    func chatInputView(_ chatInputView: ChatInputView, didTypeMessageText text: String?)
    func chatInputView(_ chatInputView: ChatInputView, didTapSendMessage message: String)
    func chatInputView(_ chatInputView: ChatInputView, didTapMediaButton mediaButton: UIButton)
    func chatInputViewDidBeginEditing(_ chatInputView: ChatInputView)
    func chatInputViewDidChangeContentSize(_ chatInputView: ChatInputView)
}

class ChatInputView: UIView, TextViewAutoExpanding {

    // MARK: Public Properties
    
    weak var delegate: ChatInputViewDelegate?
    
    var inputColors: ASAPPInputColors = ASAPP.styles.colors.chatInput {
        didSet {
            applyColors()
        }
    }
    
    var canSendMessage: Bool = true {
        didSet {
            updateSendButtonForCurrentState()
        }
    }
    
    var bubbleInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var contentInset = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 0) {
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
            textView.accessibilityLabel = placeholderText.trimmingCharacters(in: CharacterSet.punctuationCharacters)
        }
    }
    
    var sendButtonImage: ASAPPCustomImage? {
        didSet {
            if oldValue != sendButtonImage {
                updateSendButtonImage()
            }
        }
    }
    
    var sendButtonText: String? {
        didSet {
            updateSendButtonText()
        }
    }
    
    var isRounded = false {
        didSet {
            updateDisplay()
        }
    }
    
    var keyboardAppearance: UIKeyboardAppearance {
        set { textView.keyboardAppearance = newValue }
        get { return textView.keyboardAppearance }
    }
    
    // MARK: Properties: Data
    
    var inputMinHeight: CGFloat = 28
    let inputMaxHeight: CGFloat = 58
    let mediaButtonImageHeight: CGFloat = 22
    var inputHeight: CGFloat = 0
    
    // MARK: Properties: UI
    
    let bubbleView = UIView()
    private let borderTopView = UIView()
    let textView = UITextView()
    private let placeholderTextView = UITextView()
    
    private let mediaButton = UIButton()
    private let sendButton = UIButton()
    private let buttonSeparator = VerticalGradientView()
    
    fileprivate var verticalInsets: CGFloat {
        return contentInset.top + contentInset.bottom + bubbleInset.top + bubbleInset.bottom
    }
    
    // MARK: - Initialization
    
    required init() {
        self.placeholderText = ASAPP.strings.chatInputPlaceholder
        if let text = ASAPP.strings.chatInputSend {
            self.sendButtonText = text
        } else {
            self.sendButtonImage = ASAPP.styles.sendButtonImage
        }
        super.init(frame: .zero)
        
        backgroundColor = ASAPP.styles.colors.chatInput.background
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bubbleView)
        
        // Subviews
        bubbleView.addSubview(borderTopView)
        
        // Text View
        
        textView.backgroundColor = .clear
        textView.bounces = false
        textView.isScrollEnabled = false
        textView.scrollsToTop = false
        textView.clipsToBounds = false
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        textView.returnKeyType = .send
        textView.isAccessibilityElement = true
        textView.accessibilityTraits = UIAccessibilityTraitSearchField
        textView.accessibilityLabel = placeholderText.trimmingCharacters(in: CharacterSet.punctuationCharacters)
        textView.sizeToFit()
        if ASAPP.styles.colors.backgroundPrimary.isDark() {
            textView.keyboardAppearance = .dark
        } else {
            textView.keyboardAppearance = .default
        }
        inputHeight = inputMinHeight
        bubbleView.addSubview(textView)
        
        placeholderTextView.text = placeholderText
        placeholderTextView.backgroundColor = .clear
        placeholderTextView.isUserInteractionEnabled = false
        placeholderTextView.scrollsToTop = false
        placeholderTextView.isScrollEnabled = false
        placeholderTextView.isAccessibilityElement = false
        placeholderTextView.textContainer.lineFragmentPadding = 0
        bubbleView.addSubview(placeholderTextView)
        
        // Media Button
        
        mediaButton.imageView?.contentMode = .scaleAspectFit
        mediaButton.addTarget(self,
                              action: #selector(ChatInputView.didTapMediaButton),
                              for: .touchUpInside)
        bubbleView.addSubview(mediaButton)
        
        // Send Button
        
        sendButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        sendButton.addTarget(self,
                             action: #selector(ChatInputView.didTapSendButton),
                             for: .touchUpInside)
        bubbleView.addSubview(sendButton)
        
        bubbleView.addSubview(buttonSeparator)
        
        addGestureRecognizer(UITapGestureRecognizer(target: textView, action: #selector(UIView.becomeFirstResponder)))
        
        applyColors()
        updateSendButtonForCurrentState()
        updateInputMinHeight()
        
        setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        textView.delegate = nil
    }
    
    // MARK: - Appearance
    
    private func applyColors() {
        backgroundColor = .clear
        borderTopView.backgroundColor = inputColors.border
        bubbleView.backgroundColor = inputColors.background
        textView.textColor = inputColors.text
        textView.tintColor = inputColors.tint
        placeholderTextView.textColor = inputColors.placeholderText
        
        updateSendButtonText()
        
        mediaButton.setImage(Images.getImage(.iconPaperclip)?.tinted(inputColors.secondaryButton, alpha: 1), for: .normal)
        mediaButton.setImage(Images.getImage(.iconPaperclip)?.tinted(inputColors.secondaryButton, alpha: 0.7), for: .highlighted)
        mediaButton.setImage(Images.getImage(.iconPaperclip)?.tinted(inputColors.secondaryButton, alpha: 0.4), for: .disabled)
    }
    
    func updateSendButtonImage() {
        guard let image = sendButtonImage?.image.colored(with: inputColors.primaryButton) else {
            return
        }
        
        sendButton.setAttributedTitle(nil, for: UIControlState())
        sendButton.setAttributedTitle(nil, for: .highlighted)
        sendButton.setAttributedTitle(nil, for: .disabled)
        sendButton.setImage(image, for: UIControlState())
        sendButton.setImage(image.withAlpha(0.7), for: .highlighted)
        sendButton.setImage(image.withAlpha(0.4), for: .disabled)
        
        sendButton.accessibilityLabel = ASAPP.strings.accessibilitySend
    }
    
    func updateSendButtonText() {
        guard let buttonTitle = sendButtonText else {
            return
        }
        
        let font = ASAPP.styles.textStyles.link.font
        let color = inputColors.primaryButton
        let normalAttributes = [
            .kern: 1.5,
            .foregroundColor: color,
            .font: font
        ] as [NSAttributedStringKey: Any]
        let highlightedAttributes = [
            .kern: 1.5,
            .foregroundColor: color.withAlphaComponent(0.7),
            .font: font
        ] as [NSAttributedStringKey: Any]
        let disabledAttributes = [
            .kern: 1.5,
            .foregroundColor: color.withAlphaComponent(0.4),
            .font: font
        ] as [NSAttributedStringKey: Any]
        
        sendButton.setAttributedTitle(NSAttributedString(string: buttonTitle, attributes: normalAttributes), for: UIControlState())
        sendButton.setAttributedTitle(NSAttributedString(string: buttonTitle, attributes: highlightedAttributes), for: .highlighted)
        sendButton.setAttributedTitle(NSAttributedString(string: buttonTitle, attributes: disabledAttributes), for: .disabled)
    }
    
    func updateDisplay() {
        textView.updateFont(for: .body)
        placeholderTextView.updateFont(for: .bodyItalic)
        updateSendButtonText()
        updateSendButtonImage()
        updateInputMinHeight()
        setNeedsLayout()
    }
    
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
    
    // MARK: - Button Actions
    
    @objc func didTapSendButton() {
        if let messageText = textView.text {
            delegate?.chatInputView(self, didTapSendMessage: messageText)
        }
    }
    
    @objc func didTapMediaButton() {
        delegate?.chatInputView(self, didTapMediaButton: mediaButton)
    }
}

// MARK: - First Responder

extension ChatInputView {
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder() || super.becomeFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool {
        return textView.canBecomeFirstResponder || super.canBecomeFirstResponder
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder() || super.resignFirstResponder()
    }
    
    override var canResignFirstResponder: Bool {
        return textView.canResignFirstResponder || super.canResignFirstResponder
    }
    
    override var isFirstResponder: Bool {
        return textView.isFirstResponder || super.isFirstResponder
    }
}

// MARK: - Layout

extension ChatInputView {    
    override func updateConstraints() {
        super.updateConstraints()
        
        addConstraints([
            NSLayoutConstraint(item: bubbleView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: bubbleInset.top),
            NSLayoutConstraint(item: bubbleView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -bubbleInset.right),
            NSLayoutConstraint(item: bubbleView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -bubbleInset.bottom),
            NSLayoutConstraint(item: bubbleView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: bubbleInset.left)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        borderTopView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 1)
        
        let buttonWidth = ceil(sendButton.sizeThatFits(CGSize.zero).width) + sendButton.titleEdgeInsets.left + sendButton.titleEdgeInsets.right
        let sendButtonLeft = bubbleView.bounds.width - buttonWidth - contentInset.right
        let buttonTop = bubbleView.bounds.height - inputMinHeight - contentInset.bottom
        sendButton.frame = CGRect(x: sendButtonLeft, y: buttonTop, width: buttonWidth, height: inputMinHeight)
        
        mediaButton.frame = CGRect(x: sendButtonLeft, y: buttonTop, width: buttonWidth, height: sendButton.frame.height)
        let insetY: CGFloat = (sendButton.frame.height - mediaButtonImageHeight) / 2.0
        mediaButton.imageEdgeInsets = UIEdgeInsets(top: insetY, left: 0, bottom: insetY, right: 0)

        let separatorStroke: CGFloat = 1.0
        let separatorLeft = sendButton.frame.minX - separatorStroke
        buttonSeparator.frame = CGRect(x: separatorLeft, y: buttonTop, width: separatorStroke, height: inputMinHeight)
        
        let textViewWidth = sendButtonLeft - 8.0 - contentInset.left
        let textViewHeight = inputHeight
        
        textView.frame = CGRect(x: contentInset.left, y: contentInset.top, width: textViewWidth, height: textViewHeight)
        
        placeholderTextView.frame = textView.frame
        
        bubbleView.layer.cornerRadius = isRounded ? bubbleView.frame.height / 2 : 0
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: inputHeight + verticalInsets)
    }
    
    override var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize(width: bounds.width, height: 0))
    }
}

// MARK: - UITextViewDelegate

extension ChatInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        invalidateIntrinsicContentSize()
        resizeIfNeeded(animated: true, notifyOfHeightChange: true)
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
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        bubbleView.backgroundColor = inputColors.background.withAlphaComponent(1)
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.chatInputViewDidBeginEditing(self)
    }
}

// MARK: - AutoExpandingTextView

extension ChatInputView {
    func textViewHeightDidChange() {
        delegate?.chatInputViewDidChangeContentSize(self)
    }
}

// MARK: - Public Instance Methods

extension ChatInputView {
    func clear() {
        textView.text = ""
        invalidateIntrinsicContentSize()
        resizeIfNeeded(animated: false, notifyOfHeightChange: true)
        updateSendButtonForCurrentState()
        
        delegate?.chatInputView(self, didTypeMessageText: nil)
    }
}
