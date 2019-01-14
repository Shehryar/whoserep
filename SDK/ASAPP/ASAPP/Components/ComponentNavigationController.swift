//
//  ComponentNavigationController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentNavigationController: UINavigationController, UpdatableFrames {
    
    let presentationAnimator = ModalCardPresentationAnimator()
    
    private var keyboardObserver: KeyboardObserver?
    private var keyboardHeight: CGFloat = 0.0
    
    var displayStyle: ComponentViewDisplayStyle = .full {
        didSet {
            useCustomPresentation = displayStyle == .inset
        }
    }
    
    private(set) var useCustomPresentation: Bool = false {
        didSet {
            if useCustomPresentation {
                isNavigationBarHidden = true
                presentationAnimator.fixedBottom = true
                presentationAnimator.viewInsetTop = 40
                presentationAnimator.viewInsetSides = 0
                presentationAnimator.viewInsetBottom = 0
                presentationAnimator.tapToDismissEnabled = true
                modalPresentationStyle = .custom
                transitioningDelegate = presentationAnimator
            } else {
                isNavigationBarHidden = false
                modalPresentationStyle = .fullScreen
                transitioningDelegate = nil
                presentationAnimator.tapToDismissEnabled = false
                keyboardObserver = KeyboardObserver()
                keyboardObserver!.delegate = self
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isBeingPresented {
            keyboardObserver?.registerForNotifications()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isBeingDismissed {
            keyboardObserver?.deregisterForNotification()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ASAPP.styles.colors.backgroundPrimary
    }
    
    // MARK: - UpdatableFrames
    
    func willUpdateFrames() {
        for viewController in viewControllers {
            if let updatableFramesVC = viewController as? UpdatableFrames {
                updatableFramesVC.willUpdateFrames()
            }
        }
    }
    
    func updateFrames() {
        for viewController in viewControllers {
            if let updatableFramesVC = viewController as? UpdatableFrames {
                updatableFramesVC.updateFrames()
            }
        }
    }
    
    func didUpdateFrames() {
        for viewController in viewControllers {
            if let updatableFramesVC = viewController as? UpdatableFrames {
                updatableFramesVC.didUpdateFrames()
            }
        }
    }
}

extension ComponentNavigationController: KeyboardObserverDelegate {
    func keyboardWillUpdateVisibleHeight(_ height: CGFloat, withDuration duration: TimeInterval, animationCurve: UIView.AnimationOptions) {
        guard height != keyboardHeight else {
            return
        }
        
        keyboardHeight = height
        
        if let viewController = topViewController as? UpdatableFrames,
           let view = topViewController?.view {
            let newHeight = view.frame.height - keyboardHeight
            viewController.willUpdateFrames()
            
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: animationCurve,
                animations: {
                    
                viewController.updateFrames()
                var frame = view.frame
                frame.size.height = newHeight
                view.frame = frame
                view.layoutIfNeeded()
                
                viewController.didUpdateFrames()
            })
        }
    }
}
