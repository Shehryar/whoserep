//
//  ImageViewerTransitionAnimator.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ImageViewerTransitionAnimator: NSObject {

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
    
    // MARK: - Initialization
    
    required override init() {
        super.init()
        
        maskView.backgroundColor = UIColor.black
        maskView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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

// MARK: - UIViewControllerAnimatedTransitioning

extension ImageViewerTransitionAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(whenPresenting presenting: Bool) -> TimeInterval {
        return 0.3
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration(whenPresenting: isPresenting)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            presentingViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            presentingView = transitionContext.view(forKey: UITransitionContextViewKey.from) ?? presentingViewController?.view
            imageViewer = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? ImageViewer
            imageViewerView = transitionContext.view(forKey: UITransitionContextViewKey.to) ?? imageViewer?.view
            containerView = transitionContext.containerView
        
            guard let containerView = containerView else {
                DebugLog.e("Missing containerView in ImageViewTransitionAnimator")
                return
            }
            
            guard let imageViewerView = imageViewerView else {
                DebugLog.e("Missing imageViewerView in ImageViewTransitionAnimator")
                return
            }
            
            imageViewerView.isHidden = true
            if let presentFromView = imageViewer?.presentFromView {
                animateFromFrame = presentFromView.superview?.convert(presentFromView.frame, to: containerView)
            } else {
                animateFromFrame = CGRect.zero
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
    
    func animationEnded(_ transitionCompleted: Bool) {
        if !isPresenting {
            self.maskView.removeFromSuperview()
        }
        isPresenting = false
    }
}

// MARK: - Animations: Presentation

extension ImageViewerTransitionAnimator {
    func performPresentationAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        if imageViewer?.presentFromView != nil && imageViewer?.presentationImage != nil {
            performZoomPresentationAnimation(transitionContext)
        } else {
            performFadePresentationAnimation(transitionContext)
        }
    }
    
    func performZoomPresentationAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let animateFromFrame = animateFromFrame,
            let imageViewer = imageViewer,
            let imageViewerView = imageViewerView else {
                DebugLog.e("Unable to performZoomPresentationAnimation")
                return
        }
        
        transitioningImageView.frame = animateFromFrame
        transitioningImageView.contentMode = imageViewer.presentationImageContentMode
        if imageViewer.presentationImageCornerRadius > 0 {
            transitioningImageView.layer.cornerRadius = imageViewer.presentationImageCornerRadius
            transitioningImageView.clipsToBounds = true
        }
        transitioningImageView.image = imageViewer.presentationImage
        imageViewer.presentFromView?.isHidden = true
        imageViewer.setAccessoryViewsHidden(true, animated: false)
        imageViewerView.isHidden = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.presentingView?.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.maskView.alpha = 1.0
            
            if self.transitioningImageView.contentMode == .scaleAspectFit {
                let transform = self.aspectFitTransform(forImage: self.transitioningImageView.image, fromFrame: self.transitioningImageView.frame, toFrame: imageViewerView.frame)
                self.transitioningImageView.transform = transform
                
                let center = CGPoint(x: imageViewerView.bounds.midX, y: imageViewerView.bounds.midY)
                self.transitioningImageView.center = center
            } else {
                self.transitioningImageView.setFrame(imageViewerView.frame, contentMode: .scaleAspectFit)
            }
        }, completion: { _ in
            imageViewer.setAccessoryViewsHidden(false, animated: true)
            imageViewerView.isHidden = false
            self.transitioningImageView.isHidden = true
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            imageViewer.shouldOverrideStatusBar = true
        }) 
    }
    
    func performFadePresentationAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let imageViewerView = imageViewerView else {
            return
        }
        
        imageViewerView.isHidden = false
        imageViewerView.alpha = 0.0
        
        UIView.animate(withDuration: 0.3, animations: { 
            self.presentingView?.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.maskView.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, animations: { 
                imageViewerView.alpha = 1.0
            }, completion: { _ in
                self.imageViewer?.setAccessoryViewsHidden(false, animated: true)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                self.imageViewer?.shouldOverrideStatusBar = true
            })
        }) 
    }
}

