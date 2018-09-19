//
//  KeyboardObserver.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/26/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

// MARK: - KeyboardObserverDelegate

protocol KeyboardObserverDelegate: class {
    /// Height is visible height relative to UIScreen.mainScreen
    func keyboardWillUpdateVisibleHeight(_ height: CGFloat, withDuration duration: TimeInterval, animationCurve: UIView.AnimationOptions)
}

// MARK: - KeyboardObserver

class KeyboardObserver: NSObject {
    
    // MARK: Properties
    
    weak var delegate: KeyboardObserverDelegate?
    
    deinit {
        deregisterForNotification()
    }
    
    // MARK: Public Methods
    
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardObserver.keyboardWillAdjustFrame(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardObserver.keyboardWillAdjustFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardObserver.keyboardWillAdjustFrame(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterForNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Private Methods
    
    @objc private func keyboardWillAdjustFrame(_ sender: Notification) {
        guard let delegate = delegate, let userInfo = (sender as NSNotification).userInfo else {
            return
        }
        
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = UIScreen.main.bounds.height - keyboardFrame.minY
        let duration = TimeInterval(truncating: userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber)
        
        var animationCurve: UIView.AnimationOptions = .curveLinear
        if let animationCurveInt = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue {
            animationCurve = UIView.AnimationOptions(rawValue: animationCurveInt<<16)
        }

        delegate.keyboardWillUpdateVisibleHeight(keyboardHeight, withDuration: duration, animationCurve: animationCurve)
    }
}
