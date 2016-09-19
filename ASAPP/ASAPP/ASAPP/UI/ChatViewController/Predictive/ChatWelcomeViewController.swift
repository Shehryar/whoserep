//
//  ChatWelcomeViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol ChatWelcomeViewControllerDelegate {
    func chatWelcomeViewController(viewController: ChatWelcomeViewController, didFinishWithText queryText: String)
    func chatWelcomeViewControllerDidCancel(viewController: ChatWelcomeViewController)
}

class ChatWelcomeViewController: UIViewController {

    let appOpenResponse: SRSAppOpenResponse
    
    let styles: ASAPPStyles
    
    var delegate: ChatWelcomeViewControllerDelegate?
    
    var tapGesture: UITapGestureRecognizer?
    
    private(set) var viewContentsVisible = true
    
    // MARK: Private Properties
    
    private let contentInset = UIEdgeInsets(top: 5, left: 30, bottom: 30, right: 30)
    private let blurredBgView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    private let blurredColorLayer = CALayer()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let buttonsView: ChatWelcomeButtonsView
    private let messageInputView = ChatInputView()
    private var finishedInitialAnimation = true
    
    private let keyboardObserver = KeyboardObserver()
    private var keyboardOffset: CGFloat = 0
    
    // MARK: Initialization
    
    required init(appOpenResponse: SRSAppOpenResponse?, styles: ASAPPStyles?, hideViewContents: Bool = true) {
        self.appOpenResponse = appOpenResponse ?? SRSAppOpenResponse(greeting: nil)
        self.styles = styles ?? ASAPPStyles()
        self.buttonsView = ChatWelcomeButtonsView(styles: styles)
        super.init(nibName: nil, bundle: nil)
        
        let closeButton = Button()
        closeButton.insetRight = 0.0
        closeButton.image = Images.iconX()
        closeButton.foregroundColor = UIColor.whiteColor()
        closeButton.imageSize = CGSize(width: 13, height: 13)
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
        
        blurredColorLayer.backgroundColor = Colors.steelLightColor().colorWithAlphaComponent(0.5).CGColor
        blurredBgView.contentView.layer.insertSublayer(blurredColorLayer, atIndex: 0)
        
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .ByTruncatingTail
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = self.styles.bodyFont.fontWithSize(24)
        titleLabel.text = self.appOpenResponse.greeting
        blurredBgView.contentView.addSubview(titleLabel)
        
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .ByTruncatingTail
        messageLabel.textColor = UIColor.whiteColor()
        messageLabel.font = self.styles.bodyFont
        messageLabel.text = self.appOpenResponse.customizedMessage
        blurredBgView.contentView.addSubview(messageLabel)
        
        buttonsView.setButtonTitles(self.appOpenResponse.actions,
                                    highlightFirstButton: self.appOpenResponse.firstActionIsForCustomizedMessage,
                                    hideButtonsForAnimation: hideViewContents)
        buttonsView.onButtonTap = { [weak self] (buttonTitle) in
            self?.finishWithMessage(buttonTitle)
        }
        blurredBgView.contentView.addSubview(buttonsView)
        
        messageInputView.contentInset = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        messageInputView.backgroundColor = Colors.steelDarkColor()
        messageInputView.layer.cornerRadius = 20
        messageInputView.font = self.styles.bodyFont
        messageInputView.textColor = Colors.whiteColor()
        messageInputView.placeholderColor = Colors.whiteColor().colorWithAlphaComponent(0.7)
        messageInputView.separatorColor = nil
        messageInputView.updateSendButtonStyle(withFont: self.styles.buttonFont, color: Colors.marbleMedColor())
        messageInputView.displayMediaButton = false
        messageInputView.displayBorderTop = false
        messageInputView.placeholderText = ASAPPLocalizedString("Ask a new question...")
        messageInputView.delegate = self
        blurredBgView.contentView.addSubview(messageInputView)
        
        keyboardObserver.delegate = self
        
        if hideViewContents {
            viewContentsVisible = false
            finishedInitialAnimation = false
            messageLabel.alpha = 0.0
            messageInputView.alpha = 0.0
        }
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
            navigationBar.barStyle = .BlackTranslucent
            navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            navigationBar.shadowImage = UIImage()
            navigationBar.tintColor = UIColor.whiteColor()
        }
        
        // View
        
