//
//  ImageViewerTransitionAnimator.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ImageViewerTransitionAnimator: UIPercentDrivenInteractiveTransition {

    // MARK: Properties: Context
    
    private var isPresenting: Bool = false
    private var presentingViewController: UIViewController?
    private var presentingView: UIView?
    private var imageViewer: ImageViewer?
    private var imageViewerView: UIView?
    private var containerView: UIView?
    
    // MARK: Properties: Internal
    
    private var transitioningImageView = ImageViewerImageView()
    private var maskView = UIView()
    private var panGesture = UIPanGestureRecognizer()
    private var panStart: CGPoint?
    private var animateFromFrame: CGRect?
    
    // MARK:- Initialization
    
    required override init() {
        super.init()
        
        maskView.backgroundColor = UIColor.blackColor()
        maskView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        maskView.alpha = 0.0
        
        transitioningImageView.clipsToBounds = true
        
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(ImageViewerTransitionAnimator.didPan(_:)))
    }
    
    deinit {
        panGesture.delegate = nil
    }
}

// MARK:- UIViewControllerAnimatedTransitioning

extension ImageViewerTransitionAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(whenPresenting presenting: Bool) -> NSTimeInterval {
        return 0.3
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return transitionDuration(whenPresenting: isPresenting)
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            presentingViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
            presentingView = transitionContext.viewForKey(UITransitionContextFromViewKey) ?? presentingViewController?.view
            imageViewer = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? ImageViewer
            imageViewerView = transitionContext.viewForKey(UITransitionContextToViewKey) ?? imageViewer?.view
            containerView = transitionContext.containerView()
        
            
            guard let containerView = containerView else {
                DebugLogError("Missing containerView in ImageViewTransitionAnimator")
                return
            }
            
            guard let imageViewerView = imageViewerView else {
                DebugLogError("Missing imageViewerView in ImageViewTransitionAnimator")
                return
            }
            
            imageViewerView.hidden = true
            if let presentFromView = imageViewer?.presentFromView {
                animateFromFrame = presentFromView.superview?.convertRect(presentFromView.frame, toView: containerView)
            } else {
                animateFromFrame = CGRectZero
            }
            
            maskView.frame = containerView.bounds
            containerView.addSubview(maskView)
            containerView.addSubview(imageViewerView)
            containerView.addSubview(transitioningImageView)
            containerView.addGestureRecognizer(panGesture)
            
        }
    
        if isPresenting {
            performPresentationAnimation(transitionContext)
        } else {
            performDismissalAnimation(transitionContext)
        }
    }
    
    func animationEnded(transitionCompleted: Bool) {
        if !isPresenting {
            self.maskView.removeFromSuperview()
        }
        isPresenting = false
    }
}

// MARK:- Animations: Presentation

extension ImageViewerTransitionAnimator {
    func performPresentationAnimation(transitionContext: UIViewControllerContextTransitioning) {
        if imageViewer?.presentFromView != nil && imageViewer?.presentationImage != nil {
            performZoomPresentationAnimation(transitionContext)
        } else {
            performFadePresentationAnimation(transitionContext)
        }
    }
    
    func performZoomPresentationAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let animateFromFrame = animateFromFrame,
            imageViewer = imageViewer,
            imageViewerView = imageViewerView else {
                DebugLogError("Unable to performZoomPresentationAnimation")
                return
        }
        
        transitioningImageView.frame = animateFromFrame
        transitioningImageView.contentMode = imageViewer.presentationImageContentMode
        transitioningImageView.image = imageViewer.presentationImage
        imageViewer.presentFromView?.hidden = true
        imageViewer.setAccessoryViewsHidden(true, animated: false)
        imageViewerView.hidden = true
        
