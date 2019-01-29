//
//  TextInputItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TextInputItem: Component {
    
    // MARK: - JSON Keys
    
    enum JSONKey: String {
        case autocorrect
        case capitalize
        case password
        case placeholder
        case textInputType
        case maxLength
        
        // date picker
        case selectedDateFormat
        case minDate
        case maxDate
        case disabledDates
    }
    
    // MARK: - Enums
    
    enum InputType: String {
        case email
        case date
        case decimal
        case text // Default
        case number
        case phone
        case url
        
        static func from(_ string: Any?) -> InputType? {
            guard let string = string as? String,
                let type = InputType(rawValue: string) else {
                    return nil
            }
            return type
        }
    }
    
    // MARK: - Defaults
    
    static let defaultAutocorrectionEnabled = true
    static let defaultCapitalizationType = CapitalizationType.none
    static let defaultInputType = InputType.text
    static let defaultIsSecure = false
    static let defaultSelectedDateFormat = "yyyy-MM-dd"
    
    // MARK: - Properties

    let autocapitalizationType: UITextAutocapitalizationType
    let autocorrectionType: UITextAutocorrectionType
    let isSecure: Bool
    let inputControlType: InputControlType
    let placeholder: String?
    let maxLength: Int?
    
    // MARK: - Component Properties
    
    override var viewClass: UIView.Type {
        return TextInputView.self
    }
    
    override var valueIsEmpty: Bool {
        return (value as? String)?.isEmpty ?? true
    }
    
    // MARK: - Init
    
    required init?(id: String? = nil,
                   name: String? = nil,
                   value: Any? = nil,
                   isChecked: Bool? = nil,
                   isRequired: Bool? = nil,
                   style: ComponentStyle,
                   styles: [String: Any]? = nil,
                   content: [String: Any]? = nil) {
        
        let capitalizationType = CapitalizationType.from(content?.string(for: JSONKey.capitalize.rawValue))
            ?? TextInputItem.defaultCapitalizationType
        self.autocapitalizationType = capitalizationType.type()
        
        let autocorrectionEnabled = content?.bool(for: JSONKey.autocorrect.rawValue)
            ?? TextInputItem.defaultAutocorrectionEnabled
        self.autocorrectionType = autocorrectionEnabled ? .yes : .no
        
        self.isSecure = content?.bool(for: JSONKey.password.rawValue)
            ?? TextInputItem.defaultIsSecure
        
        let inputType = InputType.from(content?.string(for: JSONKey.textInputType.rawValue))
            ?? TextInputItem.defaultInputType
        
        switch inputType {
        case .date:
            self.inputControlType = .datePicker(.from(content))
        case .decimal:
            self.inputControlType = .keyboard(.decimalPad)
        case .email:
            self.inputControlType = .keyboard(.emailAddress)
        case .number:
            self.inputControlType = .keyboard(.numberPad)
        case .phone:
            self.inputControlType = .keyboard(.phonePad)
        case .text:
            self.inputControlType = .keyboard(.default)
        case .url:
            self.inputControlType = .keyboard(.URL)
        }
        
        self.placeholder = content?.string(for: JSONKey.placeholder.rawValue)
            ?? (inputType == .date ? ASAPPLocalizedString("Choose a date") : nil)
        
        self.maxLength = content?.int(for: JSONKey.maxLength.rawValue) ?? nil
        
        super.init(id: id,
                   name: name,
                   value: value,
                   isChecked: isChecked,
                   isRequired: isRequired,
                   style: style,
                   styles: styles,
                   content: content)
    }
}