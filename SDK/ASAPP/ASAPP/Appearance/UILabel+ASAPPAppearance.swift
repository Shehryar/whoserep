//
//  UILabel+ASAPPAppearance.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

extension UILabel {
    
    func setAttributedText(_ text: String?,
                           textStyle: ASAPPTextStyle,
                           color: UIColor? = nil) {
        guard var text = text else {
            attributedText = nil
            return
        }
        
        if textStyle.uppercase {
            text = text.localizedUppercase
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