        view.backgroundColor = UIColor.clearColor()
        view.addSubview(blurredBgView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.registerForNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        dismissKeyboard()
        
        keyboardObserver.deregisterForNotification()
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
        let contentWidth = CGRectGetWidth(view.bounds) - contentInset.left - contentInset.right
        let textWidth = floor(0.85 * contentWidth - 2 * additionalTextInset)
        let textLeft = contentInset.left + additionalTextInset
        
        var textTop = contentInset.top
        if let navigationBar = navigationController?.navigationBar {
            textTop = CGRectGetMaxY(navigationBar.frame) + contentInset.top
        }
        
        // Title
        let titleHeight = ceil(titleLabel.sizeThatFits(CGSize(width: textWidth, height: 0)).height)
        titleLabel.frame = CGRect(x: textLeft, y: textTop, width: textWidth, height: titleHeight)
        textTop = CGRectGetMaxY(titleLabel.frame)
        
        let isExpanded = keyboardOffset <= 0
        
        // Message
        let messageHeight = ceil(messageLabel.sizeThatFits(CGSize(width: textWidth, height: 0)).height)
        if titleHeight > 0 && messageHeight > 0 && isExpanded {
            textTop += 10
        }
        messageLabel.frame = CGRect(x: textLeft, y: textTop, width: textWidth, height: messageHeight)
        
        if isExpanded {
            if finishedInitialAnimation {
                messageLabel.alpha = 1
            }
            textTop = CGRectGetMaxY(messageLabel.frame) + 38
        } else {
            textTop += 25
            messageLabel.alpha = 0
        }
        
        // Buttons View
        let buttonsHeight = ceil(buttonsView.sizeThatFits(CGSize(width: contentWidth, height: 0)).height)
        buttonsView.frame = CGRect(x: textLeft, y: textTop, width: contentWidth, height: buttonsHeight)
        buttonsView.updateFrames()
        
        // Input View
        let inputHeight = ceil(messageInputView.sizeThatFits(CGSize(width: contentWidth, height: 300)).height)
        var inputTop = CGRectGetHeight(view.bounds) - inputHeight
        if keyboardOffset > 0 {
            inputTop -= keyboardOffset + min(contentInset.left, contentInset.bottom)
        } else {
           inputTop -= contentInset.bottom
        }
        messageInputView.frame = CGRect(x: contentInset.left, y: inputTop, width: contentWidth, height: inputHeight)
        messageInputView.layoutSubviews()
        
        buttonsView.maxVisibleHeight = CGRectGetMinY(messageInputView.frame) - CGRectGetMinY(buttonsView.frame) - 6
    }
    
    func updateFramesAnimated() {
        UIView.animateWithDuration(0.2, animations: {
            self.updateFrames()
        })
    }
    
    // MARK: Actions
    
    func finishWithMessage(message: String) {
        dismissKeyboard()
        delegate?.chatWelcomeViewController(self, didFinishWithText: message)
    }
    
    func didTapCancel() {
        dismissKeyboard()
        messageInputView.clear()
        delegate?.chatWelcomeViewControllerDidCancel(self)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK:- UIGestureRecognizerDelegate

extension ChatWelcomeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let touchView = touch.view {
            if touchView.isDescendantOfView(buttonsView) || touchView.isDescendantOfView(messageInputView) {
                return false
            }
        }
        return true
    }
}

// MARK:- ChatInputViewDelegate

extension ChatWelcomeViewController: ChatInputViewDelegate {
    func chatInputView(chatInputView: ChatInputView, didTypeMessageText text: String?) {
        // No-op
    }
    
    func chatInputView(chatInputView: ChatInputView, didTapSendMessage message: String) {
        chatInputView.clear()
        finishWithMessage(message)
    }
    
    func chatInputView(chatInputView: ChatInputView, didTapMediaButton mediaButton: UIButton) {
        // No-op
    }
    
    func chatInputViewDidChangeContentSize(chatInputView: ChatInputView) {
        updateFramesAnimated()
    }
}

// MARK:- KeyboardObserver

extension ChatWelcomeViewController: KeyboardObserverDelegate {
    
    func keyboardWillUpdateVisibleHeight(height: CGFloat, withDuration duration: NSTimeInterval, animationCurve: UIViewAnimationOptions) {
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
    private func setViewContentsVisibleAnimated(completion: (() -> Void)? = nil) {
        viewContentsVisible = true
        
        Dispatcher.delay(200) {
            if self.messageLabel.alpha == 0 {
                UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
                    self.messageLabel.alpha = 1.0
                    }, completion: nil)
            }
            Dispatcher.delay(500, closure: {
                self.buttonsView.animateButtonsIn(true, completion: {
                    UIView.animateWithDuration(0.8, delay: 0.4, options: .CurveEaseOut, animations: {
                        self.messageInputView.alpha = 1.0
                        }, completion: { (completed) in
                            self.finishedInitialAnimation = true
                            completion?()
                    })
                })
            })
        }
    }
    
    func presentingViewUpdatedVisibility(visible: Bool) {
        if visible {
            keyboardObserver.registerForNotifications()
            if !viewContentsVisible {
                setViewContentsVisibleAnimated()
            }
        } else {
            dismissKeyboard()
            keyboardObserver.deregisterForNotification()
        }
    }
}
