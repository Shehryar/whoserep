//
//  ActionableMessageAction.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/15/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

enum ActionableMessageActionType: Int {
    case Response = 0
    case DeepLink = 1
}

class ActionableMessageAction: NSObject {
    
    var name: String?
    
    var type: ActionableMessageActionType = .Response
    
    init(name: String?, type: ActionableMessageActionType) {
        self.name = name
        self.type = type
        super.init()
    }
}

extension ActionableMessageAction: JSONObject {
    static func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json else {
            return nil
        }
        
        guard let typeInt = json["Type"] as? Int,
            let type = ActionableMessageActionType(rawValue: typeInt) else {
                return nil
        }
        
        return ActionableMessageAction(name: json["Name"] as? String, type: type)
    }
}
