//
//  ButtonPresentationAnimator.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/8/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ButtonPresentationAnimator: NSObject {
    
    var buttonView: UIView
    
    // MARK: Properties: Context
    
    fileprivate var isPresenting: Bool = false
    fileprivate var presentingViewController: UIViewController?
    fileprivate var presentingView: UIView?
    fileprivate var presentedViewController: UIViewController?
    fileprivate var presentedView: UIView?
    fileprivate var containerView: UIView?
    fileprivate var transitionContext: UIViewControllerContextTransitioning?
    
    // MARK: Properties: Internal

    fileprivate var circleMaskLayer = CAShapeLayer()
    fileprivate var expansionPoint: CGPoint?
    
    fileprivate let ANIMATION_KEY_EXPAND = "expand_path"
    fileprivate let ANIMATION_KEY_COLLAPSE = "collapse_path"
    
    // MARK:- Initialization
    
    required init(withButtonView buttonView: UIView) {
        self.buttonView = buttonView
        super.init()
    }
}

// MARK:- UIViewControllerAnimatedTransitioning

extension ButtonPresentationAnimator: UIViewControllerAnimatedTransitioning {
    
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
                    DebugLogError("Missing containerView in ButtonPresentationAnimator")
                    return
            }

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
            presentedView?.layer.mask = nil
            if isPresenting {
                containerView?.backgroundColor = UIColor.black
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

// MARK:- Presentation Animation

extension ButtonPresentationAnimator {
    
    func performPresentationAnimation() {
        guard let containerView = containerView else {
            completeTransitionAnimation()
            return
        }
        
        collapseButton { (collapsedToPoint) in
            self.expansionPoint = collapsedToPoint ?? CGPoint(x: containerView.bounds.midX, y: containerView.bounds.midY)
            self.expandView(fromPoint: self.expansionPoint!, completion: {
                self.completeTransitionAnimation()
            })
        }
    }
    
    // MARK: Duration Helpers
    
    func presentationAnimationDuration() -> TimeInterval {
        return buttonCollapseDuration() + viewExpansionDuration()
    }
    
    func buttonCollapseDuration() -> TimeInterval {
        return 0.3
    }
    
    func viewExpansionDuration() -> TimeInterval {
        return 0.3
    }
    
    // MARK: Animations
    
    func collapseButton(_ completion: ((_ collapsedToPoint: CGPoint?) -> Void)?) {
        let buttonCenter = self.buttonView.superview?.convert(self.buttonView.center, to: self.containerView)
        UIView.animate(withDuration: buttonCollapseDuration(), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            self.buttonView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }) { (completed) in
                self.buttonView.isHidden = true
                completion?(buttonCenter)
        }
    }
    
    func expandView(fromPoint expansionPoint: CGPoint, completion: (() -> Void)?) {
        let duration = viewExpansionDuration()
        
        let expandFromRect = CGRect(origin: expansionPoint, size: CGSize(width: 0.1, height: 0.1))
        let expandToRect = bigCircleRect(withCenter: expansionPoint)
        let expandFromCirclePath = UIBezierPath(ovalIn: expandFromRect).cgPath
        let expandToCirclePath = UIBezierPath(ovalIn: expandToRect).cgPath
        
        // Circle Mask
        
        circleMaskLayer.path = expandToCirclePath
        presentedView?.layer.mask = circleMaskLayer
        presentedView?.isHidden = false
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = expandFromCirclePath
        animation.toValue = expandToCirclePath
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.autoreverses = false
        animation.isRemovedOnCompletion = false
        circleMaskLayer.add(animation, forKey: ANIMATION_KEY_EXPAND)
        
        // Transforms + Translations
        
        var translationX: CGFloat = 0.0, translationY: CGFloat = 0.0
        if let containerView = containerView {
            translationX = containerView.bounds.midX - expandFromRect.midX
            translationY = containerView.bounds.midY - expandFromRect.midY
        }
        
        // Presented View Transform
        
        var presentedViewTransform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        presentedViewTransform = presentedViewTransform.translatedBy(x: 0.05 * -translationX, y: 0.05 * -translationY)
        presentedView?.transform = presentedViewTransform
        
        // Presenting View Transfrom
        
        var presentingViewTransform: CGAffineTransform?
        
        var width: CGFloat = 0, height: CGFloat = 0
        if let presentingView = presentingView {
            width = presentingView.bounds.width
            height = presentingView.bounds.height
        }
        if width > 0 && height > 0 {
            let transformConstantFactor: CGFloat = 0.25
            // Scale
            let biggerWidth = width + expandToRect.width - expandFromRect.width
            let biggerHeight = height + expandToRect.height - expandFromRect.height
            let scale = max(biggerWidth / width, biggerHeight / height) * 1.5 * transformConstantFactor
            presentingViewTransform = CGAffineTransform(scaleX: scale, y: scale)
            // Translation
            let presentingTranslationX = transformConstantFactor * translationX
            let presentingTranslationY = transformConstantFactor * translationY
            presentingViewTransform = presentingViewTransform!.translatedBy(x: presentingTranslationX, y: presentingTranslationY)
        }
        
        // Animating Transforms
        
        UIView.animate(withDuration: duration, animations: { 
            self.presentedView?.transform = CGAffineTransform.identity
            if let presentingViewTransform = presentingViewTransform {
                self.presentingView?.transform = presentingViewTransform
            }
            }, completion: { (completed) in
                completion?()
        }) 
    }
}

