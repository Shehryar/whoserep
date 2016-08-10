//
//  ASAPPButton.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/5/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

public class ASAPPButton: UIView {

    /// The ViewController that will present the ASAPP view controller
    public var presentingViewController: UIViewController
    
    public var credentials: Credentials?
    
    public var styles: ASAPPStyles = ASAPPStyles()
    
    public var customPresentationDisabled: Bool = false
    
    public var shadowDisabled: Bool = false {
        didSet {
            updateButtonDisplay()
        }
    }
    
    /// This will be called after the user taps the button and the ASAPP view controll is presented
    public var onTapListenerBlock: (() -> Void)?
    
    // MARK: Private Properties: UI
    
    enum ASAPPButtonState {
        case Normal
        case Highlighted
    }
    
    private var currentState: ASAPPButtonState {
        return isTouching ? .Highlighted : .Normal
    }
    
    private var backgroundColors = [ASAPPButtonState.Normal : UIColor(red:0.155,  green:0.596,  blue:0.922, alpha:1),
                                    ASAPPButtonState.Highlighted : UIColor(red:0.109,  green:0.456,  blue:0.711, alpha:1)]
    
    private var foregroundColors = [ASAPPButtonState.Normal : Colors.whiteColor(),
                                    ASAPPButtonState.Highlighted : Colors.whiteColor()]
    
    private let contentView = UIView()
    
    private let imageView = UIImageView()
    
    private var presentationAnimator: ButtonPresentationAnimator?
    
    // MARK: Private Properties: Touch
    
    private var isTouching = false {
        didSet {
            updateButtonDisplay()
        }
    }
    
    private var isLongPressing = false
    
    private var isWaitingToAnimateIn = false
    
    // MARK: Initialization
    
    func commonInit() {
        clipsToBounds = false
        autoresizesSubviews = false
        
        contentView.layer.shadowColor = UIColor.blackColor().CGColor
        contentView.layer.cornerRadius = CGRectGetHeight(frame) / 2.0
        
        presentationAnimator = ButtonPresentationAnimator(withButtonView: self)
        
        updateButtonDisplay()
        contentView.addSubview(imageView)
        addSubview(contentView)
    }
    
    required public init(withPresentingViewController presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        commonInit()
    }
    
    override public init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented. Must initialize using init(withPresentingViewController:)")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Must initialize using init(withPresentingViewController:)")
    }
    
    // MARK: Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let currentAlpha = contentView.alpha
        let currentTransform = contentView.transform
        
        contentView.alpha = 0.0
        contentView.transform = CGAffineTransformIdentity
        contentView.frame = bounds;
        updateCornerRadius()
        
        let imageInset = floor(0.25 * CGRectGetHeight(bounds))
        imageView.frame = UIEdgeInsetsInsetRect(contentView.bounds, UIEdgeInsets(top: imageInset, left: imageInset, bottom: imageInset, right: imageInset))
        
        contentView.alpha = currentAlpha
        contentView.transform = currentTransform
    }
    
    public override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func updateCornerRadius() {
        if CGAffineTransformEqualToTransform(transform, CGAffineTransformIdentity) {
            contentView.layer.cornerRadius = CGRectGetHeight(frame) / 2.0
        }
    }
}

// MARK:- Button Display

extension ASAPPButton {
    func updateButtonDisplay() {
        if let buttonBackgroundColor = backgroundColors[currentState] {
            contentView.alpha = 1
            contentView.backgroundColor = buttonBackgroundColor
        } else if isTouching {
            contentView.alpha = 0.58
        } else {
            contentView.alpha = 1
        }
        
        if let buttonForegroundColor = foregroundColors[currentState] {
            imageView.image = Images.asappButtonIcon(fillColor: buttonForegroundColor)
        } else if imageView.image == nil {
            imageView.image = Images.asappButtonIcon(fillColor: UIColor.whiteColor())
        }
        
        if shadowDisabled {
            contentView.layer.shadowOpacity = 0
            contentView.layer.shadowColor = nil
        } else {
            switch currentState {
            case .Normal:
                contentView.layer.shadowOpacity = 0.5
                contentView.layer.shadowRadius = 3
                contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
                break
                
            case .Highlighted:
                contentView.layer.shadowOpacity = 0.6
                contentView.layer.shadowRadius = 1
                contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
                break
            }
        }
    }
}

// MARK:- Touches

extension ASAPPButton {
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touchesInBounds(touches) {
            isTouching = true
        }
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isTouching && !touchesInBounds(touches) {
            touchesCancelled(touches, withEvent: event)
        }
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isTouching && touchesInBounds(touches) {
            didTap()
        }
        isTouching = false
    }
    
    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        isTouching = false
    }
    
    // MARK: Utilies
    
    func touchesInBounds(touches: Set<UITouch>) -> Bool {
        guard let touch = touches.first else { return false }
        
        let touchLocation = touch.locationInView(self)
        let extendedTouchRange: CGFloat = 30.0
        let touchableArea = CGRectInset(bounds, -extendedTouchRange, -extendedTouchRange)
        
        return CGRectContainsPoint(touchableArea, touchLocation)
    }
}

// MARK:- Actions

extension ASAPPButton {
    func didTap() {
        guard let credentials = credentials else {
            DebugLogError("Missing credentials in ASAPPButton.")
            return
        }
                
        let chatViewController = ASAPP.createChatViewController(withCredentials: credentials, styles: styles)
        chatViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.xLightIcon(fillColor: styles.foregroundColor2), style: .Plain, target: self, action: #selector(ASAPPButton.dismissChat))
        
        
        let navigationController = UINavigationController(rootViewController: chatViewController)
        let barTintColor = styles.backgroundColor2
        navigationController.navigationBar.barTintColor = barTintColor
        if barTintColor.isBright() {
            navigationController.navigationBar.barStyle = .Default
        } else {
            navigationController.navigationBar.barStyle = .Black
        }
        navigationController.navigationBar.tintColor = styles.foregroundColor2
        navigationController.navigationBar.opaque = true
        navigationController.navigationBar.translucent = false
        
        if !customPresentationDisabled {
            navigationController.modalPresentationStyle = .Custom
            navigationController.transitioningDelegate = presentationAnimator
        }
        
        presentingViewController.presentViewController(navigationController, animated: true, completion: nil)
        
        onTapListenerBlock?()
    }
    
    func dismissChat() {
        presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didBeginLongHold() {
        DebugLog("DidBeginLongHold()")
    }
    
    func didFinishLongHold() {
        DebugLog("DidFinishLongHold()")
    }
}

// MARK:- Animations

extension ASAPPButton {
    public func hideUntilAnimateInIsCalled() {
        if isWaitingToAnimateIn { return }
        layoutSubviews()
        
        isWaitingToAnimateIn = true
        var transform = CGAffineTransformMakeScale(0.01, 0.01)
        transform = CGAffineTransformRotate(transform, CGFloat(3 * M_PI_4))
        self.contentView.transform = transform
        self.contentView.alpha = 0.0
    }
    
    public func animateIn(afterDelay delay: NSTimeInterval = 0) {
        UIView.animateWithDuration(0.5, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .BeginFromCurrentState, animations: {
            self.contentView.transform = CGAffineTransformIdentity
            self.contentView.alpha = 1.0
            }) { (completed) in
                self.isWaitingToAnimateIn = false
        }
    }
}
