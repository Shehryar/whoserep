//
//  Dispatcher.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/26/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class DemoDispatcher {
    class func delay(_ delayInMilliseconds: Double, closure: @escaping (() -> Void)) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delayInMilliseconds * Double(NSEC_PER_MSEC))) / Double(NSEC_PER_SEC), execute: closure)
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
