//
//  Dispatch.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/26/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

func delay(delayInMilliseconds: Double, closure: (() -> Void)) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delayInMilliseconds * Double(NSEC_PER_MSEC))
        ),
        dispatch_get_main_queue(), closure)
}
