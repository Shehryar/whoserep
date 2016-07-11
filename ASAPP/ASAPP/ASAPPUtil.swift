//
//  ASAPPUtil.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/14/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

let framework = NSBundle(forClass: ASAPP.self)

// MARK: - ASAPP Log

var ASAPPLogEnabled = true
func ASAPPLog(items: Any...) {
    if !ASAPPLogEnabled {
        return
    }
    print("ASAPP:", items)
}

func ASAPPLoge(items: Any...) {
    print("ASAPP ERROR:", items)
}

// MARK: - Custom Fonts

func loadFonts() {
    loadFont("Lato-Regular", type: "ttf")
    loadFont("Lato-Bold", type: "ttf")
    loadFont("Lato-Black", type: "ttf")
    loadFont("Lato-Light", type: "ttf")
}

func loadFont(name: String, type: String) {
    let path = framework.pathForResource(name, ofType: type)
    let data = NSData(contentsOfFile: path!)
    var err: Unmanaged<CFError>?
    let provider = CGDataProviderCreateWithCFData(data)
    if let font = CGFontCreateWithDataProvider(provider) {
        CTFontManagerRegisterGraphicsFont(font, &err)
        if err != nil {
            ASAPPLoge(err)
        }
    }
}

// MARK: - Keyboard events

protocol ASAPPKeyboardObserverDelegate {
    func ASAPPKeyboardWillShow(size: CGRect, duration: NSTimeInterval)
    func ASAPPKeyboardWillHide(duration: NSTimeInterval)
}

class ASAPPKeyboardObserver: NSObject {
    
    var delegate: ASAPPKeyboardObserverDelegate!
    
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ASAPPKeyboardObserver.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ASAPPKeyboardObserver.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterForNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if delegate == nil {
            return
        }
        
        var userInfo = sender.userInfo
        let size = (userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = NSTimeInterval(userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber)
        
        delegate.ASAPPKeyboardWillShow(size, duration: duration)
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if delegate == nil {
            return
        }
        
        var userInfo = sender.userInfo
        let duration = NSTimeInterval(userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber)
        
        delegate.ASAPPKeyboardWillHide(duration)
    }
}