        UIView.animateWithDuration(0.3, animations: {
            self.presentingView?.transform = CGAffineTransformMakeScale(0.96, 0.96)
            self.maskView.alpha = 1.0
            
            if self.transitioningImageView.contentMode == .ScaleAspectFit {
                let transform = self.aspectFitTransform(forImage: self.transitioningImageView.image, fromFrame: self.transitioningImageView.frame, toFrame: imageViewerView.frame)
                self.transitioningImageView.transform = transform
                
                let center = CGPoint(x: CGRectGetMidX(imageViewerView.bounds), y: CGRectGetMidY(imageViewerView.bounds))
                self.transitioningImageView.center = center
            } else {
                self.transitioningImageView.setFrame(imageViewerView.frame, contentMode: .ScaleAspectFit)
            }
            }) { (completed) in
                imageViewer.setAccessoryViewsHidden(false, animated: true)
                imageViewerView.hidden = false
                self.transitioningImageView.hidden = true
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
    func performFadePresentationAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let imageViewerView = imageViewerView else {
            return
        }
        
        imageViewerView.hidden = false
        imageViewerView.alpha = 0.0
        
        UIView.animateWithDuration(0.3, animations: { 
            self.presentingView?.transform = CGAffineTransformMakeScale(0.96, 0.96)
            self.maskView.alpha = 1.0
            }) { (completed) in
                
                UIView.animateWithDuration(0.3, animations: { 
                    imageViewerView.alpha = 1.0
                    }, completion: { (completed) in
                        self.imageViewer?.setAccessoryViewsHidden(false, animated: true)
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                })
        }
    }
}

// MARK:- Animations: Dismissal

extension ImageViewerTransitionAnimator {
    func performDismissalAnimation(transitionContext: UIViewControllerContextTransitioning) {
        if imageViewer?.presentFromView != nil && imageViewer?.presentationImage != nil {
            if imageViewer?.initialIndex == imageViewer?.currentIndex {
                performDismissToImageViewAnimation(transitionContext)
            } else {
                performDismissOffscreenAnimation(transitionContext)
            }
        } else {
            if CGRectGetMinY(transitioningImageView.frame) != 0 {
                performDismissOffscreenAnimation(transitionContext)
            } else {
                performDismissWithFadeAnimation(transitionContext)
            }
        }
    }
    
    func performDismissToImageViewAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let imageViewer = imageViewer,
            imageViewerView = imageViewerView,
            animateFromFrame = animateFromFrame else {
                DebugLogError("Unable to performDismissToImageViewAnimation")
                return
        }
        
        updateTransitioningImageViewForCurrentImage()
        transitioningImageView.hidden = false
        imageViewerView.hidden = true
        
        let contentMode = imageViewer.presentationImageContentMode
        let mustScaleToFit = contentMode == .ScaleAspectFit