// MARK: - Animations: Dismissal

extension ImageViewerTransitionAnimator {
    func performDismissalAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        self.imageViewer?.shouldOverrideStatusBar = false
        
        if imageViewer?.presentFromView != nil && imageViewer?.presentationImage != nil {
            if imageViewer?.initialIndex == imageViewer?.currentIndex {
                performDismissToImageViewAnimation(transitionContext)
            } else {
                performDismissOffscreenAnimation(transitionContext)
            }
        } else {
            if transitioningImageView.frame.minY != 0 {
                performDismissOffscreenAnimation(transitionContext)
            } else {
                performDismissWithFadeAnimation(transitionContext)
            }
        }
    }
    
    func performDismissToImageViewAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let imageViewer = imageViewer,
            let imageViewerView = imageViewerView,
            let animateFromFrame = animateFromFrame else {
                DebugLog.e("Unable to performDismissToImageViewAnimation")
                return
        }
        
        updateTransitioningImageViewForCurrentImage()
        transitioningImageView.isHidden = false
        imageViewerView.isHidden = true
        
        let contentMode = imageViewer.presentationImageContentMode
        let mustScaleToFit = contentMode == .scaleAspectFit

        let duration = mustScaleToFit ? 0.6 : 0.5
        let springDamping: CGFloat = mustScaleToFit ? 0.75 : 0.85
        let initialSpringVelocity: CGFloat = mustScaleToFit ? 0.8 : 0.0
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: springDamping, initialSpringVelocity: initialSpringVelocity, options: .beginFromCurrentState, animations: {
            self.presentingView?.transform = CGAffineTransform.identity
            if let presentingViewController = self.presentingViewController {
                self.presentingView?.frame = transitionContext.finalFrame(for: presentingViewController)
            }
            self.maskView.alpha = 0.0
            if imageViewer.presentationImageCornerRadius != 0 {
                self.transitioningImageView.layer.cornerRadius = imageViewer.presentationImageCornerRadius
            }
            
            if mustScaleToFit {
                let transform = self.aspectFitTransform(forImage: self.transitioningImageView.image, fromFrame: self.transitioningImageView.frame, toFrame: animateFromFrame)
                let center = CGPoint(x: animateFromFrame.midX, y: animateFromFrame.midY)
                
                self.transitioningImageView.transform = transform
                self.transitioningImageView.center = center
            } else {
                self.transitioningImageView.setFrame(animateFromFrame, contentMode: contentMode)
            }
        }, completion: { _ in
            self.imageViewer?.presentFromView?.isHidden = false
            self.transitioningImageView.isHidden = true
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    func performDismissOffscreenAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = containerView else {
            return
        }
        
        updateTransitioningImageViewForCurrentImage()
        transitioningImageView.isHidden = false
        imageViewerView?.isHidden = true
        imageViewer?.presentFromView?.isHidden = false
        
        var center = transitioningImageView.center
        if transitioningImageView.frame.minY < 0 {
            // Up
            center.y = -floor(containerView.bounds.height / 2.0)
        } else {
            // Down
            center.y = ceil(1.5 * containerView.bounds.height)
        }
        
        let duration = transitionDuration(whenPresenting: false)
        UIView.animate(withDuration: duration, delay: 0, options: .beginFromCurrentState, animations: { 
            self.presentingView?.transform = CGAffineTransform.identity
            if let presentingViewController = self.presentingViewController {
                self.presentingView?.frame = transitionContext.finalFrame(for: presentingViewController)
            }
            self.maskView.alpha = 0.0
            self.transitioningImageView.center = center
        }, completion: { _ in
            self.imageViewer?.presentFromView?.isHidden = false
            self.transitioningImageView.isHidden = true
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    func performDismissWithFadeAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        imageViewer?.presentFromView?.isHidden = false
        UIView.animate(withDuration: 0.2, animations: { 
            self.imageViewerView?.alpha = 0.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, animations: { 
                self.maskView.alpha = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }) 
    }
}

// MARK: - Animation Utilities

extension ImageViewerTransitionAnimator {
    func updateTransitioningImageViewForCurrentImage() {
        guard let imageViewer = imageViewer else {
            return
        }
        
        let center = transitioningImageView.center
        transitioningImageView.image = imageViewer.currentlyDisplayedImage
        transitioningImageView.transform = CGAffineTransform.identity
        transitioningImageView.frame = imageViewer.view.bounds
        transitioningImageView.contentMode = .scaleAspectFit
        transitioningImageView.center = center
    }
    
    func aspectFitTransform(forImage image: UIImage?, fromFrame: CGRect, toFrame: CGRect) -> CGAffineTransform {
        let scale = aspectFitTransformScale(forImage: image, fromFrame: fromFrame, toFrame: toFrame)
        return CGAffineTransform(scaleX: scale, y: scale)
    }
    
    func aspectFitTransformScale(forImage image: UIImage?, fromFrame: CGRect, toFrame: CGRect) -> CGFloat {
        guard let image = image else {
            return 0.0
        }
        
        if fromFrame.isEmpty || toFrame.isEmpty || image.size.width.isZero || image.size.height.isZero {
            return 0.0
        }
        
        let imageAspect = image.size.width / image.size.height
        let fromAspect = fromFrame.width / fromFrame.height
        let toAspect = toFrame.width / toFrame.height
        
        var scale: CGFloat
        if toAspect < imageAspect {
            let imageSize = (fromAspect < imageAspect ?
                fromFrame.width :
                fromFrame.height * imageAspect)
            
            scale = toFrame.width / imageSize
        } else {
            let imageSize = (fromAspect < imageAspect ?
                fromFrame.width / imageAspect :
                fromFrame.height)
            
            scale = toFrame.height / imageSize
        }
        
        return scale
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension ImageViewerTransitionAnimator: UIViewControllerTransitioningDelegate {
    
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

extension ImageViewerTransitionAnimator: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

// MARK: - Gestures

extension ImageViewerTransitionAnimator {
    @objc func didPan(_ withGesture: UIPanGestureRecognizer) {
        guard let imageViewer = imageViewer,
            let imageViewerView = imageViewerView else {
                return
        }
        
        let location = panGesture.location(in: panGesture.view?.superview)
        var viewCenter = CGPoint(x: imageViewerView.bounds.midX,
                                 y: imageViewerView.bounds.midY)
        
        if panGesture.state == .began {
            panStart = location
            imageViewer.shouldOverrideStatusBar = false
            imageViewer.presentFromView?.isHidden = imageViewer.initialIndex == imageViewer.currentIndex
            imageViewerView.isHidden = true
            updateTransitioningImageViewForCurrentImage()
            transitioningImageView.isHidden = false

        }
        
        guard let panStart = panStart else {
            DebugLog.e("Unable to handle pan gesture because panState is not set.")
            return
        }
        
        let panDistance = location.y - panStart.y
        
        if panGesture.state == .ended {
            if abs(panDistance) > 70.0 {
                dismissImageViewer()
            } else {
                UIView.animate(withDuration: 0.3, animations: { 
                    self.transitioningImageView.center = viewCenter
                    self.maskView.alpha = 1.0
                }, completion: { _ in
                    imageViewerView.isHidden = false
                    self.transitioningImageView.isHidden = true
                    imageViewer.shouldOverrideStatusBar = true
                })
            }
        } else {
            viewCenter.y += panDistance
            transitioningImageView.center = viewCenter
            
            maskView.alpha = max(1.0 / 3.0, min(1.0, 1.0 - abs(panDistance / 150.0) / 2.0))
        }
    }
}

// MARK: - Instance Methods

extension ImageViewerTransitionAnimator {
    func dismissImageViewer() {
        guard let presentingViewController = presentingViewController else {
            return
        }
        
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}
