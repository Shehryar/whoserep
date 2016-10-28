//
//  KeyboardObserver.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/26/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

// MARK:- KeyboardObserverDelegate

protocol KeyboardObserverDelegate: class {
    /// Height is visible height relative to UIScreen.mainScreen
    func keyboardWillUpdateVisibleHeight(_ height: CGFloat, withDuration duration: TimeInterval, animationCurve: UIViewAnimationOptions)
}

// MARK:- KeyboardObserver

class KeyboardObserver: NSObject {
    
    // MARK: Properties
    
    weak var delegate: KeyboardObserverDelegate?
    
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
    
    @objc fileprivate func keyboardWillAdjustFrame(_ sender: Notification) {
        guard let delegate = delegate, let userInfo = (sender as NSNotification).userInfo else {
            return
        }
        
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = UIScreen.main.bounds.height - keyboardFrame.minY
        let duration = TimeInterval(userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber)
        
        var animationCurve: UIViewAnimationOptions = .curveLinear
        if let animationCurveInt = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue {
            animationCurve = UIViewAnimationOptions(rawValue: animationCurveInt<<16)
        }

        delegate.keyboardWillUpdateVisibleHeight(keyboardHeight, withDuration: duration, animationCurve: animationCurve)
    }
}
