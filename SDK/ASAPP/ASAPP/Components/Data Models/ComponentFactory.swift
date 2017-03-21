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
    
    static func component(for type: ComponentType,
                          with content: Any?,
                          id: String?,
                          style: ComponentStyle) -> Component? {
        
        switch type { // Maintain alphabetical order
        // Core Components
        case .button: return ButtonItem.make(with: content, id: id, style: style)
        case .icon: return IconItem.make(with: content, id: id, style: style)
        case .label: return LabelItem.make(with: content, id: id, style: style)
        case .progressBar: return ProgressBarItem.make(with: content, id: id, style: style)
        case .separator: return SeparatorItem.make(with: content, id: id, style: style)
            
        // Templates
        case .stackView: return StackViewItem.make(with: content, id: id, style: style)
        }
    }
    
    static func component(with json: Any?) -> Component? {
        guard let json = json as? [String : Any] else {
            return nil
        }
        
        guard let typeString = json["type"] as? String else {
            DebugLog.w(caller: self, "Component json missing 'type': \(json)")
            return nil
        }
        
        guard let type = ComponentType(rawValue: typeString) else {
            DebugLog.w(caller: self, "Unknown Component Type [\(typeString)]: \(json)")
            return  nil
        }
        
        let content = json["content"]
        let id = json["id"] as? String
        let style = ComponentStyle.fromJSON(json["style"])
        
        return component(for: type,
                         with: content,
                         id: id,
                         style: style)
    }
}
