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
    func keyboardWillUpdateVisibleHeight(_ height: CGFloat, withDuration duration: TimeInterval, animationCurve: UIViewAnimationOptions)
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
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardObserver.keyboardWillAdjustFrame(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardObserver.keyboardWillAdjustFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardObserver.keyboardWillAdjustFrame(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = keyboardFrame.height
        let duration = TimeInterval(truncating: userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber)
        
        var animationCurve: UIViewAnimationOptions = .curveLinear
        if let animationCurveInt = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue {
            animationCurve = UIViewAnimationOptions(rawValue: animationCurveInt<<16)
        }

        delegate.keyboardWillUpdateVisibleHeight(keyboardHeight, withDuration: duration, animationCurve: animationCurve)
    }
}
