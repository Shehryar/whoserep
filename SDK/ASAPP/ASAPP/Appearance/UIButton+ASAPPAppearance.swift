//
//  UIButton+ASAPPAppearance.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

extension UIButton {
    
    func applyColors(_ colors: ASAPPButtonColors) {
        setBackgroundImage(UIImage.imageWithColor(colors.backgroundNormal), for: .normal)
        setBackgroundImage(UIImage.imageWithColor(colors.backgroundHighlighted), for: .highlighted)
        setBackgroundImage(UIImage.imageWithColor(colors.backgroundDisabled), for: .disabled)
        
        setTitleColor(colors.textNormal, for: .normal)
        setTitleColor(colors.textHighlighted, for: .highlighted)
        setTitleColor(colors.textDisabled, for: .disabled)
        
        if let borderColor = colors.border {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 1
        } else {
            layer.borderColor = nil
            layer.borderWidth = 0
        }
    }
    
    func setAttributedText(_ text: String?,
                           with textStyle: ASAPPTextStyle,
                           color: UIColor,
                           for state: UIControlState) {
        
        guard let text = text else {
            setAttributedTitle(nil, for: state)
            return
        }
        
        setAttributedTitle(NSAttributedString(string: text, attributes: [
            NSFontAttributeName : textStyle.font,
            NSForegroundColorAttributeName : color,
            NSKernAttributeName : textStyle.letterSpacing
            ]), for: state)
    }
}
