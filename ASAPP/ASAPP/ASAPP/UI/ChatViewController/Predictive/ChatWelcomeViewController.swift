//
//  ChatWelcomeViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol ChatWelcomeViewControllerDelegate {
    func chatWelcomeViewController(_ viewController: ChatWelcomeViewController, didFinishWithText queryText: String)
    func chatWelcomeViewControllerDidTapViewChat(_ viewController: ChatWelcomeViewController)
    func chatWelcomeViewControllerDidTapX(_ viewController: ChatWelcomeViewController)
}

class ChatWelcomeViewController: UIViewController {

    fileprivate(set) var appOpenResponse: SRSAppOpenResponse?
    
    let styles: ASAPPStyles
    
    var delegate: ChatWelcomeViewControllerDelegate?
    
    var tapGesture: UITapGestureRecognizer?
    
    var connectionStatus: ChatConnectionStatus = .disconnected {
        didSet {
            updateConnectionStatusLabel()
        }
    }
    
    fileprivate(set) var viewContentsVisible = true
    
    // MARK: Private Properties
    
    fileprivate let contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 30, right: 20)
    fileprivate let blurredBgView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    fileprivate let blurredColorLayer = VerticalGradientView()
    fileprivate let titleLabel = UILabel()
    fileprivate let messageLabel = UILabel()
    fileprivate let buttonsView: ChatWelcomeButtonsView
    fileprivate let messageInputView = ChatInputView()
    fileprivate let connectionStatusLabel = UILabel()
    fileprivate var finishedInitialAnimation = true
    
    fileprivate let keyboardObserver = KeyboardObserver()
    fileprivate var keyboardOffset: CGFloat = 0
    
    // MARK: Initialization
    
    required init(appOpenResponse: SRSAppOpenResponse?, styles: ASAPPStyles?) {
        self.appOpenResponse = appOpenResponse ?? SRSAppOpenResponse(greeting: nil)
        self.styles = styles ?? ASAPPStyles()
        self.buttonsView = ChatWelcomeButtonsView(styles: styles)
        super.init(nibName: nil, bundle: nil)
        
        let viewChatButton = Button()
        viewChatButton.insetLeft = 0
        viewChatButton.image = Images.buttonViewChat()
        viewChatButton.imageSize = CGSize(width: 90, height: 25)  // 79 x 22
        viewChatButton.imageIgnoresForegroundColor = true
        viewChatButton.adjustsOpacityForState = true
        viewChatButton.onTap = { [weak self] in
            if let blockSelf = self {
                blockSelf.delegate?.chatWelcomeViewControllerDidTapViewChat(blockSelf)
            }
        }
        viewChatButton.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: viewChatButton)
        
        let closeButton = Button()
        closeButton.insetRight = 0
        closeButton.image = Images.buttonCloseDark()
        closeButton.imageSize = CGSize(width: 24, height: 24)
        closeButton.imageIgnoresForegroundColor = true
        closeButton.adjustsOpacityForState = true
        closeButton.onTap = { [weak self] in
            self?.didTapCancel()
        }
        closeButton.sizeToFit()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatWelcomeViewController.dismissKeyboard))
        if let tapGesture = tapGesture {
            tapGesture.cancelsTouchesInView = false
            tapGesture.delegate = self
            blurredBgView.addGestureRecognizer(tapGesture)
        }
        
        blurredColorLayer.update(UIColor(red:0.302, green:0.310, blue:0.347, alpha:0.9),
                                 middleColor: UIColor(red:0.366, green:0.384, blue:0.426, alpha:0.8),
                                 bottomColor: UIColor(red:0.483, green:0.505, blue:0.568, alpha:0.8))
        blurredBgView.contentView.addSubview(blurredColorLayer)
        
        
        let (titleText, placeholderText) = getTitleAndInputPlaceholder()
        
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textColor = UIColor.white
        titleLabel.font = self.styles.bodyFont.withSize(24)
        titleLabel.attributedText = NSAttributedString(string: titleText, attributes: [
            NSFontAttributeName : self.styles.bodyFont.withSize(24),
            NSKernAttributeName : 0.7
            ])
        blurredBgView.contentView.addSubview(titleLabel)
        
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byTruncatingTail
        messageLabel.textColor = UIColor.white
        messageLabel.font = self.styles.detailFont.withSize(14)
        blurredBgView.contentView.addSubview(messageLabel)
        
        buttonsView.onButtonTap = { [weak self] (buttonTitle) in
            self?.finishWithMessage(buttonTitle)
        }
        blurredBgView.contentView.addSubview(buttonsView)
        
        messageInputView.contentInset = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        messageInputView.backgroundColor = UIColor(red:0.232, green:0.247, blue:0.284, alpha:1)
        messageInputView.layer.cornerRadius = 20
        messageInputView.font = self.styles.bodyFont
        messageInputView.textColor = Colors.whiteColor()
        messageInputView.placeholderColor = Colors.whiteColor().withAlphaComponent(0.7)
        messageInputView.separatorColor = nil
        messageInputView.updateSendButtonStyle(withFont: self.styles.buttonFont, color: Colors.marbleMedColor())
        messageInputView.displayMediaButton = false
        messageInputView.displayBorderTop = false
        messageInputView.placeholderText = placeholderText
        messageInputView.delegate = self
        blurredBgView.contentView.addSubview(messageInputView)
        
        connectionStatusLabel.textColor = UIColor.white
        connectionStatusLabel.font = self.styles.detailFont
        connectionStatusLabel.numberOfLines = 1
        connectionStatusLabel.alpha = 0.5
        updateConnectionStatusLabel()
        // disabling for now
