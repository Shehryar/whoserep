//
//  DropdownItem.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 12/12/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation

class DropdownItem: Component {
    struct Option {
        let text: String
        let value: Any
    }
    
    // MARK: - JSON Keys
    
    enum JSONKey: String {
        case placeholder
        case options
    }
    
    // MARK: - Properties
    
    let placeholder: String?
    
    let options: [Option]
    
    override var viewClass: UIView.Type {
        return DropdownView.self
    }
    
    required init?(id: String? = nil,
                   name: String? = nil,
                   value: Any? = nil,
                   isChecked: Bool? = nil,
                   isRequired: Bool? = nil,
                   style: ComponentStyle,
                   styles: [String: Any]? = nil,
                   content: [String: Any]? = nil) {
        guard let dicts = content?.arrayOfDictionaries(for: JSONKey.options.rawValue) else {
            return nil
        }
        
        var optionsArray: [Option] = []
        for dict in dicts {
            guard let text = dict["text"] as? String,
                  let value = dict["value"] else {
                return nil
            }
            optionsArray.append(Option(text: text, value: value))
        }
        
        options = optionsArray
        placeholder = content?.string(for: JSONKey.placeholder.rawValue)
        
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
