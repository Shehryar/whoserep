//
//  CreditCardInputViewController.swift
//  AnimationTestingGround
//
//  Created by Mitchell Morgan on 2/10/17.
//  Copyright © 2017 ASAPP, Inc. All rights reserved.
//

import UIKit

class CreditCardInputViewController: UIViewController {
    
    enum TestState {
        case start
        case error
        case success
    }
    
    var testState = TestState.start
    
    let errorView = ModalCardErrorView()
    let creditCardView = CreditCardInputView()
    let controlsView = CancelConfirmControlsView()
    let loadingView = UIVisualEffectView(effect: nil)
    let loadingVibrancyView = UIVisualEffectView(effect: nil)
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let successView = SuccessCheckmarkView()
    let screenCoverView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    fileprivate var isLoading = false
    fileprivate var isShowingSuccessView = false

    fileprivate let presentationAnimator = ModalCardPresentationAnimator()
    
    // MARK:- Initialization
    
    func commonInit() {
        // Presentation Animation
        modalPresentationStyle = .custom
        // modalPresentationCapturesStatusBarAppearance = true
        transitioningDelegate = presentationAnimator
        
        // Controls
        
        controlsView.onCancelButtonTap = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        controlsView.onConfirmButtonTap = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            self?.view.endEditing(true)
            self?.errorView.text = nil
            self?.startLoading()
            self?.presentationAnimator.updatePresentedViewFrame()
            
            var block: (() -> Void)? = nil
            switch strongSelf.testState {
            case .start:
                block = {
                    self?.stopLoading()
                    self?.errorView.text = "Oops! There was an error :("
                        // "Oops! We were unable to process your request. Please check your information and try again."
                    self?.presentationAnimator.updatePresentedViewFrame()
                }
                strongSelf.testState = .error
                break
                
            case .error:
                block = {
                    self?.stopLoading(removeBlurView: false)
                    self?.showSuccessView()
                }
                strongSelf.testState = .success
                break
                
            case .success:
                self?.dismiss(animated: true, completion: nil)
                break
            }
            if let block = block {
                Dispatcher.delay(1500, closure: { 
                    block()
                })
            }
        }
        
        // Loader
        spinner.hidesWhenStopped = true
        loadingVibrancyView.contentView.addSubview(spinner)
        loadingView.addSubview(loadingVibrancyView)
        
        // SuccessView
        successView.alpha = 0.0
        
        // Screen Cover
        screenCoverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CreditCardInputViewController.hideScreenCoverView)))
        
        // Notifications
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(CreditCardInputViewController.showScreenCoverView),
                name: Notification.Name.UIApplicationDidEnterBackground,
                object: nil)
        
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(CreditCardInputViewController.showScreenCoverView),
                name: Notification.Name.UIApplicationWillResignActive,
                object: nil)
        
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(CreditCardInputViewController.hideScreenCoverView),
                name: Notification.Name.UIApplicationDidBecomeActive,
                object: nil)
        
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(CreditCardInputViewController.hideScreenCoverView),
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
        view.backgroundColor = UIColor(red:0.973, green:0.969, blue:0.969, alpha:1)
        
        view.layer.cornerRadius = 5.0
//        view.layer.borderWidth = 1
//        view.layer.borderColor = UIColor(red: 0.925, green: 0.906, blue: 0.906, alpha: 1).cgColor
        
        view.addSubview(creditCardView)
        view.addSubview(errorView)
        view.addSubview(successView)
        view.addSubview(controlsView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
    }
    
    // MARK:- Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateFrames()
    }
}

// MARK:- ModalCardViewController

extension CreditCardInputViewController: ModalCardViewController {
    
    func getControlsViewHeight(for size: CGSize) -> CGFloat {
        return ceil(controlsView.sizeThatFits(CGSize(width: size.width, height: 0)).height)
    }
    
    func getErrorViewHeight(for size: CGSize) -> CGFloat {
        if errorView.text == nil {
            return 0
        }
        return ceil(errorView.sizeThatFits(CGSize(width: size.width, height: 0)).height)
    }
    
    func getContentViewHeight(for size: CGSize) -> CGFloat {
        var contentHeight: CGFloat
        if !isShowingSuccessView {
            contentHeight = ceil(creditCardView.sizeThatFits(CGSize(width: size.width, height: size.height)).height)
        } else {
            contentHeight = ceil(successView.sizeThatFits(CGSize(width: size.width, height: size.height)).height)
        }
        if size.height > 0 && contentHeight > size.height {
            contentHeight = size.height
        }
        return contentHeight
    }
    
