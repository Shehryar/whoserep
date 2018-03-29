//
//  UINavigationBar+ASAPPAppearance.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/15/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

extension UINavigationBar {

    func applyASAPPStyles() {
        isTranslucent = ASAPP.styles.colors.navBarBackground == nil
        isOpaque = false
        barStyle = .default
        shadowImage = nil
        setBackgroundImage(nil, for: .default)
        setBackgroundImage(nil, for: .compact)
        backgroundColor = nil
        
        if let navBarBackground = ASAPP.styles.colors.navBarBackground {
            if navBarBackground.isDark() {
                barStyle = .black
                if ASAPP.styles.colors.navBarBackground != UIColor.black {
                    barTintColor = navBarBackground
                }
            } else {
                barStyle = .default
                if ASAPP.styles.colors.navBarBackground != UIColor.white {
                    barTintColor = navBarBackground
                }
            }
        }
        
        tintColor = ASAPP.styles.colors.navBarButton
        
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
    }
    
    func removeShadow() {
        layer.shadowOffset = .zero
        layer.shadowColor = nil
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
    }
}
