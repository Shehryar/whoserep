//
//  TextInputItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TextInputItem: Component {
    
    // MARK:- JSON Keys
    
    enum JSONKey: String {
        case autocorrect = "autocorrect"
        case capitalize = "capitalize"
        case password = "password"
        case placeholder = "placeholder"
        case textInputType = "textInputType"
    }
    
    // MARK:- Enums
    
    enum InputType: String {
        case email = "email"
        case decimal = "decimal"
        case text = "text" // Default
        case number = "number"
        case phone = "phone"
        case url = "url"
        
        func keyboardType() -> UIKeyboardType {
            switch self {
            case .email: return .emailAddress
            case .decimal: return .decimalPad
            case .text: return .default
            case .number: return .numberPad
            case .phone: return .phonePad
            case .url: return .URL
            }
        }
        
        static func from(_ string: Any?) -> InputType? {
            guard let string = string as? String,
                let type = InputType(rawValue: string) else {
                    return nil
            }
            return type
        }
    }
    
    // MARK:- Defaults
    
    static let defaultAutocorrectionEnabled = true
    
    static let defaultCapitalizationType = CapitalizationType.none
    
    static let defaultInputType = InputType.text
    
    static let defaultIsSecure = false
    
    // MARK:- Properties

    let autocapitalizationType: UITextAutocapitalizationType
    
    let autocorrectionType: UITextAutocorrectionType
    
    let isSecure: Bool
    
    let keyboardType: UIKeyboardType
    
    let placeholder: String?
    
    // MARK:- Component Properties
    
    override var viewClass: UIView.Type {
        return TextInputView.self
    }
    
    // MARK:- Init
    
    required init?(id: String? = nil,
                   name: String? = nil,
                   value: Any? = nil,
                   isChecked: Bool? = nil,
                   style: ComponentStyle,
                   styles: [String : Any]? = nil,
                   content: [String : Any]? = nil) {
        
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
        self.keyboardType = inputType.keyboardType()
        
        self.placeholder = content?.string(for: JSONKey.placeholder.rawValue)
        
        super.init(id: id,
                   name: name,
                   value: value,
                   isChecked: isChecked,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