    func updateFrames() {
        let maxHeight = view.bounds.height
        
        let errorHeight = getErrorViewHeight(for: view.bounds.size)
        let controlsHeight = getControlsViewHeight(for: view.bounds.size)
        let maxContentHeight = maxHeight - controlsHeight - errorHeight
        let contentHeight = getContentViewHeight(for: CGSize(width: view.bounds.width, height: maxContentHeight))
        
        errorView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: errorHeight)
        
        let controlsTop = view.bounds.height - controlsHeight
        controlsView.frame = CGRect(x: 0, y: controlsTop, width: view.bounds.width, height: controlsHeight)
        
        
        let contentViewFrame = CGRect(x: 0, y: errorHeight, width: view.bounds.width, height: contentHeight)

        // Credit Card
        creditCardView.frame = contentViewFrame
        creditCardView.alpha = isShowingSuccessView ? 0 : 1
        creditCardView.updateFrames()
        
        // Success
        if successView.transform.isIdentity {
            successView.frame = contentViewFrame
        }
        successView.alpha = isShowingSuccessView ? 1 : 0
        
        // Loader + Screen  Cover
        let contentPlusFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: errorHeight + contentHeight)

        loadingView.frame = contentPlusFrame
        loadingVibrancyView.frame = loadingView.bounds
        spinner.center = CGPoint(x: loadingView.bounds.midX, y: loadingView.bounds.midY)
        
        // Screen Cover
        screenCoverView.frame = contentPlusFrame
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

// MARK:- Loading

extension CreditCardInputViewController {
    
    func startLoading(animated: Bool = true) {
        guard !isLoading else {
            return
        }
        isLoading = true
        
        func setupBlock() {
            spinner.startAnimating()
            spinner.alpha = 0
        }
        
        func block1() {
            controlsView.confirmButtonEnabled = false
            view.addSubview(loadingView)
            let blurEffect = UIBlurEffect(style: .light)
            loadingView.effect = blurEffect
            loadingVibrancyView.effect = UIVibrancyEffect(blurEffect: blurEffect)
            spinner.alpha = 1.0
        }
        func block2() {
//            spinner.startAnimating()
        }
        
        if animated {
            setupBlock()
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                block1()
            }, completion: { (completed) in
                block2()
            })
        } else {
            setupBlock()
            block1()
            block2()
        }
    }
    
    func stopLoading(animated: Bool = true, removeBlurView: Bool = true, completion: (() -> Void)? = nil) {
        guard isLoading else {
            return
        }
        isLoading = false
        
        func block1() {
            spinner.stopAnimating()
            if removeBlurView {
                loadingView.effect = nil
                loadingVibrancyView.effect = nil
            }
        }
        func block2() {
            if removeBlurView {
                loadingView.removeFromSuperview()
            }
            controlsView.confirmButtonEnabled = true
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                block1()
            }, completion: { (completed) in
                block2()
                completion?()
            })
        } else {
            block1()
            block2()
            completion?()
        }
    }
}

// MARK:- Success View

extension CreditCardInputViewController {
    
    func showSuccessView() {
        guard !isShowingSuccessView else {
            return
        }
        isShowingSuccessView = true

        view.bringSubview(toFront: successView)
        successView.alpha = 0.0
        successView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        successView.alpha = 1.0
        
        presentationAnimator.updatePresentedViewFrame(additionalUpdates: { 
            self.controlsView.confirmText = "FINISH"
            self.controlsView.cancelButtonHidden = true
            self.controlsView.updateFrames()
        }, completion: {
            UIView.animate(
                withDuration: 0.6,
                delay: 0,
                usingSpringWithDamping: 0.65,
                initialSpringVelocity: 20.0,
                options: .curveEaseOut,
                animations: {
                    self.successView.transform = .identity
            }) { (complete) in
                
            }
        })
    }
    
    func hideSuccessView() {
        guard isShowingSuccessView else {
            return
        }
        isShowingSuccessView = false
        
        presentationAnimator.updatePresentedViewFrame(additionalUpdates: { 
            self.controlsView.confirmText = "CONFIRM"
            self.controlsView.cancelButtonHidden = false
            self.controlsView.updateFrames()
        }, completion: nil)
    }
}

// MARK:- Screen Cover

extension CreditCardInputViewController {
    
    func showScreenCoverView() {
        if view.subviews.contains(screenCoverView) {
            view.bringSubview(toFront: screenCoverView)
        } else {
            view.addSubview(screenCoverView)
        }
    }
    
    func hideScreenCoverView() {
        if view.subviews.contains(screenCoverView) {
            screenCoverView.removeFromSuperview()
        }
    }
}
