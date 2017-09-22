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

    fileprivate(set) var appOpenResponse: AppOpenResponse?
    
    weak var delegate: PredictiveViewControllerDelegate?
    
    var tapGesture: UITapGestureRecognizer?
    
    var segue: ASAPPSegue = .present
    
    fileprivate(set) var viewContentsVisible = true
    
    // MARK: Private Properties
    
    fileprivate let contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 30, right: 20)
    fileprivate let blurredBgView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    fileprivate let blurredColorLayer = VerticalGradientView()
    fileprivate let titleLabel = UILabel()
    fileprivate let messageLabel = UILabel()
    fileprivate let buttonsView: PredictiveButtonsView
    fileprivate let messageInputView: ChatInputView
    fileprivate let connectionStatusLabel = UILabel()
    fileprivate let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    fileprivate var finishedInitialAnimation = true
    fileprivate var noConnectionFlashTime: TimeInterval?
    
    fileprivate let keyboardObserver = KeyboardObserver()
    fileprivate var keyboardOffset: CGFloat = 0
    
    fileprivate let storageKeyWelcomeTitle = "SRSPredictiveWelcomeTitle"
    fileprivate let storageKeyWelcomeInputPlaceholder = "SRSPredictiveInputPlaceholder"
    
    // MARK: Initialization
    
    required init(appOpenResponse: AppOpenResponse? = nil, segue: ASAPPSegue = .present) {
        self.appOpenResponse = appOpenResponse
        self.buttonsView = PredictiveButtonsView()
        self.messageInputView = ChatInputView()
        self.segue = segue
        super.init(nibName: nil, bundle: nil)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(PredictiveViewController.dismissKeyboard))
        if let tapGesture = tapGesture {
            tapGesture.cancelsTouchesInView = false
            tapGesture.delegate = self
            blurredBgView.addGestureRecognizer(tapGesture)
        }
        
        blurredColorLayer.update(ASAPP.styles.colors.predictiveGradientTop,
                                 middleColor: ASAPP.styles.colors.predictiveGradientMiddle,
                                 bottomColor: ASAPP.styles.colors.predictiveGradientBottom)
        blurredBgView.contentView.addSubview(blurredColorLayer)
        
        let (titleText, placeholderText) = getTitleAndInputPlaceholder()
        
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textColor = ASAPP.styles.colors.predictiveTextPrimary
        titleLabel.setAttributedText(titleText,
                                     textType: .predictiveHeader,
                                     color: ASAPP.styles.colors.predictiveTextPrimary)
        blurredBgView.contentView.addSubview(titleLabel)
        
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byTruncatingTail
        messageLabel.textColor = ASAPP.styles.colors.predictiveTextPrimary
        blurredBgView.contentView.addSubview(messageLabel)
        
        buttonsView.onButtonTap = { [weak self] (buttonTitle, isFromPrediction) in
            self?.finishWithMessage(buttonTitle, fromPrediction: isFromPrediction)
        }
        blurredBgView.contentView.addSubview(buttonsView)
        
        messageInputView.inputColors = ASAPP.styles.colors.predictiveInput
        messageInputView.contentInset = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 0)
        messageInputView.layer.cornerRadius = 20
        messageInputView.sendButtonText = ASAPP.strings.predictiveSendButton
        messageInputView.displayMediaButton = false
        messageInputView.displayBorderTop = false
        messageInputView.placeholderText = placeholderText
        messageInputView.delegate = self
        if let inputBorderColor = ASAPP.styles.colors.predictiveInput.border {
            messageInputView.layer.borderColor = inputBorderColor.cgColor
            messageInputView.layer.borderWidth = 1.0
        }
        blurredBgView.contentView.addSubview(messageInputView)
    
        connectionStatusLabel.backgroundColor = UIColor(red: 0.966, green: 0.394, blue: 0.331, alpha: 1)
        connectionStatusLabel.setAttributedText(ASAPP.strings.predictiveNoConnectionText,
                                                textType: .error,
                                                color: UIColor.white)
        connectionStatusLabel.textAlignment = .center
        connectionStatusLabel.alpha = 0.0
        blurredBgView.contentView.addSubview(connectionStatusLabel)
        
        if ASAPP.styles.colors.predictiveGradientMiddle.isDark() {
            spinner.activityIndicatorViewStyle = .white
        } else {
            spinner.activityIndicatorViewStyle = .gray
        }
        spinner.hidesWhenStopped = true
        blurredBgView.contentView.addSubview(spinner)
        
        keyboardObserver.delegate = self
        
        setAppOpenResponse(appOpenResponse: appOpenResponse, animated: appOpenResponse != nil)
        
        updateDisplay()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(PredictiveViewController.updateDisplay),
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
    
    @objc func updateDisplay() {
        if let titleText = ASAPP.strings.predictiveTitle {
            navigationItem.titleView = createASAPPTitleView(title: titleText, color: ASAPP.styles.colors.predictiveNavBarTitle)
        } else {
            navigationItem.titleView = nil
        }
        
        let chatSide = ASAPP.styles.closeButtonSide(for: segue).opposite()

        let viewChatButton = UIBarButtonItem.asappBarButtonItem(
            title: ASAPP.strings.predictiveBackToChatButton,
            customImage: ASAPP.styles.navBarStyles.buttonImages.backToChat,
            style: .respond,
            location: .predictive,
            side: chatSide,
            target: self,
            action: #selector(PredictiveViewController.didTapViewChat))
        
        let closeButton = UIBarButtonItem.asappCloseBarButtonItem(
            location: .predictive,
            segue: segue,
            target: self,
            action:  #selector(PredictiveViewController.didTapCancel))
        closeButton.accessibilityLabel = ASAPP.strings.accessibilityClose
        
        switch chatSide {
        case .left:
            navigationItem.leftBarButtonItem = viewChatButton
            navigationItem.rightBarButtonItem = closeButton
        case .right:
            navigationItem.leftBarButtonItem = closeButton
            navigationItem.rightBarButtonItem = viewChatButton
        }
        
        titleLabel.updateFont(for: .predictiveHeader)
        messageLabel.updateFont(for: .body)
        
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
            navigationBar.shadowImage = UIImage()
            navigationBar.setBackgroundImage(nil, for: .default)
            navigationBar.setBackgroundImage(nil, for: .compact)
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.backgroundColor = UIColor.clear
            
            if let barBackgroundColor = ASAPP.styles.colors.predictiveNavBarBackground {
                navigationBar.barStyle = .black
                navigationBar.barTintColor = barBackgroundColor
                navigationBar.isTranslucent = false
            } else {
                navigationBar.isTranslucent = true
                navigationBar.barStyle = .blackTranslucent
                navigationBar.backgroundColor = UIColor.clear
            }
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
}

// MARK:- Layout

extension PredictiveViewController {
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
            if let navBarFrame = navigationBar.superview?.convert(navigationBar.frame, to: view) {
                let intersection = view.frame.intersection(navBarFrame)
                if !intersection.isNull {
                    textTop = intersection.maxY + contentInset.top
                }
            }
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
        
        // Spinner
        spinner.center = blurredBgView.center
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
            }, completion: { [weak self] _ in
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.connectionStatusLabel.transform = .identity
                })
                
                Dispatcher.delay(delayBeforeHiding * 1000 + 10, closure: {
                    hideNoConnectionLabel()
                })
        })
    }
}

