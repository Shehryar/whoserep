//
//  COMTextInputCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/16/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class COMTextInputCell: UITableViewCell {
    
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
            if let placeholderText = placeholderText {
                textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [
                    .foregroundColor: ASAPP.styles.colors.textSecondary,
                    .font: ASAPP.styles.textStyles.body.font,
                    .kern: ASAPP.styles.textStyles.body.letterSpacing
                ])
            } else {
                textField.attributedPlaceholder = nil
            }
        }
    }
    
    let contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    
    class var reuseId: String {
        return "COMTextInputCellReuseId"
    }
    
    let textField = UITextField()
    
    // MARK: Init
    
    func commonInit() {
        selectionStyle = .none
        
        textField.text = ""
        textField.delegate = self
        textField.defaultTextAttributes = [
            NSAttributedStringKey.foregroundColor.rawValue: ASAPP.styles.colors.textPrimary,
            NSAttributedStringKey.font.rawValue: ASAPP.styles.textStyles.body.font,
            NSAttributedStringKey.kern.rawValue: ASAPP.styles.textStyles.body.letterSpacing
        ]
        textField.addTarget(self, action: #selector(COMTextInputCell.textFieldDidChange(_:)), for: .editingChanged)
        
        contentView.addSubview(textField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    deinit {
        onTextChange = nil
        textField.delegate = nil
    }
}

// MARK:- Layout + Sizing

extension COMTextInputCell {
    
    func getFrameThatFits(_ size: CGSize) -> CGRect {
        let contentWidth = size.width - contentInset.left - contentInset.right
        let height = ceil(textField.sizeThatFits(CGSize(width: contentWidth, height: 0)).height)
        let top = floor((size.height - height) / 2.0)
        
        return CGRect(x: contentInset.left, y: top, width: contentWidth, height: height)
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

extension COMTextInputCell: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
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

extension COMTextInputCell {
    
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
