//
//  KeyboardObserver.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/26/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

// MARK:- KeyboardObserverDelegate

protocol KeyboardObserverDelegate {
    /// Height is visible height relative to UIScreen.mainScreen
    func keyboardWillUpdateVisibleHeight(height: CGFloat, withDuration duration: NSTimeInterval, animationCurve: UIViewAnimationOptions)
}

// MARK:- KeyboardObserver

class KeyboardObserver: NSObject {
    
    // MARK: Properties
    
    var delegate: KeyboardObserverDelegate?
    
    // MARK: Public Methods
    
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KeyboardObserver.keyboardWillAdjustFrame(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KeyboardObserver.keyboardWillAdjustFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KeyboardObserver.keyboardWillAdjustFrame(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterForNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Private Methods
    
    @objc private func keyboardWillAdjustFrame(sender: NSNotification) {
        guard let delegate = delegate, userInfo = sender.userInfo else {
            return
        }
        
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardHeight = CGRectGetHeight(UIScreen.mainScreen().bounds) - CGRectGetMinY(keyboardFrame)
        let duration = NSTimeInterval(userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber)
        
        var animationCurve: UIViewAnimationOptions = .CurveLinear
        if let animationCurveInt = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.unsignedIntegerValue {
            animationCurve = UIViewAnimationOptions(rawValue: animationCurveInt<<16)
        }

        delegate.keyboardWillUpdateVisibleHeight(keyboardHeight, withDuration: duration, animationCurve: animationCurve)
    }
}
