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
    func keyboardWillShow(size: CGRect, duration: NSTimeInterval)
    func keyboardWillHide(duration: NSTimeInterval)
}

// MARK:- KeyboardObserver

class KeyboardObserver: NSObject {
    
    // MARK: Properties
    
    var delegate: KeyboardObserverDelegate?
    
    // MARK: Public Methods
    
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KeyboardObserver.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KeyboardObserver.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterForNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Private Methods
    
    @objc private func keyboardWillShow(sender: NSNotification) {
        if delegate == nil {
            return
        }
        
        var userInfo = sender.userInfo
        let size = (userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = NSTimeInterval(userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber)
        
        delegate?.keyboardWillShow(size, duration: duration)
    }
    
    @objc private func keyboardWillHide(sender: NSNotification) {
        if delegate == nil {
            return
        }
        
        var userInfo = sender.userInfo
        let duration = NSTimeInterval(userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber)
        
        delegate?.keyboardWillHide(duration)
    }
}
