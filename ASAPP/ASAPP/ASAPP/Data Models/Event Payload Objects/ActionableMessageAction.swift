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
    
    var deepLinkURL: NSURL? // Temporary; will be changed later
    
    init(name: String?, type: ActionableMessageActionType, deepLinkURL: NSURL? = nil) {
        self.name = name
        self.type = type
        self.deepLinkURL = deepLinkURL
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
                             type: type)
    }
}
