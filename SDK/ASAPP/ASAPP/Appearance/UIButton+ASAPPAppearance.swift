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
        
        // Border
        if let borderColor = colors.border {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 1
        } else {
            layer.borderColor = nil
            layer.borderWidth = 0
        }
        
        guard var text = text else {
            setAttributedTitle(nil, for: [.normal, .highlighted, .disabled])
            return
        }
        
        if textStyle.uppercase {
            text = text.localizedUppercase
        }
        
        // Text
        setAttributedTitle(NSAttributedString(string: text, attributes: [
            .font: textStyle.font,
            .foregroundColor: colors.textNormal,
            .kern: textStyle.letterSpacing
        ]), for: .normal)
        
        setAttributedTitle(NSAttributedString(string: text, attributes: [
            .font: textStyle.font,
            .foregroundColor: colors.textHighlighted,
            .kern: textStyle.letterSpacing
        ]), for: .highlighted)
        
        setAttributedTitle(NSAttributedString(string: text, attributes: [
            .font: textStyle.font,
            .foregroundColor: colors.textDisabled,
            .kern: textStyle.letterSpacing
        ]), for: .disabled)
    }
    
    func updateText(_ text: String?, buttonType: ButtonType) {
        let textStyle = ASAPP.styles.textStyles.getStyle(forButtonType: buttonType)
        let colors = ASAPP.styles.colors.getButtonColors(for: buttonType)

        updateText(text, textStyle: textStyle, colors: colors)
    }
}
