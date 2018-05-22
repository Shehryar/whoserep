//
//  UIEdgeInsetsExtensions.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 5/16/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    var vertical: CGFloat {
        return top + bottom
    }
    
    var horizontal: CGFloat {
        return left + right
    }
}
