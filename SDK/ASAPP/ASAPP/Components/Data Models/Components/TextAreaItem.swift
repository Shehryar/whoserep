//
//  TextAreaItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/12/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TextAreaItem: Component {
    
    // MARK: - JSON Keys
    
    enum JSONKey: String {
        case autocorrect
        case capitalize
        case numberOfLines
        case placeholder
        case maxLength
    }
    
    // MARK: - Defaults
    
    static let defaultAutocorrectionEnabled = true
    
    static let defaultCapitalizationType = CapitalizationType.none
    
    static let defaultNumberOfLines: Int = 3
    
    // MARK: - Properties
    
    let autocapitalizationType: UITextAutocapitalizationType
    
    let autocorrectionType: UITextAutocorrectionType
    
    let numberOfLines: Int
    
    let placeholder: String?
    
    let maxLength: Int?
    
    // MARK: - Component Properties
    
    override var viewClass: UIView.Type {
        return TextAreaView.self
    }
    
    // MARK: - Init
    
    required init?(id: String? = nil,
                   name: String? = nil,
                   value: Any? = nil,
                   isChecked: Bool? = nil,
                   style: ComponentStyle,
                   styles: [String : Any]? = nil,
                   content: [String : Any]? = nil) {
        
        let capitalizationType = CapitalizationType.from(content?.string(for: JSONKey.capitalize.rawValue))
            ?? TextAreaItem.defaultCapitalizationType
        self.autocapitalizationType = capitalizationType.type()
        
        let autocorrectionEnabled = content?.bool(for: JSONKey.autocorrect.rawValue)
            ?? TextAreaItem.defaultAutocorrectionEnabled
        self.autocorrectionType = autocorrectionEnabled ? .yes : .no
        
        self.numberOfLines = content?.int(for: JSONKey.numberOfLines.rawValue)
            ?? TextAreaItem.defaultNumberOfLines
        
        self.placeholder = content?.string(for: JSONKey.placeholder.rawValue)
        
        self.maxLength = content?.int(for: JSONKey.maxLength.rawValue) ?? nil
        
        super.init(id: id,
                   name: name,
                   value: value,
                   isChecked: isChecked,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
