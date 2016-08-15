//
//  ActionableMessage.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/15/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ActionableMessage: NSObject {
    
    var message: String?
    
    var actions: [ActionableMessageAction]?
    
    var previousAction: ActionableMessageAction?
    
    init(message: String?, actions: [ActionableMessageAction]?, previousAction: ActionableMessageAction? = nil) {
        self.message = message
        self.actions = actions
        self.previousAction = previousAction
        super.init()
    }
}

// MARK:- JSONObject

extension ActionableMessage: JSONObject {
    class func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json else {
            return nil
        }
        
        var actions = [ActionableMessageAction]()
        if let actionsJSONArray = json["Actions"] as? [[String : AnyObject]] {
            for actionJSON in actionsJSONArray {
                if let action = ActionableMessageAction.instanceWithJSON(actionJSON) as? ActionableMessageAction {
                    actions.append(action)
                }
            }
        }
       
        return ActionableMessage(message: json["Message"] as? String, actions: actions)
    }
}

// MARK:- Sample Data

extension ActionableMessage {
    class func sample() -> ActionableMessage {
        return ActionableMessage(message: "What kind of internet issue are you experiencing?",
                                 actions: [
                                    ActionableMessageAction(name: "Connection", type: .Response),
                                    ActionableMessageAction(name: "Wi-Fi", type: .Response),
                                    ActionableMessageAction(name: "Something Else", type: .DeepLink),
                                    ActionableMessageAction(name: "Download Speed", type: .Response)
                                    ])
    }
}