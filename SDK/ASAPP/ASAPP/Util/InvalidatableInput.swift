//
//  InvalidatableInput.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 10/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol InvalidatableInput: class {
    var isInvalid: Bool { get set }
    var errorLabel: UILabel { get }
    var errorIcon: UIImageView { get }
    var errorTextStyle: ASAPPTextStyle { get }
    
    func updateError(for errorMessage: String)
    func clearError()
}

/// :nodoc:
extension InvalidatableInput where Self: UIView & ComponentView {
    var errorTextStyle: ASAPPTextStyle {
        let errorDefault = ASAPP.styles.textStyles.error
        return ASAPPTextStyle(font: errorDefault.font, size: errorDefault.defaultSize - 5, letterSpacing: errorDefault.letterSpacing, color: errorDefault.color)
    }
    
    func updateError(for errorMessage: String) {
        errorLabel.numberOfLines = 0
        errorLabel.setAttributedText(errorMessage, textStyle: errorTextStyle)
        errorLabel.isHidden = false
        errorIcon.isHidden = false
        isInvalid = true
        self.setNeedsLayout()
    }
    
    func clearError() {
        errorLabel.isHidden = true
        errorIcon.isHidden = true
        isInvalid = false
        self.setNeedsLayout()
    }
}
