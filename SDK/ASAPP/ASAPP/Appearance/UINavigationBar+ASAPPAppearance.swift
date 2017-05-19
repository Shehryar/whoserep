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
        isTranslucent = false
        isOpaque = true
        shadowImage = nil
        setBackgroundImage(nil, for: .default)
        setBackgroundImage(nil, for: .compact)
        backgroundColor = nil
        if ASAPP.styles.colors.navBarBackground.isDark() {
            barStyle = .black
            if ASAPP.styles.colors.navBarBackground != UIColor.black {
                barTintColor = ASAPP.styles.colors.navBarBackground
            }
        } else {
            barStyle = .default
            if ASAPP.styles.colors.navBarBackground != UIColor.white {
                barTintColor = ASAPP.styles.colors.navBarBackground
            }
        }
        tintColor = ASAPP.styles.colors.navBarButton
    }
}
