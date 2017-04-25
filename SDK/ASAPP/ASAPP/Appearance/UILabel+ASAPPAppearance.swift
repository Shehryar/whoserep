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
                           with textStyle: ASAPPTextStyle,
                           color: UIColor? = nil) {
        guard let text = text else {
            attributedText = nil
            return
        }
        
        attributedText = NSAttributedString(string: text, attributes: [
            NSFontAttributeName : textStyle.font,
            NSForegroundColorAttributeName : color ?? textStyle.color,
            NSKernAttributeName : textStyle.letterSpacing
            ])
    }
    
    func applyTextStyle(_ textStyle: ASAPPTextStyle, color: UIColor? = nil) {
        font = textStyle.font
        textColor = color ?? textStyle.color
    }
}
