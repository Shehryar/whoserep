//
//  TextInputCheckmarkCell.swift
//  ASAPPTest
//
//  Created by Shehryar Hussain on 10/30/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

class TextInputCheckmarkCell: TableViewCell {
    
    var onTextFieldTapped: ((_ text: String) -> Void)?
    var onTextChange: ((_ text: String) -> Void)?
    
    var isChecked: Bool = false {
        didSet {
            checkmarkView.isHidden = !isChecked
        }
    }
    
    var checkmarkSize: CGFloat = 20 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var checkmarkMargin: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
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
    
    override var backgroundColor: UIColor? {
        didSet {
            updateCheckmark()
        }
    }
    
    override class var reuseId: String {
        return "TextInputCheckmarkCellReuseId"
    }
    
    let checkmarkView = UIImageView()
    let textField = UITextField()
    
    override func commonInit() {
        super.commonInit()
        configureSubviews()
    }
    
    deinit {
        checkmarkView.image = nil
        onTextChange = nil
        textField.delegate = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        textField.text = nil
        textField.placeholder = nil
        checkmarkView.image = nil
    }
    
    private func configureSubviews() {
        checkmarkView.image = UIImage(named: "icon-checkmark")
        checkmarkView.contentMode = .scaleAspectFit
        checkmarkView.clipsToBounds = true
        contentView.addSubview(checkmarkView)
        
        textField.text = ""
        textField.delegate = self
        textField.addTarget(self, action: #selector(TextInputCheckmarkCell.textFieldDidChange(_:)), for: .editingChanged)
        contentView.addSubview(textField)
        textField.clearButtonMode = .whileEditing
        textField.textAlignment = .left
    }
    
    // MARK: Styling
    
    override func applyAppSettings() {
        super.applyAppSettings()
        
        if let appSettings = appSettings {
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
                    NSFontAttributeName: appSettings.branding.fontFamily.regular.changingOnlySize(16)
                    ])
            } else {
                textField.placeholder = placeholderText
            }
        } else {
            textField.attributedPlaceholder = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (textFieldFrame, toggleFrame) = framesThatFit(bounds.size)
        textField.frame = textFieldFrame
        checkmarkView.frame = toggleFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (textFieldFrame, checkmarkFrame) = framesThatFit(size)
        let height = max(textFieldFrame.maxY, checkmarkFrame.maxY) + contentInset.bottom
        return CGSize(width: size.width, height: height)
    }
}

extension TextInputCheckmarkCell {
    
    func framesThatFit(_ size: CGSize) -> (CGRect, CGRect) {
        let checkmarkLeft = size.width - contentInset.right - checkmarkSize
        
        let textFieldLeft = contentInset.left

        let textFieldWidth = size.width - textFieldLeft - contentInset.right - checkmarkSize
        let textFieldHeight = ceil(textField.sizeThatFits(CGSize(width: textFieldWidth, height: 0)).height)
        
        let toggleTop = contentInset.top + max(0, floor((textFieldHeight - checkmarkSize) / 2.0))
        let toggleFrame = CGRect(x: checkmarkLeft, y: toggleTop, width: checkmarkSize, height: checkmarkSize)
        
        let height = max(toggleTop, textFieldHeight)
        let textFieldFrame = CGRect(x: textFieldLeft, y: contentInset.top, width: textFieldWidth, height: height)
        
        return (textFieldFrame, toggleFrame)
    }
    
    func updateCheckmark() {
        if let appSettings = appSettings {
            let color = (backgroundColor?.isDark() ?? false) ? .white : appSettings.branding.colors.accentColor
            checkmarkView.image = #imageLiteral(resourceName: "icon-checkmark").fillAlpha(color)
        }
    }
}

extension TextInputCheckmarkCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        onTextFieldTapped?(currentText)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        onTextChange?(currentText)
    }
}

// MARK: - First Responder

extension TextInputCheckmarkCell {
    
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
