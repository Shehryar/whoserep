//
//  ComponentViewAction.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum ComponentViewDisplayStyle: String {
    case full = "full"
    case inset = "inset"
}

class ComponentViewAction: Action {

    // MARK: JSON Keys
    
    enum JSONKey: String {
        case displayStyle = "displayStyle"
        case name = "name"
    }
    
    // MARK: Defaults
    
    static let defaultDisplayStyle = ComponentViewDisplayStyle.full
    
    // MARK: Properties

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
        
        if let displayStyleString = content.string(for: JSONKey.displayStyle.rawValue),
            let displayStyle = ComponentViewDisplayStyle(rawValue: displayStyleString) {
            self.displayStyle = displayStyle
        } else {
            self.displayStyle = ComponentViewAction.defaultDisplayStyle
        }
        
        super.init(content: content)
    }
}
