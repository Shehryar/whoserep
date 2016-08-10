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
    
    private var isPresenting: Bool = false
    private var presentingViewController: UIViewController?
    private var presentingView: UIView?
    private var presentedViewController: UIViewController?
    private var presentedView: UIView?
    private var containerView: UIView?
    private var transitionContext: UIViewControllerContextTransitioning?
    
    // MARK: Properties: Internal

    private var circleMaskLayer = CAShapeLayer()
    private var expansionPoint: CGPoint?
    
    private let ANIMATION_KEY_EXPAND = "expand_path"
    private let ANIMATION_KEY_COLLAPSE = "collapse_path"
    
    // MARK:- Initialization
    
    required init(withButtonView buttonView: UIView) {
        self.buttonView = buttonView
        super.init()
    }
}

// MARK:- UIViewControllerAnimatedTransitioning

extension ButtonPresentationAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return transitionDuration(whenPresenting: isPresenting)
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        if isPresenting {
            presentingViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
            presentingView = transitionContext.viewForKey(UITransitionContextFromViewKey) ?? presentingViewController?.view
            presentedViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
            presentedView = transitionContext.viewForKey(UITransitionContextToViewKey) ?? presentedViewController?.view
            containerView = transitionContext.containerView()
            
            guard let containerView = containerView,
                presentedView = presentedView else {
                    DebugLogError("Missing containerView in ButtonPresentationAnimator")
                    return
            }

            presentedView.hidden = true
            containerView.addSubview(presentedView)
        }
        
        if isPresenting {
            performPresentationAnimation()
        } else {
            performDismissalAnimation()
        }
    }
    
    func animationEnded(transitionCompleted: Bool) {
        isPresenting = false
    }
    
    // MARK: Utility
    
    func transitionDuration(whenPresenting presenting: Bool) -> NSTimeInterval {
        return isPresenting ? presentationAnimationDuration() : dismissalAnimationDuration()
    }
    
    func completeTransitionAnimation() {
        if let transitionContext = transitionContext {
            presentedView?.layer.mask = nil
            if isPresenting {
                containerView?.backgroundColor = UIColor.blackColor()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
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
            self.expansionPoint = collapsedToPoint ?? CGPoint(x: CGRectGetMidX(containerView.bounds), y: CGRectGetMidY(containerView.bounds))
            self.expandView(fromPoint: self.expansionPoint!, completion: {
                self.completeTransitionAnimation()
            })
        }
    }
    
    // MARK: Duration Helpers
    
    func presentationAnimationDuration() -> NSTimeInterval {
        return buttonCollapseDuration() + viewExpansionDuration()
    }
    
    func buttonCollapseDuration() -> NSTimeInterval {
        return 0.3
    }
    
    func viewExpansionDuration() -> NSTimeInterval {
        return 0.3
    }
    
    // MARK: Animations
    
    func collapseButton(completion: ((collapsedToPoint: CGPoint?) -> Void)?) {
        let buttonCenter = self.buttonView.superview?.convertPoint(self.buttonView.center, toView: self.containerView)
        UIView.animateWithDuration(buttonCollapseDuration(), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .CurveEaseIn, animations: {
            self.buttonView.transform = CGAffineTransformMakeScale(0.001, 0.001)
            }) { (completed) in
                self.buttonView.hidden = true
                completion?(collapsedToPoint: buttonCenter)
        }
    }
    
    func expandView(fromPoint expansionPoint: CGPoint, completion: (() -> Void)?) {
        let duration = viewExpansionDuration()
        
        let expandFromRect = CGRect(origin: expansionPoint, size: CGSize(width: 0.1, height: 0.1))
        let expandToRect = bigCircleRect(withCenter: expansionPoint)
        let expandFromCirclePath = UIBezierPath(ovalInRect: expandFromRect).CGPath
        let expandToCirclePath = UIBezierPath(ovalInRect: expandToRect).CGPath
        
        // Circle Mask
        
        circleMaskLayer.path = expandToCirclePath
        presentedView?.layer.mask = circleMaskLayer
        presentedView?.hidden = false
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = expandFromCirclePath
        animation.toValue = expandToCirclePath
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.autoreverses = false
        animation.removedOnCompletion = false
        circleMaskLayer.addAnimation(animation, forKey: ANIMATION_KEY_EXPAND)
        
        // Transforms + Translations
        
        var translationX: CGFloat = 0.0, translationY: CGFloat = 0.0
        if let containerView = containerView {
            translationX = CGRectGetMidX(containerView.bounds) - CGRectGetMidX(expandFromRect)
            translationY = CGRectGetMidY(containerView.bounds) - CGRectGetMidY(expandFromRect)
        }
        
        // Presented View Transform
        
        var presentedViewTransform = CGAffineTransformMakeScale(1.05, 1.05)
        presentedViewTransform = CGAffineTransformTranslate(presentedViewTransform, 0.05 * -translationX, 0.05 * -translationY)
        presentedView?.transform = presentedViewTransform
        
        // Presenting View Transfrom
        
        var presentingViewTransform: CGAffineTransform?
        
        var width: CGFloat = 0, height: CGFloat = 0
        if let presentingView = presentingView {
            width = CGRectGetWidth(presentingView.bounds)
            height = CGRectGetHeight(presentingView.bounds)
        }
        if width > 0 && height > 0 {
            let transformConstantFactor: CGFloat = 0.25
            // Scale
            let biggerWidth = width + CGRectGetWidth(expandToRect) - CGRectGetWidth(expandFromRect)
            let biggerHeight = height + CGRectGetHeight(expandToRect) - CGRectGetHeight(expandFromRect)
            let scale = max(biggerWidth / width, biggerHeight / height) * 1.5 * transformConstantFactor
            presentingViewTransform = CGAffineTransformMakeScale(scale, scale)
            // Translation
            let presentingTranslationX = transformConstantFactor * translationX
            let presentingTranslationY = transformConstantFactor * translationY
            presentingViewTransform = CGAffineTransformTranslate(presentingViewTransform!, presentingTranslationX, presentingTranslationY)
        }
        
        // Animating Transforms
        
        UIView.animateWithDuration(duration, animations: { 
            self.presentedView?.transform = CGAffineTransformIdentity
            if let presentingViewTransform = presentingViewTransform {
                self.presentingView?.transform = presentingViewTransform
            }
            }) { (completed) in
                completion?()
        }
    }
}

