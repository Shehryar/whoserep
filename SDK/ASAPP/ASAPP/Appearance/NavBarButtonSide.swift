//
//  NavBarButtonSide.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 8/29/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum NavBarButtonSide {
    case left
    case right
    
    func opposite() -> NavBarButtonSide {
        return self == .left ? .right : .left
    }
}
