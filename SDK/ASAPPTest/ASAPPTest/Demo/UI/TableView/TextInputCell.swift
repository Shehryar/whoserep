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
    
    var labelText: String? {
        set {
            textFieldLabel.text = newValue
            if hasLabelText {
                textField.textAlignment = .right
            } else {
                textField.textAlignment = .left
            }
            applyAppSettings()
            setNeedsLayout()
        }
        get {
            return textFieldLabel.text
        }
    }
    
    var hasLabelText: Bool {
        if let labelText = textFieldLabel.text, !labelText.isEmpty {
            return true
        }
        return false
    }
    
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
    
    let textFieldLabel = UILabel()
    
    let textField = UITextField()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        selectionStyle = .none
        
        contentView.addSubview(textFieldLabel)
        
        textField.text = ""
        textField.delegate = self
        textField.addTarget(self, action: #selector(TextInputCell.textFieldDidChange(_:)), for: .editingChanged)
        contentView.addSubview(textField)
    }
    
    deinit {
        onTextChange = nil
        textField.delegate = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        textFieldLabel.text = nil
        textField.text = nil
        textField.placeholder = nil
    }
    
    // MARK: Styling
    
    override func applyAppSettings() {
        super.applyAppSettings()
        
        if let appSettings = appSettings {
            textFieldLabel.font = appSettings.branding.fontFamily.regular.withSize(16)
            textFieldLabel.textColor = appSettings.branding.colors.foregroundColor
            
            if hasLabelText {
                textField.font = appSettings.branding.fontFamily.light.withSize(16)
            } else {
                textField.font = appSettings.branding.fontFamily.regular.withSize(16)
            }
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
                    NSForegroundColorAttributeName: appSettings.branding.colors.secondaryTextColor,
                    NSFontAttributeName: appSettings.branding.fontFamily.regular.withSize(16)
                    ])
            } else {
                textField.placeholder = placeholderText
            }
        } else {
            textField.attributedPlaceholder = nil
        }
    }
}

// MARK: - Layout + Sizing

extension TextInputCell {
    
    func getFramesThatFit(_ size: CGSize) -> (CGRect, CGRect) {
        let contentWidth = size.width - contentInset.left - contentInset.right
        
        var labelSize = textFieldLabel.sizeThatFits(CGSize(width: contentWidth / 2.0, height: 0))
        labelSize.width = ceil(labelSize.width)
        labelSize.height = ceil(labelSize.height)
      
        var textFieldLeft = contentInset.left
        if labelSize.width > 0 || labelSize.height > 0 {
            textFieldLeft = contentInset.left + labelSize.width + 12
        }
        let textFieldWidth = size.width - textFieldLeft - contentInset.right
        let textFieldHeight = ceil(textField.sizeThatFits(CGSize(width: textFieldWidth, height: 0)).height)
        
        let height = max(labelSize.height, textFieldHeight)
        
        let labelFrame = CGRect(x: contentInset.left, y: contentInset.top, width: labelSize.width, height: labelSize.height)
        let textFieldFrame = CGRect(x: textFieldLeft, y: contentInset.top, width: textFieldWidth, height: height)
        
        return (labelFrame, textFieldFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        let (labelFrame, textFieldFrame) = getFramesThatFit(bounds.size)
        textFieldLabel.frame = labelFrame
        textField.frame = textFieldFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (labelFrame, textFieldFrame) = getFramesThatFit(size)
        let height = max(labelFrame.maxY, textFieldFrame.maxY) + contentInset.bottom
        return CGSize(width: size.width, height: height)
    }
}

// MARK: - TextFieldDelegate

extension TextInputCell: UITextFieldDelegate {
    
    func textFieldDidChange(_ textField: UITextField) {
        onTextChange?(currentText)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.textField {
            onReturnKey?()
            if dismissKeyboardOnReturn {
                self.textField.resignFirstResponder()
            }
            return false
        }
        return true
    }
}

// MARK: - First Responder

extension TextInputCell {
    
    override var canBecomeFirstResponder: Bool {
        return textField.canBecomeFirstResponder
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    override var canResignFirstResponder: Bool {
        return textField.canResignFirstResponder
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
}
