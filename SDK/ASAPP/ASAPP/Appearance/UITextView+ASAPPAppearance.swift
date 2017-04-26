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
    
    func updateFont(for textType: TextType) {
        font = ASAPP.styles.textStyles.style(for: textType).font
    }
}
