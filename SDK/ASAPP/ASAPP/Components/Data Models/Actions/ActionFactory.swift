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
        case content = "content"
        case type = "type"
    }
    
    static func action(with json: Any?) -> Action? {
        guard let json = json as? [String : Any] else {
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
        
        return type.getActionClass().init(content: json[JSONKey.content.rawValue])
    }
}
