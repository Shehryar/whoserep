//
//  PlaceholderTextInputView.swift
//  AnimationTestingGround
//
//  Created by Mitchell Morgan on 2/10/17.
//  Copyright © 2017 ASAPP, Inc. All rights reserved.
//

import UIKit

enum InputControlType {
    case keyboard(UIKeyboardType)
    case datePicker(DatePickerConfig)
}

class PlaceholderTextInputView: UIView {
    // MARK: Actions
    
    var shouldBeginEditing: (() -> Bool)?
    var onBeginEditing: (() -> Void)?
    var onEndEditing: (() -> Void)?
    var onTextChange: ((_ text: String) -> Void)?
    var onReturn: (() -> Void)?
    
    // MARK: Text
    
    var text: String? {
        get { return textField.text }
        set {
            textField.text = newValue
            setNeedsLayout()
        }
    }
    
    var characterLimit: Int?
    
    var allowedCharacterSet: NSCharacterSet?
    
    var textEditingEnabled: Bool = true {
        didSet {
            textField.isEnabled = textEditingEnabled
        }
    }

    var font: UIFont = Fonts.default.regular.changingOnlySize(15) {
        didSet {
            textField.font = font
            setNeedsLayout()
        }
    }
    
    var textColor = ASAPP.styles.colors.dark {
        didSet {
            textField.textColor = textColor
        }
    }
    
