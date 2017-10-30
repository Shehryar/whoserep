//
//  UITextView+ASAPPAppearance.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

extension UITextView {

    func applyTextStyle(_ textStyle: ASAPPTextStyle, color: UIColor?) {
        font = textStyle.font
        textColor = color ?? textStyle.color
    }
    
    func applyTextType(_ textType: TextType, color: UIColor?) {
        let textStyle = ASAPP.styles.textStyles.style(for: textType)
        applyTextStyle(textStyle, color: color)
    }
    
    func setAttributedText(_ text: String?,
                           textStyle: ASAPPTextStyle,
                           color: UIColor? = nil) {
        guard let text = text else {
            attributedText = nil
            return
        }
        
        attributedText = NSAttributedString(string: text, attributes: [
            .font: textStyle.font,
            .kern: textStyle.letterSpacing,
            .foregroundColor: color ?? textStyle.color
        ])
    }
    
    func setAttributedText(_ text: String?,
                           textType: TextType,
                           color: UIColor? = nil) {
        setAttributedText(text,
                          textStyle: ASAPP.styles.textStyles.style(for: textType),
                          color: color)
    }
    
    func updateFont(for textType: TextType) {
        font = ASAPP.styles.textStyles.style(for: textType).font
    }
}
