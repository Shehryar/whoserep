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
    
    var actions: [MessageAction]?
    
    var previousAction: MessageAction?
    
    init(message: String?, actions: [MessageAction]?, previousAction: MessageAction? = nil) {
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
        
        var actions = [MessageAction]()
        if let actionsJSONArray = json["Actions"] as? [[String : AnyObject]] {
            for actionJSON in actionsJSONArray {
                if let action = MessageAction.instanceWithJSON(actionJSON) as? MessageAction {
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
                                    MessageAction(name: "Connection", type: .Response),
                                    MessageAction(name: "Wi-Fi", type: .Response),
                                    MessageAction(name: "Download Speed", type: .Response),
                                    MessageAction(name: "Open Photos", type: .DeepLink, deepLinkURL: NSURL(string: "photos://"))
                                    ])
    }
}
