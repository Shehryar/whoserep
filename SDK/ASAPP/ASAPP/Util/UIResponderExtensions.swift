//
//  UIResponderExtensions.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 8/14/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

extension UIResponder {
    private static weak var _currentFirstResponder: UIResponder?
    
    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.recordFirstResponder), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }
    
    @objc func recordFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }
}
