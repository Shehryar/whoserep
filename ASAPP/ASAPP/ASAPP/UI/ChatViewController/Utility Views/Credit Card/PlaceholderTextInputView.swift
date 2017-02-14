//
//  PlaceholderTextInputView.swift
//  AnimationTestingGround
//
//  Created by Mitchell Morgan on 2/10/17.
//  Copyright © 2017 ASAPP, Inc. All rights reserved.
//

import UIKit

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

    var font: UIFont = Fonts.latoRegularFont(withSize: 15) {
        didSet {
            textField.font = font
            setNeedsLayout()
        }
    }
    
    var textColor: UIColor = UIColor(red:0.263, green:0.278, blue:0.310, alpha:1) {
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
    
    var placeholderFont: UIFont = Fonts.latoBoldFont(withSize: 12) {
        didSet {
            updatePlaceholderText()
            setNeedsLayout()
        }
    }
    
    var placeholderColor: UIColor = UIColor(red:0.663, green:0.682, blue:0.729, alpha:1) {
        didSet {
            updatePlaceholderText()
        }
    }
    
    // MARK: Underline
    
    var underlineColorDefault: UIColor = UIColor(red:0.663, green:0.682, blue:0.729, alpha:1) {
        didSet {
            updateUnderlineColor()
        }
    }
    
    var underlineColorHighlighted: UIColor? {
        didSet {
            updateUnderlineColor()
        }
    }
    
    var underlineColorError: UIColor?  {
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
    
    var placeholderMarginBottom: CGFloat = 8.0 {
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
    
    var keyboardType: UIKeyboardType {
        get { return textField.keyboardType }
        set { textField.keyboardType = newValue }
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
    
    var adjustsFontSizeToFitWidth: Bool {
        set { textField.adjustsFontSizeToFitWidth = newValue }
        get { return textField.adjustsFontSizeToFitWidth }
    }
    
    var minimumFontSize: CGFloat {
        set { textField.minimumFontSize = newValue }
        get { return textField.minimumFontSize }
    }
    
    // MARK: Enabled / Disabled
    
    var disabled: Bool = false {
        didSet {
            let subviewAlpha: CGFloat = disabled ? 0.3 : 1.0
            for subview in subviews {
                if subview.alpha > 0 {
                    subview.alpha = subviewAlpha
                }
            }
        }
    }
    
    /// Setting invalid shows the border error color until the text changes
    var invalid: Bool = false {
        didSet {
            updateUnderlineColor()
            updatePlaceholderText()
        }
    }
    
    // MARK: Highlighting / Selection
    
    fileprivate(set) var selected: Bool = false {
        didSet {
            updateUnderlineColor()
        }
    }
    
    fileprivate(set) var highlighted: Bool = false {
        didSet {
            updateUnderlineColor()
        }
    }
    
    // MARK: Internal UI properties
    
    fileprivate let placeholderLabel = UILabel()
    
    fileprivate let textField = UITextField()
    
    fileprivate let underlineView = UIView()
    
    // MARK: Internal Text Editing Properties
    
    fileprivate var previousTextFieldContent: String?
    
    fileprivate var previousSelection: UITextRange?
    
    // MARK:- Initialization
    
    func commonInit() {
        isExclusiveTouch = true
        
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.font = placeholderFont
        placeholderLabel.adjustsFontSizeToFitWidth = true
        placeholderLabel.minimumScaleFactor = 0.5
        addSubview(placeholderLabel)
    
        textField.textColor = textColor
        textField.font = font
        textField.tintColor = UIColor(red:0.180, green:0.627, blue:0.867, alpha:1)
        // Default text attributes with kern has weird bug that breaks side-scrolling
        textField.delegate = self
        addSubview(textField)

        updateUnderlineColor()
        addSubview(underlineView)
                
        textField.addTarget(self, action: #selector(PlaceholderTextInputView.textFieldTextDidChange), for: .editingChanged)
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
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrames()
        updateUnderlineColor()
    }
    
    private func getTextFieldIntrinsicHeight(for size: CGSize) -> CGFloat {
//        return ceil(textField.intrinsicContentSize.height)
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
        let underlineFrame = CGRect(x: left, y: underlineTop, width: width, height: underlineStrokeWidth)
        
        //
        // Labels
        //
        
        let textBottom = underlineTop - underlineMarginTop
        
        let textFieldHeight = getTextFieldIntrinsicHeight(for: bounds.size)
        let textFieldTop = textBottom - textFieldHeight
        let textFieldFrame = CGRect(x: left, y: textFieldTop, width: width, height: textFieldHeight)
        

        let placeholderTop: CGFloat
        let placeholderHeight = ceil(placeholderFont.lineHeight)
        
        
        // Align the placeholder over the textView
        if textIsEmpty {
            placeholderTop = textBottom - placeholderHeight
            
            // Or center on textView
            // placehoderTop = textFieldFrame.minY + floor((textFieldFrame.height - placeholderHeight) / 2.0)
        } else {
            placeholderTop = textFieldFrame.minY - placeholderMarginBottom - placeholderHeight
        }
        let placeholderFrame = CGRect(x: left, y: placeholderTop, width: width, height: placeholderHeight)
        
        // Update
        
        func updateBlock() {
            placeholderLabel.frame = placeholderFrame;
            textField.frame = textFieldFrame;
            underlineView.frame = underlineFrame
        }
        
        if (animated) {
            UIView.animate(withDuration: 0.15, animations: updateBlock);
        } else {
            updateBlock();
        }
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
        
        if (animated) {
            UIView.animate(withDuration: 0.2, animations: updateBlock)
        } else {
            updateBlock()
        }
    }
    
    // MARK: Updating Placeholder Text
    
    func updatePlaceholderText() {
        if let placeholderText = placeholderText {
            placeholderLabel.attributedText = NSAttributedString(string: placeholderText, attributes: [
                NSFontAttributeName : placeholderFont,
                NSForegroundColorAttributeName : placeholderColor,
                NSKernAttributeName : 0.8
                ])
        } else {
            placeholderLabel.attributedText = nil
        }
    }
    
    // Mark: Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if disabled {
            return
        }
        
        super.touchesBegan(touches, with: event)
        
        let touch:UITouch = touches.first!
        let point:CGPoint = touch.location(in: self)
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
        
        let touch:UITouch = touches.first!
        let point:CGPoint = touch.location(in: self)
        let touchInset:UIEdgeInsets = UIEdgeInsetsMake(-30, -30, -30, -30)
        let touchBounds:CGRect = UIEdgeInsetsInsetRect(self.bounds, touchInset)
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
    
    // MARK: First Responder
    
    override var canBecomeFirstResponder : Bool {
        if disabled {
            return false
        }
        
        if let shouldBeginEditing = shouldBeginEditing {
            return shouldBeginEditing()
        }
        return true
    }
    
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
    
    override func resignFirstResponder() -> Bool {
        selected = false
        
        onEndEditing?()
        
        return super.resignFirstResponder()
    }
    
    override var isFirstResponder : Bool {
        return super.isFirstResponder || textField.isFirstResponder
    }
    
    // MARK: Actions
    
    func tapGestureDidTap() {
        if disabled {
            return
        }
        
        if textEditingEnabled {
            textField.becomeFirstResponder()
        } else {
            _ = becomeFirstResponder()
        }
    }
}

// MARK: - UITextFieldDelegate

extension PlaceholderTextInputView: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        selected = true
        onBeginEditing?()
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        selected = false
        onEndEditing?()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturn?()
        return false
    }
    
    public func textFieldTextDidChange() {
        
        let text = textField.text ?? ""
        
        if let characterLimit = characterLimit {
            if text.characters.count > characterLimit {
                textField.text = previousTextFieldContent
                textField.selectedTextRange = previousSelection
                return
            }
        }
        
        if let allowedCharacterSet = allowedCharacterSet {
            let disallowedCharacterSet = allowedCharacterSet.inverted
            if let _ = text.rangeOfCharacter(from: disallowedCharacterSet) {
                textField.text = previousTextFieldContent
                textField.selectedTextRange = previousSelection
                return
            }
        }
        
        if (text.characters.count > 0) {
            updateFrames(false, animated: true)
        } else {
            updateFrames(true, animated: true)
        }
        
        // Assume no longer invalid
        invalid = false
        
        onTextChange?(text)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Note textField's current state before performing the change, in case reformatTextField wants to revert it
        previousTextFieldContent = textField.text;
        previousSelection = textField.selectedTextRange;
        
        return true
    }
}
