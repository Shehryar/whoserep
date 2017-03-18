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
                          with content: [String : AnyObject]?,
                          layout: ComponentLayout) -> Component? {
        
        switch type { // Maintain alphabetical order
        case .label: return LabelItem.make(with: content, layout: layout)
        case .stackView: return StackViewItem.make(with: content, layout: layout)
        }
    }
    
    static func component(with json: [String : AnyObject]?) -> Component? {
        guard let json = json else {
            return nil
        }
        
        guard let typeString = json["template_type"] as? String else {
            DebugLog.w(caller: self, "Component json missing 'type': \(json)")
            return nil
        }
        
        guard let type = ComponentType(rawValue: typeString) else {
            DebugLog.w(caller: self, "Unknown Component Type [\(typeString)]: \(json)")
            return  nil
        }
        
        guard let content = json["content"] as? [String : AnyObject] else {
            DebugLog.w(caller: self, "Component missing content: \(json)")
            return nil
        }
        
        return component(for: type, with: content)
    }
}
