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
                // CompleteTransition called by animation
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
        animation.delegate = self
        circleMaskLayer.addAnimation(animation, forKey: "path")
        
        guard let presentingView = presentingView,
            let containerView = containerView else {
                // Nothing else to do here
                return
        }
        
        var transform: CGAffineTransform?
        
        let width = CGRectGetWidth(presentingView.bounds)
        let height = CGRectGetHeight(presentingView.bounds)
        if width > 0 && height > 0 {
            let transformConstantFactor: CGFloat = 0.25
            // Scale
            let biggerWidth = width + CGRectGetWidth(expandToRect) - CGRectGetWidth(expandFromRect)
            let biggerHeight = height + CGRectGetHeight(expandToRect) - CGRectGetHeight(expandFromRect)
            let scale = max(biggerWidth / width, biggerHeight / height) * 1.5 * transformConstantFactor
            transform = CGAffineTransformMakeScale(scale, scale)
            // Translation
            let translationX = transformConstantFactor * (CGRectGetMidX(containerView.bounds) - CGRectGetMidX(expandFromRect))
            let translationY = transformConstantFactor * (CGRectGetMidY(containerView.bounds) - CGRectGetMidY(expandFromRect))
            transform = CGAffineTransformTranslate(transform!, translationX, translationY)
        }
       
        if let transform = transform {
            UIView.animateWithDuration(duration, delay: 0, options: .BeginFromCurrentState, animations: {
                self.presentingView?.transform = transform
                }, completion: nil)
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
        return 0.3
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
        circleMaskLayer.addAnimation(animation, forKey: "path")
        
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

// MARK:- CAAnimationDelegate

extension ButtonPresentationAnimator {
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        completeTransitionAnimation()
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
