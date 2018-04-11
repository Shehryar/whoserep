//
//  ComponentFactory.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK: - ComponentFactory

enum ComponentFactory {
    
    enum JSONKey: String {
        case content
        case id
        case name
        case styleClass = "class"
        case style
        case type
        case value
        case isChecked = "checked"
        case isRequired = "required"
    }

    static func component(with json: Any?, styles: [String: Any]?) -> Component? {
        guard let json = json as? [String: Any] else {
            return nil
        }
        
        guard let typeString = json.string(for: JSONKey.type.rawValue) else {
            DebugLog.w(caller: self, "Component json missing 'type': \(json)")
            return nil
        }
        
        guard let type = ComponentType(rawValue: typeString) else {
            DebugLog.w(caller: self, "Unknown Component Type [\(typeString)]: \(json)")
            return  nil
        }
        
        let id = json[JSONKey.id.rawValue] as? String
        let name = json.string(for: JSONKey.name.rawValue)
        let value = json[JSONKey.value.rawValue]
        let isChecked = json.bool(for: JSONKey.isChecked.rawValue)
        let isRequired = json.bool(for: JSONKey.isRequired.rawValue)
        let styleClass = json.string(for: JSONKey.styleClass.rawValue)
        let style = ComponentStyle.getStyle(from: json[JSONKey.style.rawValue],
                                            styleClass: styleClass,
                                            styles: styles)
        let content = json[JSONKey.content.rawValue] as? [String: Any]
        
        return type.getItemClass().init(id: id,
                                        name: name,
                                        value: value,
                                        isChecked: isChecked,
                                        isRequired: isRequired,
                                        style: style,
                                        styles: styles,
                                        content: content)
    }
}
