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

    private(set) var appOpenResponse: AppOpenResponse?
    
    weak var delegate: PredictiveViewControllerDelegate?
    
    var shouldShowViewChatButton = false {
        didSet {
            if oldValue != shouldShowViewChatButton {
                updateDisplay()
            }
        }
    }
    
    var tapGesture: UITapGestureRecognizer?
    
    var segue: ASAPPSegue = .present
    
    private(set) var viewContentsVisible = true
    
    // MARK: Private Properties
    
    private let contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 21, right: 20)
    private let containerView = UIView()
    private let gradientView = VerticalGradientView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let buttonsView: PredictiveButtonsView
    private(set) var messageInputView: ChatInputView
    private let connectionStatusLabel = UILabel()
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    private var finishedInitialAnimation = true
    private var noConnectionFlashTime: TimeInterval?
    
    private let keyboardObserver = KeyboardObserver()
    private var keyboardOffset: CGFloat = 0
    lazy private var keyboardOffsetThreshold: CGFloat = 0
    
    private var isKeyboardVisible: Bool {
        return keyboardOffset > keyboardOffsetThreshold
    }
    
    private var storageKeyWelcomeTitle: String {
        return "\(ASAPP.config.appId).predictiveWelcomeTitle"
    }
    private var storageKeyWelcomeInputPlaceholder: String {
        return "\(ASAPP.config.appId).predictiveInputPlaceholder"
    }
    
    // MARK: Initialization
    
    required init(appOpenResponse: AppOpenResponse? = nil, segue: ASAPPSegue = .present) {
        self.appOpenResponse = appOpenResponse
        self.buttonsView = PredictiveButtonsView(style: ASAPP.styles.welcomeLayout)
        self.messageInputView = ChatInputView()
        self.segue = segue
        super.init(nibName: nil, bundle: nil)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(PredictiveViewController.dismissKeyboard))
        if let tapGesture = tapGesture {
            tapGesture.cancelsTouchesInView = false
            tapGesture.delegate = self
            containerView.addGestureRecognizer(tapGesture)
        }
        
        gradientView.update(colors: ASAPP.styles.colors.predictiveGradientColors, locations: ASAPP.styles.colors.predictiveGradientLocations)
        containerView.backgroundColor = .clear
        containerView.addSubview(gradientView)
        
        let (titleText, placeholderText) = getTitleAndInputPlaceholder()
        
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textColor = ASAPP.styles.colors.predictiveTextPrimary
        titleLabel.setAttributedText(
            titleText,
            textType: .predictiveHeader,
            color: ASAPP.styles.colors.predictiveTextPrimary)
        containerView.addSubview(titleLabel)
        
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byTruncatingTail
        messageLabel.textColor = ASAPP.styles.colors.predictiveTextPrimary
        containerView.addSubview(messageLabel)
        
        buttonsView.onButtonTap = { [weak self] (buttonTitle, isFromPrediction) in
            self?.finishWithMessage(buttonTitle, fromPrediction: isFromPrediction)
        }
        containerView.addSubview(buttonsView)
        
        messageInputView.inputColors = ASAPP.styles.colors.predictiveInput
        messageInputView.contentInset = UIEdgeInsets(top: 7, left: 20, bottom: 7, right: 0)
        messageInputView.bubbleInset = UIEdgeInsets(top: 0, left: contentInset.left, bottom: contentInset.bottom, right: contentInset.right)
        if let text = ASAPP.strings.predictiveSendButton {
            messageInputView.sendButtonText = text
        } else {
            messageInputView.sendButtonImage = ASAPP.styles.shapeStyles.sendButtonImage
        }
        messageInputView.displayMediaButton = false
        messageInputView.displayBorderTop = false
        messageInputView.isRounded = true
        messageInputView.placeholderText = placeholderText
        messageInputView.delegate = self
        if let inputBorderColor = ASAPP.styles.colors.predictiveInput.border {
            messageInputView.bubbleView.layer.borderColor = inputBorderColor.cgColor
            messageInputView.bubbleView.layer.borderWidth = 1.0
        }
    
        connectionStatusLabel.backgroundColor = UIColor(red: 0.966, green: 0.394, blue: 0.331, alpha: 1)
        connectionStatusLabel.setAttributedText(ASAPP.strings.predictiveNoConnectionText,
                                                textType: .error,
                                                color: UIColor.white)
        connectionStatusLabel.textAlignment = .center
        connectionStatusLabel.alpha = 0.0
        containerView.addSubview(connectionStatusLabel)
        
        spinner.hidesWhenStopped = true
        containerView.addSubview(spinner)
        
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
        if let titleView = ASAPP.views.predictiveTitle {
            navigationItem.titleView = titleView
        } else if let titleText = ASAPP.strings.predictiveTitle {
            navigationItem.titleView = createASAPPTitleView(title: titleText, color: ASAPP.styles.colors.predictiveNavBarTitle)
        } else {
            navigationItem.titleView = nil
        }
        
        let chatSide = ASAPP.styles.closeButtonSide(for: segue).opposite()

        let viewChatButton: NavBarButtonItem?
        
        if shouldShowViewChatButton {
            let button = NavBarButtonItem(location: .predictive, side: chatSide)
            if let customImage = ASAPP.styles.navBarStyles.buttonImages.backToChat {
                button.configImage(customImage)
            } else {
                button.configTitle(ASAPP.strings.predictiveBackToChatButton)
            }
            button.configTarget(self, action: #selector(PredictiveViewController.didTapViewChat))
            viewChatButton = button
        } else {
            viewChatButton = nil
        }
        
        let closeButton = NavCloseBarButtonItem(location: .predictive, side: .right)
            .configSegue(segue)
            .configTarget(self, action: #selector(PredictiveViewController.didTapCancel))
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
        messageLabel.updateFont(for: .predictiveSubheader)
        
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
            navigationBar.backgroundColor = .clear
            
            if let barBackgroundColor = ASAPP.styles.colors.predictiveNavBarBackground {
                navigationBar.barStyle = .black
                navigationBar.barTintColor = barBackgroundColor
                navigationBar.isTranslucent = false
                
                let gradientColors = ASAPP.styles.colors.predictiveGradientColors
                if gradientColors.count >= 1
                   && gradientColors[0].isBright()
                  && barBackgroundColor.isBright() {
                    navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2)
                    navigationBar.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
                    navigationBar.layer.shadowOpacity = 1
                    navigationBar.layer.shadowRadius = 10
                }
            } else {
                navigationBar.isTranslucent = true
                navigationBar.barStyle = .blackTranslucent
                navigationBar.backgroundColor = UIColor.clear
            }
        }
        
        // View
        
        view.backgroundColor = UIColor.clear
        view.addSubview(containerView)
        
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

