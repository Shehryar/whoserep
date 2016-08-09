//
//  ButtonPresentationAnimator.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/8/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ButtonPresentationAnimator: NSObject {
    
    var presentFromButtonView: UIView?
    
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
    
    // MARK:- Initialization
    
    required override init() {
        super.init()
    }
}

// MARK:- UIViewControllerAnimatedTransitioning

extension ButtonPresentationAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(whenPresenting presenting: Bool) -> NSTimeInterval {
        return 10//isPresenting ? 0.6 : 1.0
    }
    
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
}

// MARK:- Animations

extension ButtonPresentationAnimator {
    
    func performPresentationAnimation() {
        guard let containerView = containerView else {
            completeTransitionAnimation()
            return
        }
        
        let duration = transitionDuration(whenPresenting: true)
        
        let smallRect = smallCircleRect()
        let bigRect = bigCircleRect()
        var transform: CGAffineTransform?
        if let presentingView = presentingView {
            let width = CGRectGetWidth(presentingView.bounds)
            let biggerWidth = width + CGRectGetWidth(bigRect) - CGRectGetWidth(smallRect)
            let height = CGRectGetHeight(presentingView.bounds)
            let biggerHeight = height + CGRectGetHeight(bigRect) - CGRectGetHeight(smallRect)
            if width > 0 && height > 0 {
                transform = CGAffineTransformMakeScale(biggerWidth / width, biggerHeight / height)
                
//                presentingView.layer.anchorPoint = CGPoint(x: CGRectGetMidX(smallRect) / CGRectGetWidth(presentingView.bounds), y: CGRectGetMidY(smallRect) / CGRectGetHeight(presentingView.bounds))
            }
        }
        
        let initialDuration = duration * 0.4
        UIView.animateWithDuration(initialDuration, animations: {
            self.presentFromButtonView?.transform = CGAffineTransformMakeScale(0.001, 0.001)
        }) { (completed) in
            self.presentFromButtonView?.hidden = true
            
            let circlePathBegin = self.smallCirclePath()
            let circlePathEnd = self.bigCirclePath()
            self.circleMaskLayer.path = circlePathEnd
            self.presentedView?.layer.mask = self.circleMaskLayer
            self.presentedView?.hidden = false
            
//            UIView.animateWithDuration(duration - initialDuration - 0.01, animations: {
//                if let transform = transform {
//                    self.presentingView?.transform = transform
//                }
//            })
            
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = circlePathBegin
            animation.toValue = circlePathEnd
            animation.duration = duration - initialDuration
            animation.autoreverses = false
            animation.removedOnCompletion = false
            animation.delegate = self
            self.circleMaskLayer.addAnimation(animation, forKey: "path")
            
          
        }
    
    }
    
    func performDismissalAnimation() {
        guard let containerView = containerView else {
            completeTransitionAnimation()
            return
        }
        
        let duration = transitionDuration(whenPresenting: true)
        
        let circlePathBegin = bigCirclePath()
        let circlePathEnd = smallCirclePath()
        
        circleMaskLayer.path = circlePathEnd
        presentedView?.layer.mask = circleMaskLayer
        
        
        let initialDuration = duration * 0.3
        
//        UIView.animateWithDuration(initialDuration) {
//            self.presentingView?.transform = CGAffineTransformIdentity
//        }

        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = circlePathBegin
        animation.toValue = circlePathEnd
        animation.duration = initialDuration
        animation.autoreverses = false
        animation.removedOnCompletion = false
        circleMaskLayer.addAnimation(animation, forKey: "path")
        
        
        
        
        UIView.animateWithDuration(duration - initialDuration, delay: initialDuration, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .BeginFromCurrentState, animations: {
            self.presentFromButtonView?.hidden = false
            self.presentFromButtonView?.transform = CGAffineTransformIdentity
            }) { (completed) in
                self.completeTransitionAnimation()
        }
    }
    
    func completeTransitionAnimation() {
        if let transitionContext = transitionContext {
            presentedView?.layer.mask = nil
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}

// MARK:- CAAnimationDelegate

extension ButtonPresentationAnimator {
    override func animationDidStart(anim: CAAnimation) {
        
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        completeTransitionAnimation()
    }
}

// MARK:- Animation Utilities

extension ButtonPresentationAnimator {
    
    func smallCircleRect() -> CGRect {
        if let presentFromButtonView = presentFromButtonView,
            let buttonFrame = presentFromButtonView.superview?.convertRect(presentFromButtonView.frame, toView: containerView) {
            return CGRect(x: CGRectGetMidX(buttonFrame), y: CGRectGetMidY(buttonFrame), width: 0.01, height: 0.01)
//            return buttonFrame
        }
        if let containerView = containerView {
            return CGRect(x: CGRectGetMidX(containerView.bounds), y: CGRectGetMidY(containerView.bounds), width: 0.01, height: 0.01)
        }
        return CGRectZero
    }
    
    func smallCirclePath() -> CGPath {
        return UIBezierPath(ovalInRect: smallCircleRect()).CGPath
    }
    
    func bigCircleRect() -> CGRect {
        let smallRect = smallCircleRect()
        
        let containerRect = (containerView != nil) ? containerView!.bounds : UIScreen.mainScreen().bounds
        // This calculates the max... could obviously optimize this
        let negativeInset = -sqrt(CGRectGetWidth(containerRect) * CGRectGetWidth(containerRect) + CGRectGetHeight(containerRect) * CGRectGetHeight(containerRect))
    
        return CGRectInset(smallRect, negativeInset, negativeInset)
    }
    
    func bigCirclePath() -> CGPath {
        return UIBezierPath(ovalInRect: bigCircleRect()).CGPath
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
