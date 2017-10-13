//
//  ASAPPSegue.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 8/29/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

/**
 Represents the kind of segue used by `ASAPPButton` to show the SDK's view controller.
 */
@objc
public enum ASAPPSegue: Int {
    /// Present the view controller modally.
    case present
    
    /// Push the view controller onto the navigation stack.
    case push
}
