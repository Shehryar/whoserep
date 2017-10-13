//
//  ModalCardPresentationAnimator.swift
//  AnimationTestingGround
//
//  Created by Mitchell Morgan on 2/10/17.
//  Copyright © 2017 ASAPP, Inc. All rights reserved.
//

import UIKit

protocol UpdatableFrames {
    func updateFrames()
}

protocol ResizableModalCardViewController: UpdatableFrames {
    func viewSizeThatFits(_ size: CGSize) -> CGSize
}

class ModalCardPresentationAnimator: NSObject {
    
    var tapToDismissEnabled = false
    var viewInsetTop: CGFloat = 28.0
    var viewInsetSides: CGFloat = 20.0
    var viewInsetBottom: CGFloat = 20.0
    var fixedBottom: Bool = false
    
    // MARK: Properties: Context
    
    private var isPresenting: Bool = false
    private weak var transitionContext: UIViewControllerContextTransitioning?
    private weak var presentingViewController: UIViewController?
    private weak var presentingView: UIView?
    private weak var presentedViewController: UIViewController?
    private weak var presentedView: UIView?
    private weak var containerView: UIView?
    
    private let blurView = UIView()
    private let keyboardObserver = KeyboardObserver()
    private var keyboardHeight: CGFloat = 0.0
    
    override init() {
        super.init()
        keyboardObserver.delegate = self
    }
    
    deinit {
        keyboardObserver.delegate = nil
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension ModalCardPresentationAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration(whenPresenting: isPresenting)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        if isPresenting {
            presentingViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            presentingView = transitionContext.view(forKey: UITransitionContextViewKey.from) ?? presentingViewController?.view
            presentedViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            presentedView = transitionContext.view(forKey: UITransitionContextViewKey.to) ?? presentedViewController?.view
            containerView = transitionContext.containerView
            
            guard let containerView = containerView,
                let presentedView = presentedView else {
                    print("Missing containerView in ModalCardPresentationAnimator")
                    return
            }
            
            blurView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ModalCardPresentationAnimator.didTapBlurView)))
            blurView.alpha = 0.0
            containerView.addSubview(blurView)
            
            presentedView.isHidden = true
            containerView.addSubview(presentedView)
        }
        
        if isPresenting {
            presentingViewController?.beginAppearanceTransition(false, animated: true)
            performPresentationAnimation()
        } else {
            presentingViewController?.beginAppearanceTransition(true, animated: true)
            performDismissalAnimation()
        }
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        isPresenting = false
        presentingViewController?.endAppearanceTransition()
    }
    
    // MARK: Utility
    
    func transitionDuration(whenPresenting presenting: Bool) -> TimeInterval {
        return isPresenting ? presentationAnimationDuration() : dismissalAnimationDuration()
    }
    
    func completeTransitionAnimation() {
        if let transitionContext = transitionContext {
            if !isPresenting {
                blurView.removeFromSuperview()
                keyboardObserver.deregisterForNotification()
            } else {
                keyboardObserver.registerForNotifications()
            }
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

// MARK: - Presentation Animation

extension ModalCardPresentationAnimator {
    
    // MARK: Duration
    
    func presentationAnimationDuration() -> TimeInterval {
        return 0.5
    }
    
    // MARK: Animation
    
    func performPresentationAnimation() {
        guard let containerView = containerView else {
            completeTransitionAnimation()
            return
        }
        
        blurView.frame = containerView.bounds
        
        presentedView?.transform = .identity
        updatePresentedViewFrame(whenVisible: false)
        presentedView?.isHidden = false
        
        UIView.animate(
            withDuration: presentationAnimationDuration(),
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.0,
            options: .curveEaseInOut,
            animations: {
            self.updatePresentedViewFrame(whenVisible: true)
            self.blurView.alpha = 1.0
        }, completion: { _ in
            self.completeTransitionAnimation()
        })
    }
}

// MARK: - Dismissal Animation

extension ModalCardPresentationAnimator {
    
    // MARK: Duration
    
    func dismissalAnimationDuration() -> TimeInterval {
        return 0.8
    }
    
    // MARK: Animation
    
    func performDismissalAnimation() {
        UIView.animate(
            withDuration: dismissalAnimationDuration(),
            delay: 0.0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.0,
            options: .curveEaseInOut,
            animations: {
            self.updatePresentedViewFrame(whenVisible: false)
            self.blurView.alpha = 0.0
        }, completion: { _ in
            self.completeTransitionAnimation()
        })
    }
}

// MARK: - Interactions

extension ModalCardPresentationAnimator {
    @objc func didTapBlurView() {
        guard tapToDismissEnabled else {
            return
        }
        
        if let presentingViewController = presentingViewController {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension ModalCardPresentationAnimator: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ModalCardPresentationAnimator: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

// MARK: - KeyboardObserverDelegate

extension ModalCardPresentationAnimator: KeyboardObserverDelegate {
    
    func keyboardWillUpdateVisibleHeight(_ height: CGFloat,
                                         withDuration duration: TimeInterval,
                                         animationCurve: UIViewAnimationOptions) {
        keyboardHeight = height
        
        if let containerView = containerView,
            let presentedView = presentedView {
            if containerView.bounds.contains(presentedView.center) {
                
                UIView.animate(withDuration: duration,
                               delay: 0,
                               options: animationCurve,
                               animations: { [weak self] in
                                self?.updatePresentedViewFrame(whenVisible: true)
                    }, completion: nil)
            }
        }
    }
}

// MARK: - Updating Frames

extension ModalCardPresentationAnimator {
    
    private func updatePresentedViewFrame(whenVisible visible: Bool) {
        guard let containerView = containerView,
            let presentedView = presentedView else {
            return
        }
        
        let viewWidth = containerView.bounds.width - 2 * viewInsetSides
        let maxHeight = containerView.bounds.height - viewInsetTop - viewInsetBottom - keyboardHeight
        var viewHeight = maxHeight
        if let modalVC = presentedViewController as? ResizableModalCardViewController {
            viewHeight = min(maxHeight, modalVC.viewSizeThatFits(CGSize(width: viewWidth, height: maxHeight)).height)
        }
                
        let updatedBounds = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        if !updatedBounds.equalTo(presentedView.bounds) {
            presentedView.bounds = updatedBounds
        }
        if let modalVC = presentedViewController as? UpdatableFrames {
            modalVC.updateFrames()
        }
        
        let centerX = containerView.bounds.midX
        var centerY = containerView.bounds.midY + containerView.bounds.height
        if visible {
            if fixedBottom {
                centerY = ceil(containerView.bounds.height - keyboardHeight - viewInsetBottom - viewHeight / 2.0)
            } else {
                centerY = containerView.bounds.midY
                if keyboardHeight > 0 {
                    centerY = min(centerY, containerView.bounds.height - keyboardHeight - viewInsetBottom - ceil(presentedView.bounds.height / 2.0))
                }
            }
        }
        
        presentedView.center = CGPoint(x: centerX, y: centerY)
    }
}

// MARK: - Updating Frame Public API

extension ModalCardPresentationAnimator {
    
    func updatePresentedViewFrame(animated: Bool = true, additionalUpdates: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        if animated {
            UIView.animate(
                withDuration: 0.6,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0,
                options: .beginFromCurrentState,
                animations: { [weak self] in
                    self?.updatePresentedViewFrame(whenVisible: true)
                    additionalUpdates?()
                }, completion: { _ in
                    completion?()
                })
        } else {
            updatePresentedViewFrame(whenVisible: true)
            additionalUpdates?()
            completion?()
        }
    }
}
