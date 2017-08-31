//
//  ComponentViewAction.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum ComponentViewDisplayStyle: String {
    case full
    case inset
    
    // MARK: JSON Parsing
    
    static let defaultValue = ComponentViewDisplayStyle.full
    
    static func from(_ value: Any?) -> ComponentViewDisplayStyle? {
        guard let stringValue = value as? String else {
            return nil
        }
        return ComponentViewDisplayStyle(rawValue: stringValue)
    }
}

class ComponentViewAction: Action {
    
    // MARK: Properties
    
    enum JSONKey: String {
        case displayStyle
        case name
    }

    let displayStyle: ComponentViewDisplayStyle
    
    let name: String
    
    // MARK: Init
    
    required init?(content: Any?) {
        guard let content = content as? [String : Any] else {
            return nil
        }
        
        guard let name = content.string(for: JSONKey.name.rawValue) else {
            DebugLog.w(caller: ComponentViewAction.self, "Name is required: \(content)")
            return nil
        }
        self.name = name
        self.displayStyle = ComponentViewDisplayStyle.from(content[JSONKey.displayStyle.rawValue])
            ?? ComponentViewDisplayStyle.defaultValue

        super.init(content: content)
    }
}
