//
//  ASAPPButton.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/5/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

/**
 An `ASAPPButton` will launch the SDK, showing the view controller based on the configured segue.
 Create one using `ASAPP.createChatButton(appCallbackHandler:presentingViewController:)`.
 */
@objc(ASAPPButton)
public class ASAPPButton: UIView {
    
    let config: ASAPPConfig
    
    let user: ASAPPUser
    
    let presentingViewController: UIViewController
    
    let appCallbackHandler: ASAPPAppCallbackHandler

    // MARK: - Private Properties: UI
    
    private enum ASAPPButtonState {
        case normal
        case highlighted
    }
    
    private var currentState: ASAPPButtonState {
        return isTouching ? .highlighted : .normal
    }
    
    private let backgroundColors = [
        ASAPPButtonState.normal: ASAPP.styles.colors.helpButtonBackground,
        ASAPPButtonState.highlighted: ASAPP.styles.colors.helpButtonBackground.highlightColor()
    ]
    
    private let contentView = UIView()
    
    private let label = UILabel()
    
    private var isTouching = false {
        didSet {
            updateDisplay()
        }
    }
    
    private var isWaitingToAnimateIn = false
    
    // MARK: - Initialization
    
    init(config: ASAPPConfig,
         user: ASAPPUser,
         appCallbackHandler: @escaping ASAPPAppCallbackHandler,
         presentingViewController: UIViewController) {
        
        self.config = config
        self.user = user
        self.appCallbackHandler = appCallbackHandler
        self.presentingViewController = presentingViewController
        
        super.init(frame: CGRect(x: 0, y: 0, width: 65, height: 65))
        
        clipsToBounds = false
        autoresizesSubviews = false
        
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitButton
        accessibilityLabel = ASAPP.strings.asappButton
        
        label.minimumScaleFactor = 0.2
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        contentView.addSubview(label)
        
        contentView.layer.cornerRadius = frame.height / 2.0
        
        addSubview(contentView)
        
        updateDisplay()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(ASAPPButton.updateDisplay),
            name: Notification.Name.UIContentSizeCategoryDidChange,
            object: nil)
    }
    
    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Layout
    
    /**
     Lays out subviews. Just as with `UIView.layoutSubviews()`, you should not call this method directly.
     */
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let currentAlpha = contentView.alpha
        let currentTransform = contentView.transform
        
        contentView.alpha = 0.0
        contentView.transform = CGAffineTransform.identity
        contentView.frame = bounds
        updateCornerRadius()
        
        let labelInset = floor(0.15 * bounds.height)
        label.frame = UIEdgeInsetsInsetRect(contentView.bounds, UIEdgeInsets(top: labelInset, left: labelInset, bottom: labelInset, right: labelInset))
        
        contentView.alpha = currentAlpha
        contentView.transform = currentTransform
    }
    
    /// :nodoc:
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: 72, height: 34)
    }
    
    func updateCornerRadius() {
        if transform == CGAffineTransform.identity {
            contentView.layer.cornerRadius = frame.height / 2.0
        }
    }
    
    // MARK: - Touches
    
    /**
     Overrides `UIView.touchesBegan(_:with:)`.
     
     - parameter touches: A set of `UITouch` instances that represent the touches for the starting phase of the event, which is represented by event. For touches in a view, this set contains only one touch by default. To receive multiple touches, you must set the view's `isMultipleTouchEnabled` property to true.
     - parameter event: The event to which the touches belong.
     */
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchesInBounds(touches) {
            isTouching = true
        }
    }
    
    /**
     Overrides `UIView.touchesMoved(_:with:)`.
     
     - parameter touches: A set of `UITouch` instances that represent the touches for the starting phase of the event, which is represented by event. For touches in a view, this set contains only one touch by default. To receive multiple touches, you must set the view's `isMultipleTouchEnabled` property to true.
     - parameter event: The event to which the touches belong.
     */
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTouching && !touchesInBounds(touches) {
            touchesCancelled(touches, with: event)
        }
    }
    
    /**
     Overrides `UIView.touchesEnded(_:with:)`.
     
     - parameter touches: A set of `UITouch` instances that represent the touches for the starting phase of the event, which is represented by event. For touches in a view, this set contains only one touch by default. To receive multiple touches, you must set the view's `isMultipleTouchEnabled` property to true.
     - parameter event: The event to which the touches belong.
     */
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTouching && touchesInBounds(touches) {
            didTap()
        }
        isTouching = false
    }
    
    /**
     Overrides `UIView.touchesCancelled(_:with:)`.
     
     - parameter touches: A set of `UITouch` instances that represent the touches for the starting phase of the event, which is represented by event. For touches in a view, this set contains only one touch by default. To receive multiple touches, you must set the view's `isMultipleTouchEnabled` property to true.
     - parameter event: The event to which the touches belong.
     */
    public override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        isTouching = false
    }
    
    // MARK: Utilities
    
    func touchesInBounds(_ touches: Set<UITouch>) -> Bool {
        guard let touch = touches.first else { return false }
        
        let touchLocation = touch.location(in: self)
        let extendedTouchRange: CGFloat = 30.0
        let touchableArea = bounds.insetBy(dx: -extendedTouchRange, dy: -extendedTouchRange)
        
        return touchableArea.contains(touchLocation)
    }
}

