//
//  ASAPPButton.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/5/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

public class ASAPPButton: UIView {
    
    public let config: ASAPPConfig
    
    public let user: ASAPPUser
    
    public let presentingViewController: UIViewController
    
    public let appCallbackHandler: ASAPPAppCallbackHandler

    // MARK:- Private Properties: UI
    
    fileprivate enum ASAPPButtonState {
        case normal
        case highlighted
    }
    
    fileprivate var currentState: ASAPPButtonState {
        return isTouching ? .highlighted : .normal
    }
    
    fileprivate let backgroundColors = [ASAPPButtonState.normal : ASAPP.styles.colors.helpButtonBackground,
                                        ASAPPButtonState.highlighted : ASAPP.styles.colors.helpButtonBackground.highlightColor()]
    
    fileprivate let contentView = UIView()
    
    fileprivate let label = UILabel()
    
    fileprivate var presentationAnimator: ButtonPresentationAnimator?
    
    fileprivate var isTouching = false {
        didSet {
            updateDisplay()
        }
    }
    
    fileprivate var isWaitingToAnimateIn = false
    
    // MARK:- Initialization
    
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
        
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.cornerRadius = frame.height / 2.0
        
        presentationAnimator = ButtonPresentationAnimator(withButtonView: self)
        
        addSubview(contentView)
        
        updateDisplay()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ASAPPButton.updateDisplay),
                                               name: Notification.Name.UIContentSizeCategoryDidChange,
                                               object: nil)
        
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK:- Layout
    
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
    
    public override var intrinsicContentSize : CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func updateCornerRadius() {
        if transform == CGAffineTransform.identity {
            contentView.layer.cornerRadius = frame.height / 2.0
        }
    }
}

// MARK:- Button Display

extension ASAPPButton {
    
    func updateDisplay() {
        label.setAttributedText(ASAPP.strings.asappButton,
                                textStyle: .asappButton,
                                color: ASAPP.styles.helpButtonForegroundColor)
        
        if let buttonBackgroundColor = backgroundColors[currentState] {
            contentView.alpha = 1
            contentView.backgroundColor = buttonBackgroundColor
        } else if isTouching {
            contentView.alpha = 0.58
        } else {
            contentView.alpha = 1
        }
        
     
        switch currentState {
        case .normal:
            contentView.layer.shadowOpacity = 0.5
            contentView.layer.shadowRadius = 3
            contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
            break
            
        case .highlighted:
            contentView.layer.shadowOpacity = 0.6
            contentView.layer.shadowRadius = 1
            contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
            break
        }
    }
}

// MARK:- Touches

extension ASAPPButton {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchesInBounds(touches) {
            isTouching = true
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTouching && !touchesInBounds(touches) {
            touchesCancelled(touches, with: event)
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTouching && touchesInBounds(touches) {
            didTap()
        }
        isTouching = false
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        isTouching = false
    }
    
    // MARK: Utilies
    
    func touchesInBounds(_ touches: Set<UITouch>) -> Bool {
        guard let touch = touches.first else { return false }
        
        let touchLocation = touch.location(in: self)
        let extendedTouchRange: CGFloat = 30.0
        let touchableArea = bounds.insetBy(dx: -extendedTouchRange, dy: -extendedTouchRange)
        
        return touchableArea.contains(touchLocation)
    }
}

// MARK:- Actions

extension ASAPPButton {
    
    func didTap() {
        let chatViewController = ChatViewController(config: config, user: user, appCallbackHandler: appCallbackHandler)
        
        let navigationController = NavigationController(rootViewController: chatViewController)
        
        navigationController.modalPresentationStyle = .custom
        navigationController.transitioningDelegate = presentationAnimator
        navigationController.modalPresentationCapturesStatusBarAppearance = true
        
        presentingViewController.present(navigationController, animated: true, completion: nil)
    }
    
    func didBeginLongHold() {
        DebugLog.d("DidBeginLongHold()")
    }
    
    func didFinishLongHold() {
        DebugLog.d("DidFinishLongHold()")
    }
}

// MARK:- Animations

extension ASAPPButton {
    public func triggerTap() {
        didTap()
    }
    
    public func hideUntilAnimateInIsCalled() {
        if isWaitingToAnimateIn { return }
        layoutSubviews()
        
        isWaitingToAnimateIn = true
        var transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        transform = transform.rotated(by: CGFloat(3.0 * .pi / 4.0))
        self.contentView.transform = transform
        self.contentView.alpha = 0.0
    }
    
    public func animateIn(afterDelay delay: TimeInterval = 0) {
        UIView.animate(withDuration: 0.5, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: { [weak self] in
            self?.contentView.transform = CGAffineTransform.identity
            self?.contentView.alpha = 1.0
        }) { [weak self] (completed) in
            self?.isWaitingToAnimateIn = false
        }
    }
}