// MARK:- Dismissal Animation

extension ButtonPresentationAnimator {
    
    func performDismissalAnimation() {
        guard let containerView = containerView else {
            completeTransitionAnimation()
            return
        }
        
        containerView.backgroundColor = UIColor.clearColor()
        
        collapseView(toPoint: expansionPoint ?? CGPoint(x: CGRectGetMidX(containerView.bounds), y: CGRectGetMidY(containerView.bounds))) { 
            self.expandButton({
                self.completeTransitionAnimation()
            })
        }
    }
    
    // MARK: Duration Helpers
    
    func dismissalAnimationDuration() -> NSTimeInterval {
        return collapseViewDuration() + expandButtonDuration()
    }
    
    func collapseViewDuration() -> NSTimeInterval {
        return 0.25
    }
    
    func expandButtonDuration() -> NSTimeInterval {
        return 0.5
    }
    
    // MARK: Animations
    
    func collapseView(toPoint collapseToPoint: CGPoint, completion: (() -> Void)?) {
        let duration = collapseViewDuration()
        
        let collapseFromCirclePath = bigCirclePath(withCenter: collapseToPoint)
        let collapseToRect = CGRect(origin: collapseToPoint, size: CGSize(width: 0.01, height: 0.01))
        let collapseToCirclePath = UIBezierPath(ovalInRect: collapseToRect).CGPath
        
        circleMaskLayer.path = collapseToCirclePath
        presentedView?.layer.mask = circleMaskLayer
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = collapseFromCirclePath
        animation.toValue = collapseToCirclePath
        animation.duration = duration
        animation.autoreverses = false
        animation.removedOnCompletion = false
        circleMaskLayer.addAnimation(animation, forKey: ANIMATION_KEY_COLLAPSE)
        
        UIView.animateWithDuration(duration, animations: { 
            self.presentingView?.transform = CGAffineTransformIdentity
            if let presentingViewController = self.presentingViewController,
                let presentingViewFrame = self.transitionContext?.finalFrameForViewController(presentingViewController) {
                self.presentingView?.frame = presentingViewFrame
            }
            }) { (completed) in
                completion?()
        }
    }
    
    func expandButton(completion: (() -> Void)?) {
        buttonView.hidden = false
        UIView.animateWithDuration(expandButtonDuration(), delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .CurveEaseOut, animations: {
            self.buttonView.transform = CGAffineTransformIdentity
        }) { (completed) in
            completion?()
        }
    }
}

// MARK:- Animation Utilities

extension ButtonPresentationAnimator {
    
    func bigCircleRect(withCenter centerPoint: CGPoint) -> CGRect {
        let containerRect = (containerView != nil) ? containerView!.bounds : UIScreen.mainScreen().bounds
        
        let distanceX = max(centerPoint.x, CGRectGetWidth(containerRect) - centerPoint.x)
        let distanceY = max(centerPoint.y, CGRectGetHeight(containerRect) - centerPoint.y)
        let radius = sqrt(distanceX * distanceX + distanceY * distanceY)
    
        return CGRect(x: centerPoint.x - radius, y: centerPoint.y - radius, width: 2 * radius, height: 2 * radius)
    }
    
    func bigCirclePath(withCenter centerPoint: CGPoint) -> CGPath {
        return UIBezierPath(ovalInRect: bigCircleRect(withCenter: centerPoint)).CGPath
    }
}

// MARK:- UIViewControllerTransitioningDelegate

extension ButtonPresentationAnimator: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
}

// MARK:- UIGestureRecognizerDelegate

extension ButtonPresentationAnimator: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
