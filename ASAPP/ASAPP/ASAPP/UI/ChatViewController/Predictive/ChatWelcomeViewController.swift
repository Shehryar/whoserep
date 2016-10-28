//
//  ChatWelcomeViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol ChatWelcomeViewControllerDelegate: class {
    func chatWelcomeViewController(_ viewController: ChatWelcomeViewController, didFinishWithText queryText: String, fromPrediction: Bool)
    func chatWelcomeViewControllerDidTapViewChat(_ viewController: ChatWelcomeViewController)
    func chatWelcomeViewControllerDidTapX(_ viewController: ChatWelcomeViewController)
}

class ChatWelcomeViewController: UIViewController {

    fileprivate(set) var appOpenResponse: SRSAppOpenResponse?
    
    let styles: ASAPPStyles
    
    let strings: ASAPPStrings
    
    weak var delegate: ChatWelcomeViewControllerDelegate?
    
    var tapGesture: UITapGestureRecognizer?
    
    fileprivate(set) var viewContentsVisible = true
    
    // MARK: Private Properties
    
    fileprivate let contentInset = UIEdgeInsets(top: 20, left: 16, bottom: 30, right: 16)
    fileprivate let blurredBgView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    fileprivate let blurredColorLayer = VerticalGradientView()
    fileprivate let titleLabel = UILabel()
    fileprivate let messageLabel = UILabel()
    fileprivate let buttonsView: ChatWelcomeButtonsView
    fileprivate let messageInputView: ChatInputView
    fileprivate var finishedInitialAnimation = true
    
    fileprivate let keyboardObserver = KeyboardObserver()
    fileprivate var keyboardOffset: CGFloat = 0
    
    // MARK: Initialization
    
    required init(appOpenResponse: SRSAppOpenResponse?, styles: ASAPPStyles, strings: ASAPPStrings) {
        self.appOpenResponse = appOpenResponse
        self.styles = styles
        self.strings = strings
        self.buttonsView = ChatWelcomeButtonsView(styles: styles, strings: strings)
        self.messageInputView = ChatInputView(styles: styles, strings: strings)
        super.init(nibName: nil, bundle: nil)
        
        let viewChatButton = UIBarButtonItem.chatBubbleBarButtonItem(title: strings.predictiveBackToChatButton,
                                                                     font: styles.navBarButtonFont,
                                                                     textColor: UIColor.white,
                                                                     backgroundColor: UIColor(red:0.201, green:0.215, blue:0.249, alpha:1),
                                                                     style: .respond,
                                                                     target: self,
                                                                     action: #selector(ChatWelcomeViewController.didTapViewChat))
        navigationItem.leftBarButtonItem = viewChatButton
        
        
        let closeButton = UIBarButtonItem.circleCloseBarButtonItem(foregroundColor: UIColor.white,
                                                                   backgroundColor: UIColor(red:0.201, green:0.215, blue:0.249, alpha:1),
                                                                   target: self,
                                                                   action: #selector(ChatWelcomeViewController.didTapCancel))
        navigationItem.rightBarButtonItem = closeButton
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatWelcomeViewController.dismissKeyboard))
        if let tapGesture = tapGesture {
            tapGesture.cancelsTouchesInView = false
            tapGesture.delegate = self
            blurredBgView.addGestureRecognizer(tapGesture)
        }
        
        blurredColorLayer.update(styles.askViewGradientTopColor,
                                 middleColor: styles.askViewGradientMiddleColor,
                                 bottomColor: styles.askViewGradientBottomColor)
        blurredBgView.contentView.addSubview(blurredColorLayer)
        
        
        let (titleText, placeholderText) = getTitleAndInputPlaceholder()
        
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textColor = UIColor.white
        titleLabel.font = styles.bodyFont.withSize(24)
        titleLabel.attributedText = NSAttributedString(string: titleText, attributes: [
            NSFontAttributeName : styles.bodyFont.withSize(24),
            NSKernAttributeName : 0.7
            ])
        blurredBgView.contentView.addSubview(titleLabel)
        
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byTruncatingTail
        messageLabel.textColor = UIColor.white
        messageLabel.font = styles.detailFont.withSize(14)
        blurredBgView.contentView.addSubview(messageLabel)
        
        buttonsView.onButtonTap = { [weak self] (buttonTitle, isFromPrediction) in
            self?.finishWithMessage(buttonTitle, fromPrediction: isFromPrediction)
        }
        blurredBgView.contentView.addSubview(buttonsView)
        
        messageInputView.contentInset = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 0)
        messageInputView.backgroundColor = styles.askViewInputBgColor
        messageInputView.layer.cornerRadius = 20
        messageInputView.sendButtonText = strings.predictiveSendButton
        messageInputView.textColor = Colors.whiteColor()
        messageInputView.placeholderColor = Colors.whiteColor().withAlphaComponent(0.7)
        messageInputView.separatorColor = nil
        messageInputView.sendButtonColor = Colors.marbleMedColor()
        messageInputView.displayMediaButton = false
        messageInputView.displayBorderTop = false
        messageInputView.placeholderText = placeholderText
        messageInputView.delegate = self
        blurredBgView.contentView.addSubview(messageInputView)
        
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
            navigationBar.shadowImage = nil
            navigationBar.setBackgroundImage(nil, for: .default)
            navigationBar.setBackgroundImage(nil, for: .compact)
            navigationBar.barStyle = .blackTranslucent
            navigationBar.backgroundColor = UIColor.clear
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
            navigationBar.tintColor = UIColor.white
            navigationBar.isTranslucent = true
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
    
    // MARK: Supported Orientations
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateFrames()
    }
    
    func updateFrames() {
        
        blurredBgView.frame = view.bounds
        blurredColorLayer.frame = blurredBgView.bounds
        
        let additionalTextInset: CGFloat = 0.0
        let contentWidth = view.bounds.width - contentInset.left - contentInset.right
        let textWidth = floor(0.91 * contentWidth - 2 * additionalTextInset)
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
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.updateFrames()
        })
    }
    
    // MARK: Actions
    
    func finishWithMessage(_ message: String, fromPrediction: Bool) {
        dismissKeyboard()
        delegate?.chatWelcomeViewController(self, didFinishWithText: message, fromPrediction: fromPrediction)
    }
    
    func didTapViewChat() {
        dismissKeyboard()
        delegate?.chatWelcomeViewControllerDidTapViewChat(self)
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
        let title = UserDefaults.standard.string(forKey: storageKeyWelcomeTitle) ?? strings.predictiveWelcomeText
        let placeholder = UserDefaults.standard.string(forKey: storageKeyWelcomeInputPlaceholder) ?? strings.predictiveInputPlaceholder
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
        finishWithMessage(message, fromPrediction: false)
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
        
        
        if keyboardOffset > 0 {
            buttonsView.expanded = false
            buttonsView.update(relatedButtonTitles: appOpenResponse.customizedActions,
                               otherButtonTitles: appOpenResponse.genericActions,
                               hideButtonsForAnimation: animated)
            buttonsView.animateButtonsIn()
            viewContentsVisible = true
        } else {
            buttonsView.update(relatedButtonTitles: appOpenResponse.customizedActions,
                               otherButtonTitles: appOpenResponse.genericActions,
                               hideButtonsForAnimation: animated)
            
            updateFrames()
            
            Dispatcher.delay(300) {
                UIView.animate(withDuration: 0.4, animations: { [weak self] in
                    
                    self?.messageLabel.alpha = 1.0
                    }, completion: { [weak self] (completed) in
                        self?.buttonsView.animateButtonsIn(true) {
                            self?.viewContentsVisible = true
                        }
                })
            }
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
