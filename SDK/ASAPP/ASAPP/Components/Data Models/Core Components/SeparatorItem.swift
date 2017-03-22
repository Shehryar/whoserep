//
//  SeparatorItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SeparatorItem: Component {

    // MARK:- Defaults
    
    static let defaultColor = UIColor(red:0.820, green:0.827, blue:0.851, alpha:1.000)
    
    // MARK:- Properties
    
    override var viewClass: UIView.Type {
        return SeparatorView.self
    }
}
