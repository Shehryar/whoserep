//
//  Dispatcher.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/26/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class Dispatcher {
    class func delay(_ delay: DispatchTimeInterval = .defaultAnimationDuration, closure: @escaping (() -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: closure)
    }
    
    class func performOnMainThread(_ closure: @escaping (() -> Void)) {
        DispatchQueue.main.async {
            closure()
        }
    }
    
    class func performOnBackgroundThread(_ closure: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .utility).async {
            closure()
        }
    }
}
