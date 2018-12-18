//
//  HelpButton.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/5/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import ASAPP
import UIKit

class HelpButton: UIView {
    let config: ASAPPConfig
    
    let user: ASAPPUser
    
    let presentingViewController: UIViewController
    
    var title: String = "HELP" {
        didSet {
            updateDisplay()
        }
    }
    
    var segue: AppearanceConfig.Segue = .push
    
    // MARK: - Private Properties: UI
    
    fileprivate enum HelpButtonState {
        case normal
        case highlighted
    }
    
    fileprivate var currentState: HelpButtonState {
        return isTouching ? .highlighted : .normal
    }
    
    fileprivate let backgroundColors = [
        HelpButtonState.normal: ASAPP.styles.colors.primary,
        HelpButtonState.highlighted: ASAPP.styles.colors.primary.highlightColor()
    ]
    
    fileprivate let contentView = UIView()
    
    fileprivate let label = UILabel()
    
    fileprivate var isTouching = false {
        didSet {
            updateDisplay()
        }
    }
    
    fileprivate var isWaitingToAnimateIn = false
    
    // MARK: - Initialization
    
    init(config: ASAPPConfig,
         user: ASAPPUser,
         presentingViewController: UIViewController) {
        
        self.config = config
        self.user = user
        self.presentingViewController = presentingViewController
        
        super.init(frame: CGRect(x: 0, y: 0, width: 89, height: 44))
        
        clipsToBounds = false
        autoresizesSubviews = false
        
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = title
        
        label.minimumScaleFactor = 0.2
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        contentView.addSubview(label)
        
        contentView.layer.cornerRadius = frame.height / 2.0
        
        addSubview(contentView)
        
        updateDisplay()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(HelpButton.updateDisplay),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let currentAlpha = contentView.alpha
        let currentTransform = contentView.transform
        
        contentView.alpha = 0
        contentView.transform = .identity
        contentView.frame = bounds
        updateCornerRadius()
        
        let labelInset = floor(0.15 * bounds.height)
        label.frame = contentView.bounds.inset(by: UIEdgeInsets(top: labelInset, left: 0, bottom: labelInset, right: 0))
        
        contentView.alpha = currentAlpha
        contentView.transform = currentTransform
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: 64, height: 34)
    }
    
    func updateCornerRadius() {
        if transform == CGAffineTransform.identity {
            contentView.layer.cornerRadius = frame.height / 2.0
        }
    }
    
    // MARK: - Touches
    
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

extension HelpButton {
    
    @objc func updateDisplay() {
        accessibilityLabel = title
        label.attributedText = NSAttributedString(string: title, attributes: [
            .font: AppSettings.shared.branding.appearanceConfig.fontFamily.bold.withSize(12),
            .kern: 0.5,
            .foregroundColor: UIColor.white
        ])
        
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

extension HelpButton {
    private func createTestRequest(with config: ASAPPConfig) -> URLRequest {
        let connectionRequest = NSMutableURLRequest()
        connectionRequest.url = URL(string: "wss://\(config.apiHostName)/api/websocket")
        return connectionRequest as URLRequest
    }
    
    func didTap() {
        let testRequest = createTestRequest(with: config)
        guard testRequest.url != nil else {
            let alert = UIAlertController(title: "API Host is invalid",
                                          message: "Please make sure the API Host is a valid domain like example.asapp.com",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            presentingViewController.present(alert, animated: true, completion: nil)
            return
        }
        
        switch segue {
        case .present:
            let navigationController = ASAPP.createChatViewControllerForPresenting(fromNotificationWith: nil)
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.modalPresentationCapturesStatusBarAppearance = true
            presentingViewController.present(navigationController, animated: true, completion: nil)
        case .push:
            let containerViewController = ASAPP.createChatViewControllerForPushing(fromNotificationWith: nil)
            presentingViewController.navigationController?.pushViewController(containerViewController, animated: true)
        }
    }
}

extension HelpButton {
    // MARK: - Animations
    
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
            }, completion: { [weak self] _ in
                self?.isWaitingToAnimateIn = false
        })
    }
}
