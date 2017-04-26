//
//  UIButton+ASAPPAppearance.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

extension UIButton {
    
    func updateText(_ text: String?, textStyle: ASAPPTextStyle, colors: ASAPPButtonColors) {
        // Background
        setBackgroundImage(UIImage.imageWithColor(colors.backgroundNormal), for: .normal)
        setBackgroundImage(UIImage.imageWithColor(colors.backgroundHighlighted), for: .highlighted)
        setBackgroundImage(UIImage.imageWithColor(colors.backgroundDisabled), for: .disabled)
        
        // Text
        if let text = text {
            setAttributedTitle(NSAttributedString(string: text, attributes: [
                NSFontAttributeName : textStyle.font,
                NSForegroundColorAttributeName : colors.textNormal,
                NSKernAttributeName : textStyle.letterSpacing
                ]), for: .normal)
            
            setAttributedTitle(NSAttributedString(string: text, attributes: [
                NSFontAttributeName : textStyle.font,
                NSForegroundColorAttributeName : colors.textHighlighted,
                NSKernAttributeName : textStyle.letterSpacing
                ]), for: .highlighted)
            
            setAttributedTitle(NSAttributedString(string: text, attributes: [
                NSFontAttributeName : textStyle.font,
                NSForegroundColorAttributeName : colors.textDisabled,
                NSKernAttributeName : textStyle.letterSpacing
                ]), for: .disabled)
        } else {
            setAttributedTitle(nil, for: [.normal, .highlighted, .disabled])
        }
        
        // Border
        if let borderColor = colors.border {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 1
        } else {
            layer.borderColor = nil
            layer.borderWidth = 0
        }
    }
    
    func updateText(_ text: String?, buttonStyle: ButtonStyle) {
        let textStyle = ASAPP.styles.textStyles.getStyle(forButtonStyle: buttonStyle)
        let colors = ASAPP.styles.colors.getButtonColors(for: buttonStyle)

        updateText(text, textStyle: textStyle, colors: colors)
    }
}
