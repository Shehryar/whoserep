//
//  ComponentFactory.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- ComponentFactory

enum ComponentFactory {
    
    enum JSONKey: String {
        case content = "content"
        case id = "id"
        case name = "name"
        case styleClass = "class"
        case style = "style"
        case type = "type"
        case value = "value"
    }

    static func component(with json: Any?, styles: [String : Any]?) -> Component? {
        guard let json = json as? [String : Any] else {
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
        let styleClass = json.string(for: JSONKey.styleClass.rawValue)
        let style = ComponentStyle.getStyle(from: json[JSONKey.style.rawValue],
                                            styleClass: styleClass,
                                            styles: styles)
        let content = json[JSONKey.content.rawValue] as? [String : Any]
        
        return type.getItemClass().init(id: id,
                                        name: name,
                                        value: value,
                                        style: style,
                                        styles: styles,
                                        content: content)
    }
}