// MARK: - Button Display

extension ASAPPButton {
    
    @objc func updateDisplay() {
        label.setAttributedText(ASAPP.strings.asappButton,
                                textType: .link,
                                color: ASAPP.styles.colors.helpButtonText)
        
        if let buttonBackgroundColor = backgroundColors[currentState] {
            contentView.alpha = 1
            contentView.backgroundColor = buttonBackgroundColor
        } else if isTouching {
            contentView.alpha = 0.58
        } else {
            contentView.alpha = 1
        }
    }
}

// MARK: - Actions

extension ASAPPButton {
    func didTap() {
        let conversationManager = ConversationManager(config: config, user: user, userLoginAction: nil)
        let chatViewController = ChatViewController(config: config, user: user, segue: ASAPP.styles.segue, conversationManager: conversationManager, appCallbackHandler: appCallbackHandler)
        
        switch ASAPP.styles.segue {
        case .present:
            let navigationController = NavigationController(rootViewController: chatViewController)
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.modalPresentationCapturesStatusBarAppearance = true
            presentingViewController.present(navigationController, animated: true, completion: nil)
        case .push:
            let containerViewController = ContainerViewController(rootViewController: chatViewController)
            presentingViewController.navigationController?.pushViewController(containerViewController, animated: true)
        }
    }
    
    func didBeginLongHold() {
        DebugLog.d("DidBeginLongHold()")
    }
    
    func didFinishLongHold() {
        DebugLog.d("DidFinishLongHold()")
    }
}

extension ASAPPButton {
    // MARK: - Animations
    
    /**
     Simulates a tap on the button, displaying the SDK's view controller.
     */
    public func triggerTap() {
        didTap()
    }
    
    /**
     Hides the button until `animateIn(afterDelay:)` is called.
     */
    public func hideUntilAnimateInIsCalled() {
        if isWaitingToAnimateIn { return }
        layoutSubviews()
        
        isWaitingToAnimateIn = true
        var transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        transform = transform.rotated(by: CGFloat(3.0 * .pi / 4.0))
        self.contentView.transform = transform
        self.contentView.alpha = 0.0
    }
    
    /**
     Reveals the button with an animation.
     
     - parameter delay: A `TimeInterval` after which the animation will start.
     */
    public func animateIn(afterDelay delay: TimeInterval = 0) {
        UIView.animate(withDuration: 0.5, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: { [weak self] in
            self?.contentView.transform = CGAffineTransform.identity
            self?.contentView.alpha = 1.0
        }, completion: { [weak self] _ in
            self?.isWaitingToAnimateIn = false
        })
    }
}