        let duration = mustScaleToFit ? 0.6 : 0.5
        let springDamping: CGFloat = mustScaleToFit ? 0.75 : 0.85
        let initialSpringVelocity: CGFloat = mustScaleToFit ? 0.8 : 0.0
        
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: springDamping, initialSpringVelocity: initialSpringVelocity, options: .BeginFromCurrentState, animations: {
            self.presentingView?.transform = CGAffineTransformIdentity
            self.maskView.alpha = 0.0
            
            if mustScaleToFit {
                let transform = self.aspectFitTransform(forImage: self.transitioningImageView.image, fromFrame: self.transitioningImageView.frame, toFrame: animateFromFrame)
                let center = CGPoint(x: CGRectGetMidX(animateFromFrame), y: CGRectGetMidY(animateFromFrame))
                
                self.transitioningImageView.transform = transform
                self.transitioningImageView.center = center
            } else {
                self.transitioningImageView.setFrame(animateFromFrame, contentMode: contentMode)
            }
        }) { (completed) in
            self.imageViewer?.presentFromView?.hidden = false
            self.transitioningImageView.hidden = true
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
    func performDismissOffscreenAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = containerView else {
            return
        }
        
        updateTransitioningImageViewForCurrentImage()
        transitioningImageView.hidden = false
        imageViewerView?.hidden = true
        imageViewer?.presentFromView?.hidden = false
        
        var center = transitioningImageView.center
        if CGRectGetMinY(transitioningImageView.frame) < 0 {
            // Up
            center.y = -floor(CGRectGetHeight(containerView.bounds) / 2.0)
        } else {
            // Down
            center.y = ceil(1.5 * CGRectGetHeight(containerView.bounds))
        }
        
        let duration = transitionDuration(whenPresenting: false)
        UIView.animateWithDuration(duration, delay: 0, options: .BeginFromCurrentState, animations: { 
            self.presentingView?.transform = CGAffineTransformIdentity
            self.maskView.alpha = 0.0
            self.transitioningImageView.center = center
            }) { (completed) in
                self.imageViewer?.presentFromView?.hidden = false
                self.transitioningImageView.hidden = true
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
    func performDismissWithFadeAnimation(transitionContext: UIViewControllerContextTransitioning) {
        imageViewer?.presentFromView?.hidden = false
        UIView.animateWithDuration(0.2, animations: { 
            self.imageViewerView?.alpha = 0.0
            }) { (completed) in
                UIView.animateWithDuration(0.3, animations: { 
                    self.maskView.alpha = 0.0
                    }, completion: { (completed) in
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                })
        }
    }
}

// MARK:- Animation Utilities

extension ImageViewerTransitionAnimator {
    func updateTransitioningImageViewForCurrentImage() {
        guard let imageViewer = imageViewer else {
            return
        }
        
        let center = transitioningImageView.center
        transitioningImageView.image = imageViewer.currentlyDisplayedImage
        transitioningImageView.transform = CGAffineTransformIdentity
        transitioningImageView.frame = imageViewer.view.bounds
        transitioningImageView.contentMode = .ScaleAspectFit
        transitioningImageView.center = center
    }
    
    func aspectFitTransform(forImage image: UIImage?, fromFrame: CGRect, toFrame: CGRect) -> CGAffineTransform {
        let scale = aspectFitTransformScale(forImage: image, fromFrame: fromFrame, toFrame: toFrame)
        return CGAffineTransformMakeScale(scale, scale)
    }
    
    func aspectFitTransformScale(forImage image: UIImage?, fromFrame: CGRect, toFrame: CGRect) -> CGFloat {
        guard let image = image else {
            return 0.0
        }
        
        if fromFrame.isEmpty || toFrame.isEmpty || image.size.width.isZero || image.size.height.isZero {
            return 0.0
        }
        
        let imageAspect = image.size.width / image.size.height
        let fromAspect = CGRectGetWidth(fromFrame) / CGRectGetHeight(fromFrame)
        let toAspect = CGRectGetWidth(toFrame) / CGRectGetHeight(toFrame)
        
        var scale: CGFloat
        if toAspect < imageAspect {
            let imageSize = (fromAspect < imageAspect ?
                CGRectGetWidth(fromFrame) :
                CGRectGetHeight(fromFrame) * imageAspect)
            
            scale = CGRectGetWidth(toFrame) / imageSize
        } else {
            let imageSize = (fromAspect < imageAspect ?
                CGRectGetWidth(fromFrame) / imageAspect :
                CGRectGetHeight(fromFrame))
            
            scale = CGRectGetHeight(toFrame) / imageSize
        }
        
        return scale
    }
}

// MARK:- UIViewControllerTransitioningDelegate

extension ImageViewerTransitionAnimator: UIViewControllerTransitioningDelegate {
    
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

extension ImageViewerTransitionAnimator: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

// MARK:- Gestures

extension ImageViewerTransitionAnimator {
    func didPan(withGesture: UIPanGestureRecognizer) {
        guard let imageViewer = imageViewer,
            let imageViewerView = imageViewerView else {
                return
        }
        
        let location = panGesture.locationInView(panGesture.view?.superview)
        var viewCenter = CGPoint(x: CGRectGetMidX(imageViewerView.bounds),
                                 y: CGRectGetMidY(imageViewerView.bounds))
        
        if panGesture.state == .Began {
            panStart = location
            imageViewer.presentFromView?.hidden = imageViewer.initialIndex == imageViewer.currentIndex
            imageViewerView.hidden = true
            updateTransitioningImageViewForCurrentImage()
            transitioningImageView.hidden = false
        }
        
        guard let panStart = panStart else {
            DebugLogError("Unable to handle pan gesture because panState is not set.")
            return
        }
        
        let panDistance = location.y - panStart.y
        
        if panGesture.state == .Ended {
            if abs(panDistance) > 70.0 {
                dismissImageViewer()
            } else {
                UIView.animateWithDuration(0.3, animations: { 
                    self.transitioningImageView.center = viewCenter
                    self.maskView.alpha = 1.0
                    }, completion: { (completed) in
                        imageViewerView.hidden = false
                        self.transitioningImageView.hidden = true
                })
            }
        } else {
            viewCenter.y += panDistance
            transitioningImageView.center = viewCenter
            
            maskView.alpha = max(1.0 / 3.0, min(1.0, 1.0 - abs(panDistance / 150.0) / 2.0))
        }
    }
}

// MARK:- Instance Methods

extension ImageViewerTransitionAnimator {
    func dismissImageViewer() {
        guard let presentingViewController = presentingViewController else {
            return
        }
        
        presentingViewController.dismissViewControllerAnimated(true, completion: { [weak presentingViewController] in
            UIView.animateWithDuration(0.3, animations: { 
                presentingViewController?.setNeedsStatusBarAppearanceUpdate()
            })
        })
    }
}
