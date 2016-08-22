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

class MessageAction: NSObject {
    
    var name: String?
    
    var type: ActionableMessageActionType = .Response
    
    var action: String?
    
    var userInfo: [String : AnyObject]?
    
    init(name: String?, type: ActionableMessageActionType, action: String?, userInfo: [String : AnyObject]?) {
        self.name = name
        self.type = type
        self.action = action
        self.userInfo = userInfo
        super.init()
    }
}

extension MessageAction: JSONObject {
    static func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json else {
            return nil
        }
        
        guard let typeInt = json["Type"] as? Int,
            let type = ActionableMessageActionType(rawValue: typeInt) else {
                return nil
        }
        
        return MessageAction(name: json["Name"] as? String,
                             type: type,
                             action: json["Action"] as? String,
                             userInfo: json["ActionInfo"] as? [String : AnyObject])
    }
}
