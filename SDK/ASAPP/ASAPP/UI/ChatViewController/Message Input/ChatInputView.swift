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
    
    var bubbleInset = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14) {
        didSet {
            if oldValue.bottom != bubbleInset.bottom {
                bubbleBottomConstraint.constant = -bubbleInset.bottom
                shadowBottomConstraint.constant = -bubbleInset.bottom
                invalidateIntrinsicContentSize()
                resizeIfNeeded(animated: true, notifyOfHeightChange: true)
                cornerRadius = (inputHeight + contentInset.top + contentInset.bottom) / 2
            }
            setNeedsLayout()
        }
    }
    
    var contentInset = UIEdgeInsets(top: 2, left: 24, bottom: 2, right: 9) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var displayMediaButton = false {
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
    
    var inputMinHeight: CGFloat = 26
    let inputMaxHeight: CGFloat = 108
    var inputHeight: CGFloat = 0
    
    private var cornerRadius: CGFloat = 0
    
    let mediaButtonSize = CGSize(width: 16, height: 16)
    let sendButtonSize = CGSize(width: 24, height: 24)
    let sendArrowSize = CGSize(width: 11, height: 11)
    
    // MARK: Properties: UI
    
    let bubbleView = UIView()
    private let shadowView = UIView()
    private let borderTopView = UIView()
    let textView = UITextView()
    private let placeholderTextView = UITextView()
    private let blurredBackground = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    private let mediaButton = UIButton()
    private var sendButtonImage: UIImage?
    private let sendButton = UIButton()
    private var bubbleBottomConstraint: NSLayoutConstraint!
    private var shadowBottomConstraint: NSLayoutConstraint!
    
    fileprivate var verticalInsets: CGFloat {
        return contentInset.top + contentInset.bottom + bubbleInset.top + bubbleInset.bottom
    }
    
    // MARK: - Initialization
    
    required init() {
        self.placeholderText = ASAPP.strings.chatInputPlaceholder
        super.init(frame: .zero)
        
        backgroundColor = .clear
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        blurredBackground.isHidden = true
        addSubview(blurredBackground)
        
        bubbleView.clipsToBounds = true
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bubbleView)
        
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(shadowView, belowSubview: bubbleView)
        
        // Subviews
        addSubview(borderTopView)
        
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
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: sendButtonSize.width + 8)
        textView.scrollIndicatorInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
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
        mediaButton.addTarget(self, action: #selector(ChatInputView.didTapMediaButton), for: .touchUpInside)
        bubbleView.addSubview(mediaButton)
        
        // Send Button
        
        if let icon = createSendIcon() {
            sendButtonImage = icon
        }
        sendButton.addTarget(self, action: #selector(ChatInputView.didTapSendButton), for: .touchUpInside)
        bubbleView.addSubview(sendButton)
        
        addGestureRecognizer(UITapGestureRecognizer(target: textView, action: #selector(UIView.becomeFirstResponder)))
        
        applyColors()
        updateSendButtonForCurrentState()
        updateInputMinHeight()
        
        bubbleBottomConstraint = NSLayoutConstraint(item: bubbleView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -bubbleInset.bottom)
        shadowBottomConstraint = NSLayoutConstraint(item: shadowView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -bubbleInset.bottom)
        
        addConstraints([
            NSLayoutConstraint(item: bubbleView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: bubbleInset.top),
            NSLayoutConstraint(item: bubbleView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -bubbleInset.right),
            bubbleBottomConstraint,
            NSLayoutConstraint(item: bubbleView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: bubbleInset.left),
            NSLayoutConstraint(item: shadowView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: bubbleInset.top),
            NSLayoutConstraint(item: shadowView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -bubbleInset.right),
            shadowBottomConstraint,
            NSLayoutConstraint(item: shadowView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: bubbleInset.left)
        ])
        
        cornerRadius = bubbleView.frame.height / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        textView.delegate = nil
    }
    
    // MARK: - Appearance
    
    private func createSendIcon() -> UIImage? {
        guard let sendArrow = Images.getImage(.iconSend) else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(sendButtonSize, false, UIScreen.main.nativeScale)
        let rect = CGRect(origin: .zero, size: sendButtonSize)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(inputColors.primaryButton.cgColor)
        context?.fillEllipse(in: rect)
        
        let offsetX = (sendButtonSize.width - sendArrowSize.width) / 2
        let offsetY = (sendButtonSize.height - sendArrowSize.height) / 2
        sendArrow.tinted(.white).draw(at: CGPoint(x: offsetX, y: offsetY))
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return combinedImage
    }
    
    private func applyColors() {
        borderTopView.backgroundColor = inputColors.border
        bubbleView.backgroundColor = inputColors.background
        bubbleView.layer.borderColor = inputColors.border?.cgColor
        bubbleView.layer.borderWidth = 1
        shadowView.backgroundColor = inputColors.background
        shadowView.layer.shadowColor = UIColor(red: 0.29, green: 0.29, blue: 0.49, alpha: 1).cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowView.layer.shadowRadius = 2
        shadowView.layer.shadowOpacity = 0.04
        textView.textColor = inputColors.text
        textView.tintColor = inputColors.tint
        placeholderTextView.textColor = inputColors.placeholderText
        
        if let paperclipIcon = Images.getImage(.iconPaperclip) {
            mediaButton.setImage(paperclipIcon.tinted(inputColors.secondaryButton, alpha: 1), for: .normal)
            mediaButton.setImage(paperclipIcon.tinted(inputColors.secondaryButton, alpha: 0.7), for: .highlighted)
            mediaButton.setImage(paperclipIcon.tinted(inputColors.secondaryButton, alpha: 0.4), for: .disabled)
        }
        
        if let sendButtonImage = sendButtonImage {
            sendButton.setImage(sendButtonImage, for: UIControlState())
            sendButton.setImage(sendButtonImage.withAlpha(0.7), for: .highlighted)
            sendButton.setImage(sendButtonImage.withAlpha(0.4), for: .disabled)
        }
        
        sendButton.accessibilityLabel = ASAPP.strings.accessibilitySend
    }
    
    func updateDisplay() {
        textView.updateFont(for: .body)
        placeholderTextView.updateFont(for: .body)
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
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurredBackground.frame = bounds
        
        borderTopView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 1)
        
        let sendButtonLeft = bubbleView.bounds.width - sendButtonSize.width - contentInset.right
        let buttonTop = bubbleView.bounds.height - inputMinHeight - contentInset.bottom
        sendButton.frame = CGRect(x: sendButtonLeft, y: buttonTop, width: sendButtonSize.width, height: ceil(inputMinHeight))
        
        mediaButton.frame = CGRect(x: sendButtonLeft, y: buttonTop, width: sendButtonSize.width, height: sendButton.frame.height)
        let insetX: CGFloat = ceil((sendButton.frame.width - mediaButtonSize.width) / 2)
        let insetY: CGFloat = ceil((sendButton.frame.height - mediaButtonSize.height) / 2)
        mediaButton.imageEdgeInsets = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
        
        let textViewWidth = sendButton.frame.maxX - contentInset.left
        let textViewHeight = inputHeight
        
        textView.frame = CGRect(x: contentInset.left, y: contentInset.top, width: textViewWidth, height: textViewHeight)
        
        placeholderTextView.frame = textView.frame
        
        bubbleView.layer.cornerRadius = isRounded ? cornerRadius : 0
        shadowView.layer.cornerRadius = isRounded ? cornerRadius : 0
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
    
    func hideBlur() {
        blurredBackground.isHidden = true
        setNeedsDisplay()
    }
    
    func showBlur() {
        blurredBackground.isHidden = false
        setNeedsDisplay()
    }
    
    func hideSolidBackground() {
        backgroundColor = .clear
        setNeedsDisplay()
    }
    
    func showSolidBackground() {
        backgroundColor = .white
        setNeedsDisplay()
    }
}