    var isSecureTextEntry: Bool {
        get { return textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }
    
    // MARK: Placeholder
    
    var placeholderText: String? {
        didSet {
            updatePlaceholderText()
        }
    }
    
    var placeholderFont: UIFont = Fonts.default.bold.changingOnlySize(12) {
        didSet {
            updatePlaceholderText()
            setNeedsLayout()
        }
    }
    
    var placeholderColor = ASAPP.styles.colors.dark.withAlphaComponent(0.5) {
        didSet {
            updatePlaceholderText()
        }
    }
    
    // MARK: Underline
    
    var underlineColorDefault = ASAPP.styles.colors.dark.withAlphaComponent(0.15) {
        didSet {
            updateUnderlineColor()
        }
    }
    
    var underlineColorHighlighted: UIColor? {
        didSet {
            updateUnderlineColor()
        }
    }
    
    var underlineColorError: UIColor? = UIColor.ASAPP.errorRed {
        didSet {
            updateUnderlineColor()
        }
    }
    
    // MARK: Layout
    
    var contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var placeholderMarginBottom: CGFloat = 3.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var underlineMarginTop: CGFloat = 3.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var underlineStrokeWidth: CGFloat = UIScreen.main.scale > 1 ? 0.5 : 1 {
        didSet {
            setNeedsLayout()
        }
    }

    // MARK: Keyboard
    
    var inputControlType: InputControlType = .keyboard(.default) {
        didSet {
            if case let .keyboard(type) = inputControlType {
                textField.keyboardType = type
            }
        }
    }
    
    var autocapitalizationType: UITextAutocapitalizationType {
        get { return textField.autocapitalizationType }
        set { textField.autocapitalizationType = newValue }
    }
    
    var autocorrectionType: UITextAutocorrectionType {
        get { return textField.autocorrectionType }
        set { textField.autocorrectionType = newValue }
    }
    
    var returnKeyType: UIReturnKeyType {
        get { return textField.returnKeyType }
        set { textField.returnKeyType = newValue }
    }
    
    var clearButtonMode: UITextFieldViewMode {
        get { return textField.clearButtonMode }
        set { textField.clearButtonMode = newValue }
    }
    
    var inputToolbar: UIView? {
        didSet {
            textField.inputAccessoryView = inputToolbar
        }
    }
    
    override var inputView: UIView? {
        get { return textField.inputView }
        set { textField.inputView = newValue }
    }
    
    var adjustsFontSizeToFitWidth: Bool {
        set { textField.adjustsFontSizeToFitWidth = newValue }
        get { return textField.adjustsFontSizeToFitWidth }
    }
    
    var minimumFontSize: CGFloat {
        set { textField.minimumFontSize = newValue }
        get { return textField.minimumFontSize }
    }
    
    // MARK: Enabled / Disabled
    
    var disabled = false {
        didSet {
            let subviewAlpha: CGFloat = disabled ? 0.3 : 1.0
            for subview in subviews where subview.alpha > 0 {
                subview.alpha = subviewAlpha
            }
        }
    }
    
    // MARK: Required
    
    var isRequired = false {
        didSet {
            updatePlaceholderText()
        }
    }
    
    /// Setting invalid shows the border error color until the text changes
    var invalid: Bool = false {
        didSet {
            updateUnderlineColor()
            updatePlaceholderText()
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            textField.tintColor = tintColor
        }
    }
    
    // MARK: Highlighting / Selection
    
    private(set) var selected: Bool = false {
        didSet {
            updateUnderlineColor()
        }
    }
    
    private(set) var highlighted: Bool = false {
        didSet {
            updateUnderlineColor()
        }
    }
    
    // MARK: Internal UI properties
    
    let textField = UITextField()
    private let placeholderLabel = UILabel()
    private let underlineView = UIView()
    
    // MARK: Internal Text Editing Properties
    
    private var previousTextFieldContent: String?
    private var previousSelection: UITextRange?
    
    // MARK: - Initialization
    
    func commonInit() {
        isExclusiveTouch = true
        
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.font = placeholderFont
        placeholderLabel.adjustsFontSizeToFitWidth = true
        placeholderLabel.minimumScaleFactor = 0.5
        addSubview(placeholderLabel)
    
        textField.textColor = textColor
        textField.font = font
        textField.tintColor = UIColor(red: 0.180, green: 0.627, blue: 0.867, alpha: 1)
        textField.delegate = self
        addSubview(textField)

        updateUnderlineColor()
        addSubview(underlineView)
                
        textField.addTarget(self, action: #selector(PlaceholderTextInputView.textFieldTextDidChange), for: .editingChanged)
        
        isAccessibilityElement = false
        accessibilityElements = [textField]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    deinit {
        textField.delegate = nil
    }
    
    // MARK: Updating Color
    
    func updateUnderlineColor(animated: Bool = false) {
        func updateBlock() {
            var underlineColor: UIColor?
            if invalid {
                underlineColor = underlineColorError
            } else if textField.isEditing || highlighted || selected {
                underlineColor = underlineColorHighlighted
            }
    
            underlineView.layer.backgroundColor = (underlineColor ?? underlineColorDefault).cgColor
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: updateBlock)
        } else {
            updateBlock()
        }
    }
    
    // MARK: Updating Placeholder Text
    
    func updatePlaceholderText() {
        if var placeholderText = placeholderText {
            var plainPlaceholder = placeholderText
            let requiredSuffix = " *"
            if isRequired {
                if !placeholderText.hasSuffix(requiredSuffix) {
                    placeholderText.append(requiredSuffix)
                } else {
                    plainPlaceholder.removeLast(requiredSuffix.count)
                }
            } else {
                if placeholderText.hasSuffix(requiredSuffix) {
                    placeholderText.removeLast(requiredSuffix.count)
                    plainPlaceholder = placeholderText
                }
            }
            placeholderLabel.setAttributedText(placeholderText, textType: .detail1, color: placeholderColor)
            let prefix = isRequired ? ASAPPLocalizedString("Required: ") : ""
            textField.accessibilityLabel = "\(prefix)\(plainPlaceholder)"
        } else {
            placeholderLabel.attributedText = nil
            textField.accessibilityLabel = ASAPPLocalizedString("Text area")
        }
    }
}

// MARK: - Layout

extension PlaceholderTextInputView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrames()
        updateUnderlineColor()
    }
    
