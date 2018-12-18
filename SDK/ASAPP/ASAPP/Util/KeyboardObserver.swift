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
        
        // Note:
        // If the app launches in landscape, and then transitions to portrait for chat the input accessory view's
        // frame will be incorrect. Though the keyboard is hidden the last notification to fire
        // is `UIKeyboardWillShow`, the keyboards height then comes back incorrect and the
        // accessory is placed in the wrong location
        // Similar open radar: https://openradar.appspot.com/34912123
        // Relevant stack overflow: https://stackoverflow.com/questions/51889141/ios-keyboard-input-accessory-view-wrong-orientation-when-we-start-the-applicat
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = keyboardFrame.height
        let duration = TimeInterval(truncating: userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber)
        
        var animationCurve: UIView.AnimationOptions = .curveLinear
        if let animationCurveInt = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue {
            animationCurve = UIView.AnimationOptions(rawValue: animationCurveInt<<16)
        }

        delegate.keyboardWillUpdateVisibleHeight(keyboardHeight, withDuration: duration, animationCurve: animationCurve)
    }
}
