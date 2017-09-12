//
//  ModalCardViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

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
    
    var shouldHideContentWhenBackgrounded = false
    
    fileprivate(set) var isLoading: Bool = false
    fileprivate(set) var isShowingSuccessView: Bool = false
    
    let errorView = ModalCardErrorView()
    let contentScrollView = UIScrollView()
    let controlsView = ModalCardControlsView()
    let loadingView = ModalCardLoadingView()
    let successView = ModalCardSuccessView()
    let presentationAnimator = ModalCardPresentationAnimator()
    
    // MARK:- Initialization
    
    func commonInit() {
        modalPresentationStyle = .custom
        transitioningDelegate = presentationAnimator
        
        contentScrollView.clipsToBounds = false
        contentScrollView.alwaysBounceVertical = false
        contentScrollView.addSubview(successView)
        
        // Controls
        controlsView.onCancelButtonTap = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
        controlsView.onConfirmButtonTap = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.isShowingSuccessView {
                strongSelf.hideSuccessView()
            } else {
                strongSelf.showSuccessView()
            }
        }
        
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
    
    // MARK:- Status Bar
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.layer.cornerRadius = 5.0
        
        if let contentView = contentView {
            if !contentScrollView.subviews.contains(contentView) {
                contentScrollView.addSubview(contentView)
            }
        }
        view.addSubview(contentScrollView)
        view.addSubview(errorView)
        view.addSubview(controlsView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
    }
    
    // MARK:- View Layout
    
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
    
    private func getSuccessViewHeight(for size: CGSize) -> CGFloat {
        return ceil(successView.sizeThatFits(CGSize(width: size.width, height: size.height)).height)
    }
    
    private func getContentViewHeight(for width: CGFloat) -> CGFloat {
        var contentHeight: CGFloat = 0.0
        if let contentView = contentView {
            contentHeight = ceil(contentView.sizeThatFits(CGSize(width: width, height: 0)).height)
        }
        return contentHeight
    }
    
    // MARK: Public API
    
    func updateFrames() {
        
        // Error View
        let errorHeight = getErrorViewHeight(for: view.bounds.size)
        errorView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: errorHeight)
        
        // Controls View
        let controlsHeight = getControlsViewHeight(for: view.bounds.size)
        let controlsTop = view.bounds.height - controlsHeight
        controlsView.frame = CGRect(x: 0, y: controlsTop, width: view.bounds.width, height: controlsHeight)
        
        // Loading View
        loadingView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: controlsView.frame.minY)
        
        // Content View
        let contentViewHeight = getContentViewHeight(for: view.bounds.width)
        contentView?.frame = CGRect(x: 0, y: 0, width: contentScrollView.bounds.width, height: contentViewHeight)
    
        // Success View
        let successViewHeight = getSuccessViewHeight(for: view.bounds.size)
        if successView.transform.isIdentity {
            successView.frame = CGRect(x: 0, y: 0, width: contentScrollView.bounds.width, height: successViewHeight)
        }
        
        // Content Scroll View
        let containerViewTop = errorView.frame.maxY
        let containerViewHeight = controlsView.frame.minY - containerViewTop
        contentScrollView.frame = CGRect(x: 0, y: containerViewTop, width: view.bounds.width, height: containerViewHeight)
        
        let contentHeight = isShowingSuccessView ? successViewHeight : contentViewHeight
        contentScrollView.contentSize = CGSize(width: contentScrollView.bounds.width, height: contentHeight)
        
        successView.alpha = isShowingSuccessView ? 1.0 : 0.0
        contentView?.alpha = isShowingSuccessView ? 0.0 : 1.0
    }
    
    func viewSizeThatFits(_ size: CGSize) -> CGSize {
        let maxHeight: CGFloat = size.height > 0 ? size.height : CGFloat.greatestFiniteMagnitude
        
        let errorHeight = getErrorViewHeight(for: size)
        let controlsHeight = getControlsViewHeight(for: size)
        
        let maxContentHeight = max(0, maxHeight - controlsHeight - errorHeight)
        var contentHeight: CGFloat = 0.0
        if isShowingSuccessView {
            contentHeight = getSuccessViewHeight(for: size)
        } else {
            contentHeight = getContentViewHeight(for: size.width)
        }
        if contentHeight > maxContentHeight {
            contentHeight = maxContentHeight
        }
        
        let totalHeight = errorHeight + controlsHeight + contentHeight
        return CGSize(width: size.width, height: totalHeight)
    }
}

// MARK:- Screen Cover

extension ModalCardViewController {
    
    func hideContentWhileBackgrounded() {
        if shouldHideContentWhenBackgrounded {
            contentView?.alpha = 0.0
        }
    }
    
    func showContent() {
        if !isShowingSuccessView {
            contentView?.alpha = 1.0
        }
    }
}

// MARK:- Error

extension ModalCardViewController {
    
    func showErrorMessage(_ errorMessage: String?) {
        errorView.text = errorMessage
        presentationAnimator.updatePresentedViewFrame()
    }
}

// MARK:- Loading

extension ModalCardViewController {
    
    func startLoading() {
        guard !isLoading else {
            return
        }
        isLoading = true
        
        controlsView.confirmButtonEnabled = false
        view.addSubview(loadingView)
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.loadingView.isBlurred = true
                self?.loadingView.isLoading = true
            },
            completion: nil)
    }
    
    func stopLoading(hideContentView: Bool = false, completion: (() -> Void)? = nil) {
        guard isLoading else {
            return
        }
        isLoading = false
        
        if hideContentView {
            contentView?.alpha = 0.0
        }
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.loadingView.isLoading = false
                self?.loadingView.isBlurred = false
            },
            completion: { [weak self] _ in
                self?.controlsView.confirmButtonEnabled = true
                self?.loadingView.removeFromSuperview()
            })
        
    }
    
    func setIsLoading(_ isLoading: Bool, removeBlur: Bool = true, animated: Bool) {
        guard isLoading != self.isLoading && isViewLoaded else {
            return
        }
        self.isLoading = isLoading
        
        if isLoading {
            view.addSubview(loadingView)
        }
        
        let animationBlock: (() -> Void) = { [weak self] in
            self?.loadingView.isLoading = isLoading
            if isLoading {
                self?.loadingView.isBlurred = true
            } else if removeBlur {
                self?.loadingView.isBlurred = false
            }
        }
        
        let completionBlock: ((Bool) -> Void) = { [weak self] (completed) in
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
    
    func showSuccessView(buttonText: String? = nil) {
        guard !isShowingSuccessView else {
            return
        }
        isShowingSuccessView = true
        
        contentScrollView.bringSubview(toFront: successView)
        
        successView.alpha = 0.0
        successView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        successView.alpha = 1.0
        
        presentationAnimator.updatePresentedViewFrame(additionalUpdates: { [weak self] in
            self?.controlsView.confirmText = buttonText ?? ASAPP.strings.modalViewDoneButton
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
            }, completion: nil)
        })
    }
    
    func hideSuccessView() {
        guard isShowingSuccessView else {
            return
        }
        isShowingSuccessView = false
        
        presentationAnimator.updatePresentedViewFrame(
            additionalUpdates: { [weak self] in
                self?.controlsView.confirmText = ASAPP.strings.modalViewSubmitButton
                self?.controlsView.cancelButtonHidden = false
                self?.controlsView.updateFrames()
            }, completion: nil)
    }
}
