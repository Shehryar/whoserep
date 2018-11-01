//
//  ActionFactory.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/2/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum ActionFactory {
    
    enum JSONKey: String {
        case content
        case type
        case performImmediately
    }
    
    static func action(with json: Any?) -> Action? {
        guard let json = json as? [String: Any] else {
            return nil
        }
        
        guard let typeString = json.string(for: JSONKey.type.rawValue) else {
            DebugLog.w(caller: self, "Action type required: \(json)")
            return nil
        }
        
        guard let type = ActionType(rawValue: typeString) else {
            DebugLog.w(caller: self, "Action type not recognized: \(json)")
            return nil
        }
        
        let performImmediately = json.bool(for: JSONKey.performImmediately.rawValue) ?? false
        
        return type.getActionClass().init(content: json[JSONKey.content.rawValue], performImmediately: performImmediately)
    }
}
