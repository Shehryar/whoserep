//
//  ModalCardViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol ModalCardContentView {
    func updateFrames()
}

/**
 Subclassable base class for displaying ocntent as an animated modal view controller.
 
 This class will help handle things like an error bar, bottom controls, and a loading view.
 
 -Usage:
 At a minimum, subclasses should set contentView, ideally with a UIView that implements the ModalCardContentView protocol
 */
class ModalCardViewController: UIViewController {
    
    var contentView: UIView? {
        didSet {
            // Remove the previous view, if necessary
            if let previousView = oldValue {
                previousView.removeFromSuperview()
            }
            
            // Add the new view to the scroll view
            if let contentView = contentView {
                contentScrollView.addSubview(contentView)
                if isViewLoaded {
                    view.setNeedsLayout()
                }
            }
        }
    }
    
    var shouldCoverScreenWhenBackgrounded = false
    
    fileprivate(set) var isLoading: Bool = false
    fileprivate(set) var isShowingSuccessView: Bool = false
    
    let errorView = ModalCardErrorView()
    let contentScrollView = UIScrollView()
    let controlsView = CancelConfirmControlsView()
    let loadingView = ModalCardLoadingView()
    let successView = SuccessCheckmarkView()
    let presentationAnimator = ModalCardPresentationAnimator()
    
    // MARK:- Initialization
    
    func commonInit() {
        modalPresentationStyle = .custom
        transitioningDelegate = presentationAnimator
        
        // Notifications
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(ModalCardViewController.hideContentWhileBackgrounded),
                name: Notification.Name.UIApplicationDidEnterBackground,
                object: nil)
        
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(ModalCardViewController.hideContentWhileBackgrounded),
                name: Notification.Name.UIApplicationWillResignActive,
                object: nil)
        
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(ModalCardViewController.showContent),
                name: Notification.Name.UIApplicationDidBecomeActive,
                object: nil)
        
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(ModalCardViewController.showContent),
                name: Notification.Name.UIApplicationWillEnterForeground,
                object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(contentScrollView)
        view.addSubview(errorView)
        view.addSubview(controlsView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateFrames()
    }
}

// MARK:- ResizableModalCardViewController

extension ModalCardViewController: ResizableModalCardViewController {
    
    // MARK: Private Helpers
    
    private func getErrorViewHeight(for size: CGSize) -> CGFloat {
        if errorView.text == nil || errorView.text!.isEmpty {
            return 0.0
        }
        return ceil(errorView.sizeThatFits(CGSize(width: size.width, height: 0)).height)
    }
    
    private func getControlsViewHeight(for size: CGSize) -> CGFloat {
        return ceil(controlsView.sizeThatFits(CGSize(width: size.width, height: 0)).height)
    }
    
    private func getContentViewHeight(for size: CGSize) -> CGFloat {
        var contentHeight: CGFloat = 0.0
        if isShowingSuccessView {
            contentHeight = ceil(successView.sizeThatFits(CGSize(width: size.width, height: size.height)).height)
        } else if let contentView = contentView {
            contentHeight = ceil(contentView.sizeThatFits(CGSize(width: size.width, height: size.height)).height)
        }
        if size.height > 0 && contentHeight > size.height {
            contentHeight = size.height
        }
        return contentHeight
    }
    
    // MARK: Public API
    
    func updateFrames() {
        let maxHeight = view.bounds.height
        let errorHeight = getErrorViewHeight(for: view.bounds.size)
        let controlsHeight = getControlsViewHeight(for: view.bounds.size)
        let maxContentHeight = maxHeight - controlsHeight - errorHeight
        let contentHeight = getContentViewHeight(for: CGSize(width: view.bounds.width, height: maxContentHeight))
        
        // Error View
        errorView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: errorHeight)
        
        // Controls View
        let controlsTop = view.bounds.height - controlsHeight
        controlsView.frame = CGRect(x: 0, y: controlsTop, width: view.bounds.width, height: controlsHeight)
        
