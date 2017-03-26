//
//  ComponentStyleable.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol ComponentStyleable {
    func applyStyle(_ style: ComponentStyle)
}

extension ComponentStyleable where Self: UIView {
    
    func applyStyle(_ style: ComponentStyle) {
        backgroundColor = style.backgroundColor ?? UIColor.clear
        layer.borderColor = style.borderColor?.cgColor
        layer.borderWidth = style.borderWidth
        layer.cornerRadius = style.cornerRadius
        
        setNeedsLayout()
    }
}
