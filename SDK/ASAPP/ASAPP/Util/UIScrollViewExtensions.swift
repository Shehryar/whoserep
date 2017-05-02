//
//  UIScrollViewExtensions.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/2/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    var currentPage: Int {
        return max(Int(0),
                   Int(floor((contentOffset.x + bounds.width / CGFloat(2.0)) / bounds.width)))
    }
}
