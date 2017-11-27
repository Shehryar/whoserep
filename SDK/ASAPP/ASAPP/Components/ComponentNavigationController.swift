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
    
    // MARK: - UpdatableFrames
    
    func updateFrames() {
        for viewController in viewControllers {
            if let updatableFramesVC = viewController as? UpdatableFrames {
                updatableFramesVC.updateFrames()
            }
        }
    }
}

extension ComponentNavigationController: KeyboardObserverDelegate {
    func keyboardWillUpdateVisibleHeight(_ height: CGFloat, withDuration duration: TimeInterval, animationCurve: UIViewAnimationOptions) {
        guard height != keyboardHeight else {
            return
        }
        
        keyboardHeight = height
        
        if let updatableFramesVC = visibleViewController as? UpdatableFrames,
           let view = visibleViewController?.view {
            let newHeight = view.bounds.height - keyboardHeight
            
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: animationCurve,
                animations: {
                    updatableFramesVC.updateFrames()
                    
                    var frame = view.frame
                    frame.size.height = newHeight
                    view.frame = frame
                    view.layoutIfNeeded()
                }, completion: nil)
        }
    }
}