// MARK:- Actions

extension PredictiveViewController {
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
    
    @objc func didTapViewChat() {
        dismissKeyboard()
        delegate?.predictiveViewControllerDidTapViewChat(self)
    }
    
    @objc func didTapCancel() {
        dismissKeyboard()
        messageInputView.clear()
        delegate?.predictiveViewControllerDidTapX(self)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK:- Saving Text

extension PredictiveViewController {
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
    func setAppOpenResponse(appOpenResponse: AppOpenResponse?, animated: Bool) {
        guard let appOpenResponse = appOpenResponse else {
            self.appOpenResponse = nil
            messageLabel.text = nil
            messageLabel.alpha = 0.0
            spinner.stopAnimating()
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
                                           textType: .body,
                                           color: ASAPP.styles.colors.predictiveTextPrimary)
        } else {
            messageLabel.text = nil
        }
        
        if keyboardOffset > 0 {
            buttonsView.expanded = false
            buttonsView.update(relatedButtonTitles: appOpenResponse.customizedActions,
                               otherButtonTitles: appOpenResponse.genericActions,
                               hideButtonsForAnimation: animated)
            spinner.stopAnimating()
            buttonsView.animateButtonsIn()
            viewContentsVisible = true
        } else {
            buttonsView.update(relatedButtonTitles: appOpenResponse.customizedActions,
                               otherButtonTitles: appOpenResponse.genericActions,
                               hideButtonsForAnimation: animated)
            
            updateFrames()
            spinner.stopAnimating()
            
            Dispatcher.delay(300) {
                UIView.animate(withDuration: 0.4, animations: { [weak self] in
                    if let blockSelf = self {
                        if blockSelf.keyboardOffset <= 0 {
                            self?.messageLabel.alpha = 1.0
                        }
                    }
                }, completion: { [weak self] _ in
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
            
            if appOpenResponse == nil {
                spinner.startAnimating()
            }
            
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, titleLabel)
        } else {
            dismissKeyboard()
            keyboardObserver.deregisterForNotification()
        }
    }
}
