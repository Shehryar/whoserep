//
//  TextInputCell.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 2/24/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TextInputCell: TableViewCell {

    var onTextChange: ((_ text: String) -> Void)?
    
    var onReturnKey: (() -> Void)?
    
    var dismissKeyboardOnReturn: Bool = false
    
    var currentText: String {
        set {
            textField.text = newValue
        }
        get {
            return textField.text ?? ""
        }
    }

    var placeholderText: String? {
        didSet {
            updatePlaceholderText()
        }
    }
    
    override class var reuseId: String {
        return "TextInputCellReuseId"
    }
    
    let textField = UITextField()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        selectionStyle = .none
        
        textField.text = ""
        textField.delegate = self
        textField.addTarget(self, action: #selector(TextInputCell.textFieldDidChange(_:)), for: .editingChanged)
        contentView.addSubview(textField)
    }
    
    deinit {
        onTextChange = nil
        textField.delegate = nil
    }
    
    // MARK: Styling
    
    override func applyAppSettings() {
        super.applyAppSettings()
        
        if let appSettings = appSettings {
            textField.font = appSettings.branding.fonts.regularFont.withSize(16)
            textField.textColor = appSettings.branding.colors.foregroundColor
            textField.tintColor = appSettings.branding.colors.accentColor
            
            updatePlaceholderText()
        }
        
        setNeedsLayout()
    }
    
    func updatePlaceholderText() {
        if let placeholderText = placeholderText {
            if let appSettings = appSettings {
                textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [
                    NSForegroundColorAttributeName : appSettings.branding.colors.secondaryTextColor,
                    NSFontAttributeName : appSettings.branding.fonts.regularFont.withSize(16)
                    ])
            } else {
                textField.placeholder = placeholderText
            }
        } else {
            textField.attributedPlaceholder = nil
        }
    }
}

// MARK:- Layout + Sizing

extension TextInputCell {
    
    func getFrameThatFits(_ size: CGSize) -> CGRect {
        let contentWidth = size.width - contentInset.left - contentInset.right
        let height = ceil(textField.sizeThatFits(CGSize(width: contentWidth, height: 0)).height)
        return CGRect(x: contentInset.left, y: contentInset.top, width: contentWidth, height: height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        textField.frame = getFrameThatFits(bounds.size)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let textFieldFrame = getFrameThatFits(size)
        let height = textFieldFrame.maxY + contentInset.bottom
        return CGSize(width: size.width, height: height)
    }
}

// MARK:- TextFieldDelegate

extension TextInputCell: UITextFieldDelegate {
    
    func textFieldDidChange(_ textField: UITextField) {
        onTextChange?(currentText)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.textField {
            onReturnKey?()
            if dismissKeyboardOnReturn {
                _ = self.textField.resignFirstResponder()
            }
            return false
        }
        return true
    }
}

// MARK:- First Responder

extension TextInputCell {
    
    override var canBecomeFirstResponder: Bool {
        return textField.canBecomeFirstResponder
    }
    
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    override var canResignFirstResponder: Bool {
        return textField.canResignFirstResponder
    }
    
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
}