// MARK:- Dismissal Animation

extension ButtonPresentationAnimator {
    
    func performDismissalAnimation() {
        guard let containerView = containerView else {
            completeTransitionAnimation()
            return
        }
        
        containerView.backgroundColor = UIColor.clear
        
        collapseView(toPoint: expansionPoint ?? CGPoint(x: containerView.bounds.midX, y: containerView.bounds.midY)) { 
            self.expandButton({
                self.completeTransitionAnimation()
            })
        }
    }
    
    // MARK: Duration Helpers
    
    func dismissalAnimationDuration() -> TimeInterval {
        return collapseViewDuration() + expandButtonDuration()
    }
    
    func collapseViewDuration() -> TimeInterval {
        return 0.25
    }
    
    func expandButtonDuration() -> TimeInterval {
        return 0.5
    }
    
    // MARK: Animations
    
    func collapseView(toPoint collapseToPoint: CGPoint, completion: (() -> Void)?) {
        let duration = collapseViewDuration()
        
        let collapseFromCirclePath = bigCirclePath(withCenter: collapseToPoint)
        let collapseToRect = CGRect(origin: collapseToPoint, size: CGSize(width: 0.01, height: 0.01))
        let collapseToCirclePath = UIBezierPath(ovalIn: collapseToRect).cgPath
        
        circleMaskLayer.path = collapseToCirclePath
        presentedView?.layer.mask = circleMaskLayer
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = collapseFromCirclePath
        animation.toValue = collapseToCirclePath
        animation.duration = duration
        animation.autoreverses = false
        animation.isRemovedOnCompletion = false
        circleMaskLayer.add(animation, forKey: ANIMATION_KEY_COLLAPSE)
        
        UIView.animate(withDuration: duration, animations: { 
            self.presentingView?.transform = CGAffineTransform.identity
            if let presentingViewController = self.presentingViewController,
                let presentingViewFrame = self.transitionContext?.finalFrame(for: presentingViewController) {
                self.presentingView?.frame = presentingViewFrame
            }
            }, completion: { (completed) in
                completion?()
        }) 
    }
    
    func expandButton(_ completion: (() -> Void)?) {
        buttonView.isHidden = false
        UIView.animate(withDuration: expandButtonDuration(), delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.buttonView.transform = CGAffineTransform.identity
        }) { (completed) in
            completion?()
        }
    }
}

// MARK:- Animation Utilities

extension ButtonPresentationAnimator {
    
    func bigCircleRect(withCenter centerPoint: CGPoint) -> CGRect {
        let containerRect = (containerView != nil) ? containerView!.bounds : UIScreen.main.bounds
        
        let distanceX = max(centerPoint.x, containerRect.width - centerPoint.x)
        let distanceY = max(centerPoint.y, containerRect.height - centerPoint.y)
        let radius = sqrt(distanceX * distanceX + distanceY * distanceY)
    
        return CGRect(x: centerPoint.x - radius, y: centerPoint.y - radius, width: 2 * radius, height: 2 * radius)
    }
    
    func bigCirclePath(withCenter centerPoint: CGPoint) -> CGPath {
        return UIBezierPath(ovalIn: bigCircleRect(withCenter: centerPoint)).cgPath
    }
}

// MARK:- UIViewControllerTransitioningDelegate

extension ButtonPresentationAnimator: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
}

// MARK:- UIGestureRecognizerDelegate

extension ButtonPresentationAnimator: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