//        blurredBgView.contentView.addSubview(connectionStatusLabel)
        
        keyboardObserver.delegate = self
        
        setAppOpenResponse(appOpenResponse: appOpenResponse, animated: appOpenResponse != nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        messageInputView.delegate = nil
        keyboardObserver.delegate = nil
        tapGesture?.delegate = nil
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation Bar
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barStyle = .blackTranslucent
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
            navigationBar.tintColor = UIColor.white
        }
        
        // View
        
        view.backgroundColor = UIColor.clear
        view.addSubview(blurredBgView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.registerForNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        dismissKeyboard()
        
        keyboardObserver.deregisterForNotification()
    }
    
    // MARK: Content
    
    func updateConnectionStatusLabel() {
        // Do stuff
        switch connectionStatus {
        case .disconnected:
            connectionStatusLabel.text = ASAPPLocalizedString("You are not connected.")
            connectionStatusLabel.alpha = 0.5
            break
         
        case .connecting:
            connectionStatusLabel.text = ASAPPLocalizedString("Connecting...")
            connectionStatusLabel.alpha = 0.3
            break
            
        case .connected:
            connectionStatusLabel.text = ASAPPLocalizedString("Connected")
            connectionStatusLabel.alpha = 0.0
            break
        }
    }
    
    // MARK: Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateFrames()
    }
    
    func updateFrames() {
        
        blurredBgView.frame = view.bounds
        blurredColorLayer.frame = blurredBgView.bounds
        
        let additionalTextInset: CGFloat = 5
        let contentWidth = view.bounds.width - contentInset.left - contentInset.right
        let textWidth = floor(0.85 * contentWidth - 2 * additionalTextInset)
        let textLeft = contentInset.left + additionalTextInset
        
        var textTop = contentInset.top
        if let navigationBar = navigationController?.navigationBar {
            textTop = navigationBar.frame.maxY + contentInset.top
        }
        
        // Title
        let titleHeight = ceil(titleLabel.sizeThatFits(CGSize(width: textWidth, height: 0)).height)
        titleLabel.frame = CGRect(x: textLeft, y: textTop, width: textWidth, height: titleHeight)
        textTop = titleLabel.frame.maxY
        
        let isExpanded = keyboardOffset <= 0
        
        // Message
        let messageHeight = ceil(messageLabel.sizeThatFits(CGSize(width: textWidth, height: 0)).height)
        if titleHeight > 0 && messageHeight > 0 && isExpanded {
            textTop += 10
        }
        messageLabel.frame = CGRect(x: textLeft, y: textTop, width: textWidth, height: messageHeight)
        
        if isExpanded {
            if viewContentsVisible {
                messageLabel.alpha = 1
            }
            textTop = messageLabel.frame.maxY + 38
        } else {
            textTop += 25
            messageLabel.alpha = 0
        }
       
        // Input View
        var visibleBottom = view.bounds.height
        if keyboardOffset > 0 {
            visibleBottom -= keyboardOffset
        }
        
        let inputHeight = ceil(messageInputView.sizeThatFits(CGSize(width: contentWidth, height: 300)).height)
        let inputTop = visibleBottom - contentInset.bottom - inputHeight
        messageInputView.frame = CGRect(x: contentInset.left, y: inputTop, width: contentWidth, height: inputHeight)
        messageInputView.layoutSubviews()
        
        // Connection Status
        let statusTop = messageInputView.frame.maxY + 2
        let statusHeight = min(contentInset.bottom - 2, ceil(connectionStatusLabel.font.lineHeight))
        let statusLeft = messageInputView.frame.minX + floor(messageInputView.layer.cornerRadius / 2.0)
        connectionStatusLabel.frame = CGRect(x: statusLeft, y: statusTop, width: contentWidth, height: statusHeight)
        
        // Buttons View
        var buttonsTop: CGFloat
        if isExpanded {
            buttonsTop = messageLabel.frame.maxY + 38
        } else {
            buttonsTop = titleLabel.frame.maxY + 25
        }
        let buttonsHeight = messageInputView.frame.minY - buttonsTop - 10
        buttonsView.frame = CGRect(x: textLeft, y: buttonsTop, width: contentWidth, height: buttonsHeight)
        buttonsView.updateFrames()
    }
    
    func updateFramesAnimated() {
        UIView.animate(withDuration: 0.2, animations: {
            self.updateFrames()
        })
    }
    
    // MARK: Actions
    
    func finishWithMessage(_ message: String) {
        dismissKeyboard()
        delegate?.chatWelcomeViewController(self, didFinishWithText: message)
    }
    
    func didTapCancel() {
        dismissKeyboard()
        messageInputView.clear()
        delegate?.chatWelcomeViewControllerDidTapX(self)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK:- Saving Text
    
    let storageKeyWelcomeTitle = "SRSPredictiveWelcomeTitle"
    let storageKeyWelcomeInputPlaceholder = "SRSPredictiveInputPlaceholder"
    
    func getTitleAndInputPlaceholder() -> (String /* Title */, String /* Placeholder */) {
        let title = UserDefaults.standard.string(forKey: storageKeyWelcomeTitle) ?? ASAPPLocalizedString("How can we help?")
        let placeholder = UserDefaults.standard.string(forKey: storageKeyWelcomeInputPlaceholder) ?? ASAPPLocalizedString("Ask a new question...")
        return (title, placeholder)
    }
    
    func saveTitle(title: String?, placeholder: String?) {
        if let title = title {
            UserDefaults.standard.set(title, forKey: storageKeyWelcomeTitle)
        }
        if let placeholder = placeholder {
            UserDefaults.standard.set(placeholder, forKey: storageKeyWelcomeInputPlaceholder)
        }
    }
}

