//
//  PredictiveViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol PredictiveViewControllerDelegate: class {
    func predictiveViewController(_ viewController: PredictiveViewController, didFinishWithText queryText: String, fromPrediction: Bool)
    func predictiveViewControllerDidTapViewChat(_ viewController: PredictiveViewController)
    func predictiveViewControllerDidTapX(_ viewController: PredictiveViewController)
    func predictiveViewControllerIsConnected(_ viewController: PredictiveViewController) -> Bool
}

class PredictiveViewController: UIViewController {

    fileprivate(set) var appOpenResponse: SRSAppOpenResponse?
    
    weak var delegate: PredictiveViewControllerDelegate?
    
    var tapGesture: UITapGestureRecognizer?
    
    fileprivate(set) var viewContentsVisible = true
    
    // MARK: Private Properties
    
    fileprivate let contentInset = UIEdgeInsets(top: 20, left: 16, bottom: 30, right: 16)
    fileprivate let blurredBgView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    fileprivate let blurredColorLayer = VerticalGradientView()
    fileprivate let titleLabel = UILabel()
    fileprivate let messageLabel = UILabel()
    fileprivate let buttonsView: PredictiveButtonsView
    fileprivate let messageInputView: ChatInputView
    fileprivate let connectionStatusLabel = UILabel()
    fileprivate var finishedInitialAnimation = true
    fileprivate var noConnectionFlashTime: TimeInterval?
    
    fileprivate let keyboardObserver = KeyboardObserver()
    fileprivate var keyboardOffset: CGFloat = 0
    
    // MARK: Initialization
    
    required init(appOpenResponse: SRSAppOpenResponse? = nil) {
        self.appOpenResponse = appOpenResponse
        self.buttonsView = PredictiveButtonsView()
        self.messageInputView = ChatInputView()
        super.init(nibName: nil, bundle: nil)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(PredictiveViewController.dismissKeyboard))
        if let tapGesture = tapGesture {
            tapGesture.cancelsTouchesInView = false
            tapGesture.delegate = self
            blurredBgView.addGestureRecognizer(tapGesture)
        }
        
        blurredColorLayer.update(ASAPP.styles.askViewGradientTopColor,
                                 middleColor: ASAPP.styles.askViewGradientMiddleColor,
                                 bottomColor: ASAPP.styles.askViewGradientBottomColor)
        blurredBgView.contentView.addSubview(blurredColorLayer)
        
        
        let (titleText, placeholderText) = getTitleAndInputPlaceholder()
        
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textColor = UIColor.white
        titleLabel.setAttributedText(titleText,
                                     textStyle: .predictiveGreeting,
                                     color: UIColor.white)
        blurredBgView.contentView.addSubview(titleLabel)
        
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byTruncatingTail
        messageLabel.textColor = UIColor.white
        blurredBgView.contentView.addSubview(messageLabel)
        
        buttonsView.onButtonTap = { [weak self] (buttonTitle, isFromPrediction) in
            self?.finishWithMessage(buttonTitle, fromPrediction: isFromPrediction)
        }
        blurredBgView.contentView.addSubview(buttonsView)
        
