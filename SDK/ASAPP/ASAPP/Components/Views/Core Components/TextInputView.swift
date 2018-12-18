//
//  TextInputView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TextInputView: BaseComponentView, InvalidatableInput {

    let textInputView = PlaceholderTextInputView()
    let errorLabel = UILabel()
    let calendarIcon = UIImageView()
    
    lazy var errorIcon: UIImageView = {
        return UIImageView(image: ComponentIcon.getImage(.notificationAlert)?.tinted(UIColor.ASAPP.errorRed))
    }()
    
    lazy var calendarIconOriginal: UIImage? = {
        return ComponentIcon.getImage(.timeCalendar)
    }()
    
    var isInvalid: Bool = false {
        didSet {
            textInputView.invalid = isInvalid
        }
    }
    
    private var pickerOptions: [PickerOption] = []
    private var selectedDateFormat: String?
    
    private var errorLabelHeight: CGFloat {
        let width = bounds.inset(by: component?.style.padding ?? .zero).width
        let errorLabelSize = errorLabel.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        return errorLabelSize.height
    }
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            textInputView.text = nil
            textInputView.placeholderText = nil
            
            if let textInputItem = textInputItem {
                if let value = textInputItem.value as? NSNumber {
                    let formatter = NumberFormatter()
                    formatter.minimumFractionDigits = 0
                    formatter.maximumFractionDigits = 2
                    textInputView.text = formatter.string(from: value)
                } else {
                    textInputView.text = textInputItem.value as? String
                }
                
                textInputView.placeholderText = textInputItem.placeholder
                textInputView.textColor = textInputItem.style.color ?? ASAPP.styles.colors.dark
                textInputView.font = ASAPP.styles.textStyles.style(for: textInputItem.style.textType).font
                textInputView.underlineColorDefault = ASAPP.styles.colors.controlSecondary
                textInputView.underlineColorHighlighted = ASAPP.styles.colors.dark
                textInputView.underlineStrokeWidth = 1
                textInputView.tintColor = ASAPP.styles.colors.controlTint
                textInputView.autocorrectionType = textInputItem.autocorrectionType
                textInputView.autocapitalizationType = textInputItem.autocapitalizationType
                textInputView.isSecureTextEntry = textInputItem.isSecure
                textInputView.characterLimit = textInputItem.maxLength
                textInputView.isRequired = textInputItem.isRequired ?? false
                
                textInputView.inputControlType = textInputItem.inputControlType
                if case let .datePicker(config) = textInputItem.inputControlType {
                    textInputView.onBeginEditing = { [weak self] in
                        self?.setDateInputView(config)
                    }
                    calendarIcon.isHidden = false
                }
            }
        }
    }
    
    var textInputItem: TextInputItem? {
        return component as? TextInputItem
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        textInputView.onTextChange = { [weak self] (text) in
            self?.component?.value = text
            self?.clearError()
        }
        addSubview(textInputView)
        
        errorLabel.isHidden = true
        addSubview(errorLabel)
        
        errorIcon.isHidden = true
        addSubview(errorIcon)
        
        calendarIcon.isHidden = true
        addSubview(calendarIcon)
        
        isAccessibilityElement = false
        accessibilityElements = [textInputView, errorLabel]
    }
    
    // MARK: Layout
    
    private func bottomPaddingWithError(_ padding: UIEdgeInsets) -> CGFloat {
        return errorLabel.numberOfVisibleLines > 1
            ? errorLabelHeight + max(padding.bottom, errorLabel.font.lineHeight) - errorLabel.font.lineHeight
            : max(padding.bottom, errorLabelHeight)
    }
    
    override func updateFrames() {
        let errorIconSize = CGSize(width: 20, height: 20)
        
        var padding = component?.style.padding ?? .zero
        padding.bottom = bottomPaddingWithError(padding)
        
        textInputView.contentInset.right = errorIcon.isHidden ? 0 : errorIconSize.width
        textInputView.frame = bounds.inset(by: padding)
        
        let errorLabelSize = errorLabel.sizeThatFits(CGSize(width: textInputView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        errorLabel.frame = CGRect(x: textInputView.frame.minX, y: textInputView.frame.maxY - textInputView.underlineMarginTop, width: errorLabelSize.width, height: errorLabelSize.height)
        
        let errorIconLeft = textInputView.frame.maxX - errorIconSize.width
        let errorIconTop = errorLabel.frame.minY - 5 - errorIconSize.height
        errorIcon.frame = CGRect(x: errorIconLeft, y: errorIconTop, width: errorIconSize.width, height: errorIconSize.height)
        
        guard errorIcon.isHidden, !calendarIcon.isHidden else {
            return
        }
        
        let calendarIconSize = CGSize(width: 16, height: 16)
        let calendarIconLeft = textInputView.frame.maxX - calendarIconSize.width
        let calendarIconTop = textInputView.frame.maxY - textInputView.underlineMarginTop - 8 - calendarIconSize.height
        calendarIcon.frame = CGRect(x: calendarIconLeft, y: calendarIconTop, width: calendarIconSize.width, height: calendarIconSize.height)
        let alpha: CGFloat = textInputView.isFirstResponder || !(textInputView.text?.isEmpty ?? true) ? 0.85 : 0.4
        calendarIcon.image = calendarIconOriginal?.tinted(ASAPP.styles.colors.dark, alpha: alpha)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let component = component else {
            return .zero
        }
        let padding = component.style.padding
        let bottom = bottomPaddingWithError(padding)
        
        let fitToWidth = max(0, (size.width > 0 ? size.width : CGFloat.greatestFiniteMagnitude) - padding.left - padding.right)
        let fitToHeight = max(0, (size.height > 0 ? size.height : CGFloat.greatestFiniteMagnitude) - padding.top - padding.bottom)
        guard fitToWidth > 0 && fitToHeight > 0 else {
            return .zero
        }
        
        let fittedInputSize = textInputView.sizeThatFits(CGSize(width: fitToWidth, height: fitToHeight))
        guard fittedInputSize.width > 0 && fittedInputSize.height > 0 else {
            return .zero
        }
        
        let fittedWidth = min(fitToWidth, fittedInputSize.width + padding.left + padding.right)
        let fittedHeight = min(fitToHeight - padding.bottom, fittedInputSize.height + padding.top) + bottom
        
        return CGSize(width: fittedWidth, height: fittedHeight)
    }
}

// MARK: - Date Picker

extension TextInputView: UIPickerViewDelegate, UIPickerViewDataSource {
    private func getSelectedDate(_ config: DatePickerConfig) -> Date? {
        return Date(iso8601DateString: textInputItem?.value as? String)
            ?? (config.maxDate == nil ? config.minDate : nil)
            ?? (config.minDate == nil ? config.maxDate : nil)
    }
    
    func setDateInputView(_ config: DatePickerConfig) {
        selectedDateFormat = config.selectedDateFormat
        
        let inputView: UIView
        if let disabledDates = config.disabledDates, !disabledDates.isEmpty {
            let picker = UIPickerView()
            picker.dataSource = self
            pickerOptions = config.getPickerOptions()
            if let selected = getSelectedDate(config) ?? pickerOptions.first?.value as? Date,
               let index = pickerOptions.index(where: { $0.value as? Date == selected }) {
                picker.selectRow(index, inComponent: 0, animated: false)
            }
            picker.delegate = self
            inputView = picker
        } else {
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.minimumDate = config.minDate
            datePicker.maximumDate = config.maxDate
            if let selected = getSelectedDate(config) {
                datePicker.setDate(selected, animated: false)
            }
            inputView = datePicker
        }
        
        textInputView.inputView = inputView
        textInputView.inputToolbar = UIToolbar.createDefaultDoneBar(target: self, action: #selector(doneSelectingDate))
        updateFrames()
    }
    
    @objc func doneSelectingDate() {
        var selectedDate: Date?
        if let picker = textInputView.inputView as? UIPickerView {
            let index = picker.selectedRow(inComponent: 0)
            let option = pickerOptions[index]
            selectedDate = (option.value as? Date)
        } else if let datePicker = textInputView.inputView as? UIDatePicker {
            selectedDate = datePicker.date
        }
        textInputView.text = selectedDate?.asString(with: selectedDateFormat)
        textInputItem?.value = selectedDate?.asISO8601DateString
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.textInputView.updateFrames()
        }
        textInputView.inputView = nil
        textInputView.inputToolbar = nil
        textInputView.reloadInputViews()
        textInputView.resignFirstResponder()
        updateFrames()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[row].text
    }
}