        // Content View
        let contentViewFrame = CGRect(x: 0, y: errorHeight, width: view.bounds.width, height: contentHeight)
        contentView?.frame = contentViewFrame
        if let contentView = contentView as? ModalCardContentView {
            contentView.updateFrames()
        }
        
        // Success View
        if successView.transform.isIdentity {
            successView.frame = contentViewFrame
        }
        
        // Loading View
        loadingView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: errorHeight + contentHeight)
    }
    
    func viewSizeThatFits(_ size: CGSize) -> CGSize {
        let maxHeight: CGFloat = size.height > 0 ? size.height : CGFloat.greatestFiniteMagnitude
        
        let errorHeight = getErrorViewHeight(for: size)
        let controlsHeight = getControlsViewHeight(for: size)
        let maxContentHeight = maxHeight - controlsHeight - errorHeight
        let contentHeight = getContentViewHeight(for: CGSize(width: size.width, height: maxContentHeight))
        
        var totalHeight = errorHeight + controlsHeight + contentHeight
        if size.height > 0 && size.height < totalHeight {
            totalHeight = size.height
        }
        
        return CGSize(width: size.width, height: totalHeight)
    }
}

// MARK:- Screen Cover

extension ModalCardViewController {
    
    func hideContentWhileBackgrounded() {
        contentScrollView.isHidden = true
    }
    
    func showContent() {
        if !isShowingSuccessView {
            contentScrollView.isHidden = false
        }
    }
}

// MARK:- Loading

extension ModalCardViewController {
    
    func setIsLoading(_ isLoading: Bool, removeBlur: Bool = true, animated: Bool) {
        guard isLoading != self.isLoading && isViewLoaded else {
            return
        }
        self.isLoading = isLoading
        
        if isLoading {
            view.addSubview(loadingView)
        }
        
        var animationBlock: (() -> Void) = { [weak self] in
            self?.loadingView.isLoading = isLoading
            if isLoading {
                self?.loadingView.isBlurred = true
            } else if removeBlur {
                self?.loadingView.isBlurred = false
            }
        }
        
        var completionBlock: ((Bool) -> Void) = { [weak self] (completed) in
            if !isLoading && removeBlur {
                self?.loadingView.removeFromSuperview()
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.2,
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: animationBlock,
                           completion: completionBlock)
        } else {
            animationBlock()
            completionBlock(true)
        }
    }
}

// MARK:- Success View

extension ModalCardViewController {
    
    func showSuccessView() {
        guard !isShowingSuccessView else {
            return
        }
        isShowingSuccessView = true
        
        view.addSubview(successView)
        
        successView.alpha = 0.0
        successView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        successView.alpha = 1.0
        
        presentationAnimator.updatePresentedViewFrame(additionalUpdates: { [weak self] in
            self?.controlsView.confirmText = ASAPP.strings.creditCardFinishButton
            self?.controlsView.cancelButtonHidden = true
            self?.controlsView.updateFrames()
            }, completion: {
                UIView.animate(
                    withDuration: 0.6,
                    delay: 0,
                    usingSpringWithDamping: 0.65,
                    initialSpringVelocity: 20.0,
                    options: .curveEaseOut,
                    animations: { [weak self] in
                        self?.successView.transform = .identity
                }) { (complete) in
                    
                }
        })
    }
    
    func hideSuccessView() {
        guard isShowingSuccessView else {
            return
        }
        isShowingSuccessView = false
        
        presentationAnimator.updatePresentedViewFrame(
            additionalUpdates: { [weak self] in
                self?.successView.alpha = 0.0
                self?.controlsView.confirmText = ASAPP.strings.creditCardConfirmButton
                self?.controlsView.cancelButtonHidden = false
                self?.controlsView.updateFrames()
            },
            completion: { [weak self] (completed) in
                self?.successView.removeFromSuperview()
        })
    }
}