        messageInputView.contentInset = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 0)
        messageInputView.backgroundColor = ASAPP.styles.askViewInputBgColor
        messageInputView.layer.cornerRadius = 20
        messageInputView.sendButtonText = ASAPP.strings.predictiveSendButton
        messageInputView.textColor = Colors.whiteColor()
        messageInputView.placeholderColor = Colors.whiteColor().withAlphaComponent(0.7)
        messageInputView.separatorColor = nil
        messageInputView.sendButtonColor = Colors.marbleMedColor()
        messageInputView.displayMediaButton = false
        messageInputView.displayBorderTop = false
        messageInputView.placeholderText = placeholderText
        messageInputView.delegate = self
        blurredBgView.contentView.addSubview(messageInputView)
    
        connectionStatusLabel.backgroundColor = UIColor(red:0.966, green:0.394, blue:0.331, alpha:1)
        connectionStatusLabel.setAttributedText(ASAPP.strings.predictiveNoConnectionText,
                                                textStyle: .connectionStatusBanner,
                                                color: UIColor.white)
        connectionStatusLabel.textAlignment = .center
        connectionStatusLabel.alpha = 0.0
        blurredBgView.contentView.addSubview(connectionStatusLabel)
        
        keyboardObserver.delegate = self
        
        setAppOpenResponse(appOpenResponse: appOpenResponse, animated: appOpenResponse != nil)
        
        updateDisplay()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PredictiveViewController.updateDisplay),
                                               name: Notification.Name.UIContentSizeCategoryDidChange,
                                               object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        messageInputView.delegate = nil
        keyboardObserver.delegate = nil
        tapGesture?.delegate = nil
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Display
    
    
    func updateDisplay() {
        let viewChatButton = UIBarButtonItem.chatBubbleBarButtonItem(title: ASAPP.strings.predictiveBackToChatButton,
                                                                     font: ASAPP.styles.font(for: .navBarButton),
                                                                     textColor: UIColor.white,
                                                                     backgroundColor: UIColor(red:0.201, green:0.215, blue:0.249, alpha:1),
                                                                     style: .respond,
                                                                     target: self,
                                                                     action: #selector(PredictiveViewController.didTapViewChat))
        navigationItem.leftBarButtonItem = viewChatButton
        
        
        let closeButton = UIBarButtonItem.circleCloseBarButtonItem(foregroundColor: UIColor.white,
                                                                   backgroundColor: UIColor(red:0.201, green:0.215, blue:0.249, alpha:1),
                                                                   target: self,
                                                                   action: #selector(PredictiveViewController.didTapCancel))
        closeButton.accessibilityLabel = ASAPP.strings.accessibilityClose
        navigationItem.rightBarButtonItem = closeButton
        
        titleLabel.updateFont(for: .predictiveGreeting)
        messageLabel.updateFont(for: .predictiveMessage)
        
        buttonsView.updateDisplay()
        messageInputView.updateDisplay()
        
        if isViewLoaded {
            view.setNeedsLayout()
        }
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
        
        view.accessibilityViewIsModal = true
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
        
        let noConnectionMargin: CGFloat = 4
        let noConnectionPadding: CGFloat = 10
        let noConnectionHeight = min(contentInset.bottom - noConnectionMargin, ceil(connectionStatusLabel.sizeThatFits(CGSize(width: contentWidth, height: 0)).height) + noConnectionPadding)
        let noConnectionTop = visibleBottom - noConnectionHeight
        connectionStatusLabel.frame = CGRect(x: 0, y: noConnectionTop, width: view.bounds.width, height: noConnectionHeight)
        
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
    
    func flashNoConnectionLabel() {
        
        noConnectionFlashTime = floor(NSDate().timeIntervalSince1970)
        
        let delayBeforeHiding: TimeInterval = 5
        
        func hideNoConnectionLabel() {
            if connectionStatusLabel.alpha == 0 {
                return
            }
            
            let currentTime = ceil(NSDate().timeIntervalSince1970)
            if currentTime > noConnectionFlashTime! + delayBeforeHiding {
                UIView.animate(withDuration: 1.0, animations: { [weak self] in
                    self?.connectionStatusLabel.alpha = 0.0
                })
            }
        }
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.connectionStatusLabel.alpha = 1.0
            self?.connectionStatusLabel.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }, completion: { [weak self] (completed) in
                
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.connectionStatusLabel.transform = .identity
                })
                
                Dispatcher.delay(delayBeforeHiding * 1000 + 10, closure: {
                    hideNoConnectionLabel()
                })
        })
    }
    
    // MARK: Actions
    
    func finishWithMessage(_ message: String, fromPrediction: Bool) {
        guard let delegate = delegate else { return }
        
        if delegate.predictiveViewControllerIsConnected(self) {
            dismissKeyboard()
            delegate.predictiveViewController(self, didFinishWithText: message, fromPrediction: fromPrediction)
            messageInputView.clear()
        } else {
            flashNoConnectionLabel()
        }
    }
    
    func didTapViewChat() {
        dismissKeyboard()
        delegate?.predictiveViewControllerDidTapViewChat(self)
    }
    
    func didTapCancel() {
        dismissKeyboard()
        messageInputView.clear()
        delegate?.predictiveViewControllerDidTapX(self)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK:- Saving Text
    
    let storageKeyWelcomeTitle = "SRSPredictiveWelcomeTitle"
    let storageKeyWelcomeInputPlaceholder = "SRSPredictiveInputPlaceholder"
    
    func getTitleAndInputPlaceholder() -> (String /* Title */, String /* Placeholder */) {
        let title = UserDefaults.standard.string(forKey: storageKeyWelcomeTitle) ?? ASAPP.strings.predictiveWelcomeText
        let placeholder = UserDefaults.standard.string(forKey: storageKeyWelcomeInputPlaceholder) ?? ASAPP.strings.predictiveInputPlaceholder
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

extension PredictiveViewController: UIGestureRecognizerDelegate {
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

extension PredictiveViewController: ChatInputViewDelegate {
    func chatInputView(_ chatInputView: ChatInputView, didTypeMessageText text: String?) {
        // No-op
    }
    
    func chatInputView(_ chatInputView: ChatInputView, didTapSendMessage message: String) {
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

extension PredictiveViewController: KeyboardObserverDelegate {
    
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

extension PredictiveViewController {
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
        } else if keyboardOffset <= 0 {
            messageLabel.alpha = 1.0
        }
        
        if let customMessage = appOpenResponse.customizedMessage {
            messageLabel.setAttributedText(customMessage,
                                           textStyle: .predictiveMessage,
                                           color: UIColor.white)
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
                    if let blockSelf = self {
                        if blockSelf.keyboardOffset <= 0 {
                            self?.messageLabel.alpha = 1.0
                        }
                    }
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
            
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, titleLabel)
        } else {
            dismissKeyboard()
            keyboardObserver.deregisterForNotification()
        }
    }
}