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
        updateBackgroundColors(colors)
        
        guard var text = text else {
            setAttributedTitle(nil, for: [.normal, .highlighted, .disabled])
            return
        }
        
        switch textStyle.case {
        case .upper:
            text = text.localizedUppercase
        case .start:
            text = text.split(separator: " ").map({ (substring) in
                return String(substring).localizedCapitalized
            }).joined()
        case .original:
            break
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
    
    func updateBackgroundColors(_ colors: ASAPPButtonColors) {
        setBackgroundImage(UIImage.imageWithColor(colors.backgroundNormal), for: .normal)
        setBackgroundImage(UIImage.imageWithColor(colors.backgroundHighlighted), for: .highlighted)
        setBackgroundImage(UIImage.imageWithColor(colors.backgroundDisabled), for: .disabled)
        
        if let borderColor = colors.border {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 1
        } else {
            layer.borderColor = nil
            layer.borderWidth = 0
        }
    }
    
    func setTitleShadow(color: UIColor = ASAPP.styles.colors.textShadow, offset: CGSize = CGSize(width: 0, height: 1), radius: CGFloat = 3, opacity: Float) {
        titleLabel?.layer.shadowColor = color.cgColor
        titleLabel?.layer.shadowOffset = offset
        titleLabel?.layer.shadowRadius = radius
        titleLabel?.layer.shadowOpacity = opacity
    }
}