// MARK:- UIGestureRecognizerDelegate

extension ChatWelcomeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view {
            if touchView.isDescendant(of: buttonsView) || touchView.isDescendant(of: messageInputView) {
                return false
            }
        }
        return true
    }
}

// MARK:- ChatInputViewDelegate

extension ChatWelcomeViewController: ChatInputViewDelegate {
    func chatInputView(_ chatInputView: ChatInputView, didTypeMessageText text: String?) {
        // No-op
    }
    
    func chatInputView(_ chatInputView: ChatInputView, didTapSendMessage message: String) {
        chatInputView.clear()
        finishWithMessage(message)
    }
    
    func chatInputView(_ chatInputView: ChatInputView, didTapMediaButton mediaButton: UIButton) {
        // No-op
    }
    
    func chatInputViewDidChangeContentSize(_ chatInputView: ChatInputView) {
        updateFramesAnimated()
    }
}

// MARK:- KeyboardObserver

extension ChatWelcomeViewController: KeyboardObserverDelegate {
    
    func keyboardWillUpdateVisibleHeight(_ height: CGFloat, withDuration duration: TimeInterval, animationCurve: UIViewAnimationOptions) {
        keyboardOffset = height
        
        if keyboardOffset > 0 {
            buttonsView.expanded = false
        } else {
            buttonsView.expanded = true
        }
        updateFramesAnimated()
    }
}

// MARK:- External API

extension ChatWelcomeViewController {
    func setAppOpenResponse(appOpenResponse: SRSAppOpenResponse?, animated: Bool) {
        guard let appOpenResponse = appOpenResponse else {
            self.appOpenResponse = nil
            messageLabel.text = nil
            messageLabel.alpha = 0.0
            buttonsView.clear()
            return
        }
        
        if appOpenResponse == self.appOpenResponse {
            return
        }
        
        self.appOpenResponse = appOpenResponse
        viewContentsVisible = false
        
        if animated {
            messageLabel.alpha = 0.0
        } else {
            messageLabel.alpha = 1.0
        }
        
        if let customMessage = appOpenResponse.customizedMessage {
            let attrString = NSAttributedString(string: customMessage, attributes: [
                NSFontAttributeName : messageLabel.font,
                NSKernAttributeName : 1.2
                ])
            messageLabel.attributedText = attrString
        } else {
            messageLabel.text = nil
        }
        
        buttonsView.update(relatedButtonTitles: appOpenResponse.customizedActions,
                           otherButtonTitles: appOpenResponse.genericActions,
                           hideButtonsForAnimation: animated)
        
        updateFrames()
        
        Dispatcher.delay(300) {
            UIView.animate(withDuration: 0.4, animations: { 
                self.messageLabel.alpha = 1.0
                }, completion: { (completed) in
                    self.buttonsView.animateButtonsIn(true) {
                        self.viewContentsVisible = true
                    }
            })
        }
        
        saveTitle(title: appOpenResponse.greeting, placeholder: appOpenResponse.inputPlaceholder)
    }
    
    func presentingViewUpdatedVisibility(_ visible: Bool) {
        if visible {
            keyboardObserver.registerForNotifications()
        } else {
            dismissKeyboard()
            keyboardObserver.deregisterForNotification()
        }
    }
}
