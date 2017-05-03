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
        layer.borderWidth = style.borderWidth
        if style.borderWidth > 0 {
            if let borderColor = style.borderColor?.cgColor {
                layer.borderColor = borderColor
            } else {
                layer.borderColor = ASAPP.styles.colors.separatorPrimary.cgColor
            }
        }
        layer.cornerRadius = style.cornerRadius
        
        setNeedsLayout()
    }
}