// MARK: - Layout

extension PredictiveViewController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateFrames()
    }
    
    func updateFrames() {
        switch ASAPP.styles.welcomeLayout {
        case .buttonMenu:
            updateFramesForButtonMenuLayout()
        case .chat:
            updateFramesForChatLayout()
        }
    }
    
    func updateFramesForButtonMenuLayout() {
        updateGeneralFrames()
        
        let contentWidth = view.bounds.width - contentInset.left - contentInset.right
        let textWidth = floor(0.91 * contentWidth)
        let textLeft = contentInset.left
        
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
        
        let isExpanded = !isKeyboardVisible
        
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
        let visibleBottom = view.frame.size.height - keyboardOffset
        
        let inputHeight = ceil(messageInputView.sizeThatFits(CGSize(width: contentWidth, height: .greatestFiniteMagnitude)).height)
        if keyboardOffsetThreshold == 0 {
            keyboardOffsetThreshold = inputHeight
        }
        
        // Buttons View
        var buttonsTop: CGFloat
        if isExpanded {
            buttonsTop = messageLabel.frame.maxY + 38
        } else {
            buttonsTop = titleLabel.frame.maxY + 25
        }
        let buttonsHeight = visibleBottom - buttonsTop - 10
        buttonsView.frame = CGRect(x: textLeft, y: buttonsTop, width: contentWidth, height: buttonsHeight)
        buttonsView.updateFrames()
        
        // Spinner
        let inBetween = (visibleBottom - titleLabel.frame.maxY) / 2
        spinner.center = CGPoint(x: containerView.frame.midX, y: titleLabel.frame.maxY + inBetween)
        updateSpinnerColor()
    }
    
    func updateFramesForChatLayout() {
        updateGeneralFrames()
        
        let additionalInset: CGFloat = 13
        let contentWidth = view.bounds.width - contentInset.left - contentInset.right - 2 * additionalInset
        let textLeft = contentInset.left + additionalInset
        let isExpanded = !isKeyboardVisible
        
        // Input View
        let inputHeight = ceil(messageInputView.sizeThatFits(CGSize(width: contentWidth, height: .greatestFiniteMagnitude)).height)
        if keyboardOffsetThreshold == 0 {
            keyboardOffsetThreshold = inputHeight
        }
        let visibleBottom = view.frame.size.height - max(keyboardOffset, inputHeight) - 5
        
        var frame = gradientView.frame
        if isKeyboardVisible {
            let offset = keyboardOffset - inputHeight
            frame.origin.y = -offset
        } else {
            frame.origin.y = 0
        }
        gradientView.frame = frame
        
        let buttonsNaturalSize = buttonsView.sizeThatFits(CGSize(width: contentWidth, height: .greatestFiniteMagnitude))
        let messageHeight = ceil(messageLabel.sizeThatFits(CGSize(width: contentWidth, height: .greatestFiniteMagnitude)).height)
        let titleHeight = ceil(titleLabel.sizeThatFits(CGSize(width: contentWidth, height: .greatestFiniteMagnitude)).height)
        
        var textTop = contentInset.top
        if let navigationBar = navigationController?.navigationBar {
            if let navBarFrame = navigationBar.superview?.convert(navigationBar.frame, to: view) {
                let intersection = view.frame.intersection(navBarFrame)
                if !intersection.isNull {
                    textTop = intersection.maxY + contentInset.top
                }
            }
        }
        let buttonsCollapsedHeight = visibleBottom - textTop - titleHeight - 15
        
        // Buttons View
        let buttonsNaturalHeight = ceil(buttonsNaturalSize.height)
        let buttonsWidth = buttonsNaturalSize.width
        var buttonsTop: CGFloat
        if isExpanded {
            buttonsTop = visibleBottom - buttonsNaturalHeight
        } else {
            buttonsTop = visibleBottom - min(buttonsCollapsedHeight, buttonsNaturalHeight)
        }
        let buttonsHeight = visibleBottom - buttonsTop
        buttonsView.frame = CGRect(x: textLeft, y: buttonsTop, width: buttonsWidth, height: buttonsHeight)
        buttonsView.updateFrames()
        
        var textBottom = buttonsTop - 40
        
        // Message
        messageLabel.frame = CGRect(x: textLeft, y: textBottom - messageHeight, width: contentWidth, height: messageHeight)
        
        if isExpanded {
            if viewContentsVisible {
                messageLabel.alpha = 1
            }
            textBottom = messageLabel.frame.minY - 5
        } else {
            textBottom = textTop + titleHeight
            messageLabel.alpha = 0
        }
        
        // Title
        titleLabel.frame = CGRect(x: textLeft, y: textBottom - titleHeight, width: contentWidth, height: titleHeight)
        
        // Spinner
        let inBetween = (visibleBottom - titleLabel.frame.maxY) / 2
        spinner.center = CGPoint(x: containerView.frame.midX, y: titleLabel.frame.maxY + inBetween)
        updateSpinnerColor()
    }
    
    func updateGeneralFrames() {
        containerView.frame = view.bounds
        gradientView.frame = containerView.bounds
        
        let visibleBottom = view.frame.size.height - keyboardOffset
        let contentWidth = view.bounds.width - contentInset.left - contentInset.right
        let noConnectionMargin: CGFloat = 4
        let noConnectionPadding: CGFloat = 10
        let noConnectionHeight = min(contentInset.bottom - noConnectionMargin, ceil(connectionStatusLabel.sizeThatFits(CGSize(width: contentWidth, height: 0)).height) + noConnectionPadding)
        let noConnectionTop = visibleBottom - noConnectionHeight - contentInset.bottom
        connectionStatusLabel.frame = CGRect(x: 0, y: noConnectionTop, width: view.bounds.width, height: noConnectionHeight)
    }
    
    func updateSpinnerColor() {
        let point = containerView.convert(spinner.center, to: gradientView)
        if gradientView.layer.color(at: point)?.isDark() == true {
            spinner.activityIndicatorViewStyle = .white
        } else {
            spinner.activityIndicatorViewStyle = .gray
        }
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

// MARK: - Actions

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
        messageInputView.resignFirstResponder()
    }
}

// MARK: - Saving Text

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

// MARK: - UIGestureRecognizerDelegate

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

// MARK: - ChatInputViewDelegate

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

// MARK: - KeyboardObserver

extension PredictiveViewController: KeyboardObserverDelegate {
    
    func keyboardWillUpdateVisibleHeight(_ height: CGFloat, withDuration duration: TimeInterval, animationCurve: UIViewAnimationOptions) {
        keyboardOffset = messageInputView.isFirstResponder ? height : 0
        
        if isKeyboardVisible {
            buttonsView.expanded = false
        } else {
            buttonsView.expanded = true
        }
        updateFramesAnimated()
    }
}

// MARK: - External API

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
        } else if !isKeyboardVisible {
            messageLabel.alpha = 1.0
        }
        
        if let customMessage = appOpenResponse.customizedMessage {
            messageLabel.setAttributedText(
                customMessage,
                textType: .predictiveSubheader,
                color: ASAPP.styles.colors.predictiveTextSecondary)
        } else {
            messageLabel.text = nil
        }
        
        if isKeyboardVisible {
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
                        if !blockSelf.isKeyboardVisible {
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