    private func getTextFieldIntrinsicHeight(for size: CGSize) -> CGFloat {
        return ceil(textField.sizeThatFits(CGSize(width: size.width, height: 0)).height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var height = contentInset.top + contentInset.bottom
        height += placeholderFont.lineHeight + placeholderMarginBottom
        height += underlineMarginTop + underlineStrokeWidth
        height += getTextFieldIntrinsicHeight(for: size)
        
        return CGSize(width: size.width, height: height)
    }
    
    func updateFrames(animated: Bool = false) {
        if let inputText = text {
            updateFrames(inputText.isEmpty, animated: animated)
        } else {
            updateFrames(true, animated: animated)
        }
    }
    
    func updateFrames(_ textIsEmpty: Bool, animated: Bool) {
        var left = contentInset.left
        var width = bounds.width - left - contentInset.right
        
        // Underline
        
        let underlineTop = bounds.height - contentInset.bottom - underlineStrokeWidth
        let underlineWidth = width + contentInset.left + contentInset.right
        let underlineFrame = CGRect(x: left, y: underlineTop, width: underlineWidth, height: underlineStrokeWidth)
        
        // Labels
        
        let textBottom = underlineTop - underlineMarginTop
        
        let textFieldHeight = getTextFieldIntrinsicHeight(for: bounds.size)
        let textFieldTop = textBottom - textFieldHeight
        let textFieldFrame = CGRect(x: left, y: textFieldTop, width: width, height: textFieldHeight)
        
        let placeholderTop: CGFloat
        let placeholderHeight = ceil(placeholderFont.lineHeight)
        
        // Align the placeholder over the textView
        if textIsEmpty {
            placeholderTop = textBottom - placeholderHeight - (textFieldHeight - placeholderHeight) / 2
        } else {
            placeholderTop = textFieldFrame.minY - placeholderMarginBottom - placeholderHeight
        }
        let placeholderFrame = CGRect(x: left, y: placeholderTop, width: width, height: placeholderHeight)
        
        // Update
        
        func updateBlock() {
            placeholderLabel.frame = placeholderFrame
            textField.frame = textFieldFrame
            underlineView.frame = underlineFrame
        }
        
        if animated {
            UIView.animate(withDuration: 0.15, animations: updateBlock)
        } else {
            updateBlock()
        }
    }
}

// MARK: - Touches

extension PlaceholderTextInputView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if disabled {
            return
        }
        
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first!
        let point = touch.location(in: self)
        if self.bounds.contains(point) {
            highlighted = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if highlighted {
            tapGestureDidTap()
        }
        highlighted = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let touch = touches.first!
        let point = touch.location(in: self)
        let touchInset = UIEdgeInsets(top: -30, left: -30, bottom: -30, right: -30)
        let touchBounds = UIEdgeInsetsInsetRect(self.bounds, touchInset)
        if !touchBounds.contains(point) {
            self.touchesCancelled(touches, with: event)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        super.touchesCancelled(touches!, with: event)
        highlighted = false
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event) {
            if hitView == textField {
                return textField.isEditing ? textField : self
            }
            return hitView
        }
        return nil
    }
}

// MARK: - First Responder

extension PlaceholderTextInputView {
    override var canBecomeFirstResponder: Bool {
        if disabled {
            return false
        }
        
        if let shouldBeginEditing = shouldBeginEditing {
            return shouldBeginEditing()
        }
        return true
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        if disabled {
            return false
        }
        
        if textEditingEnabled {
            return textField.becomeFirstResponder()
        }
        
        selected = true
        
        onBeginEditing?()
        
        return super.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        selected = false
        
        onEndEditing?()
        
        return textField.resignFirstResponder() && super.resignFirstResponder()
    }
    
    override var isFirstResponder: Bool {
        return super.isFirstResponder || textField.isFirstResponder
    }
    
    // MARK: Actions
    
    func tapGestureDidTap() {
        if disabled {
            return
        }
        
        if textEditingEnabled {
            textField.delegate = self
            textField.becomeFirstResponder()
        } else {
            becomeFirstResponder()
        }
    }
}

// MARK: - UITextFieldDelegate

extension PlaceholderTextInputView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selected = true
        onBeginEditing?()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        selected = false
        onEndEditing?()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturn?()
        return false
    }
    
    @objc func textFieldTextDidChange() {
        
        let text = textField.text ?? ""
        
        if let characterLimit = characterLimit {
            if text.count > characterLimit {
                textField.text = previousTextFieldContent
                textField.selectedTextRange = previousSelection
                return
            }
        }
        
        if let allowedCharacterSet = allowedCharacterSet {
            let disallowedCharacterSet = allowedCharacterSet.inverted
            if text.rangeOfCharacter(from: disallowedCharacterSet) != nil {
                textField.text = previousTextFieldContent
                textField.selectedTextRange = previousSelection
                return
            }
        }
        
        if text.count > 0 {
            updateFrames(false, animated: true)
        } else {
            updateFrames(true, animated: true)
        }
        
        // Assume no longer invalid
        invalid = false
        
        onTextChange?(text)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Note textField's current state before performing the change, in case reformatTextField wants to revert it
        previousTextFieldContent = textField.text
        previousSelection = textField.selectedTextRange
        
        return true
    }
}
