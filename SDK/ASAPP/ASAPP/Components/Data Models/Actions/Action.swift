//
//  Action.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/10/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit


// MARK:- ActionType

enum ActionType: String {
    case link       = "LINK"
    case treewalk   = "AID"
    case api        = "ACTION"
    case action     = "APP_ACTION"
    case componentView = "COMPONENT_VIEW"
}

// MARK:- AppAction

enum AppAction: String {
    case Ask = "ask"
    case AddCreditCard = "addCreditCard"
    case LeaveFeedback = "leaveFeedback"
    case jsonView   = "json_view"
}

// MARK:- Action

class Action: NSObject {
    static let tag = "Action"
    
    let type: ActionType
    let name: String
    let context: [String : AnyObject]?
    
    var willExitASAPP: Bool {
        return type == .link
    }
    
    // MARK: Init
    
    init(type: ActionType, name: String, context: [String : AnyObject]?) {
        self.type = type
        self.name = name
        self.context = context
        super.init()
    }
}

// MARK:- Web Links

extension Action {
    
    func getWebLink() -> URL? {
        guard type == .link && name == "url",
            let urlString = context?["url"] as? String else {
                return nil
        }
        
        return URL(string: urlString)
    }
    
    func getAppAction() -> AppAction? {
        guard type == .action else {
            return nil
        }
        return AppAction(rawValue: name)
    }
    
    func getComponentViewAction() -> ComponentViewAction? {
        guard type == .componentView else {
            return nil
        }
        
        return ComponentViewAction(content: context)
    }
}

// MARK:- JSON Parsing

extension Action {
    
    class func fromJSON(_ json: [String : AnyObject]?) -> Action? {
        guard let json = json else { return nil }
        guard let typeString = json["type"] as? String else {
            DebugLog.i("Action: Missing type in Action")
            return nil
        }
        guard let type = ActionType(rawValue: typeString) else {
            DebugLog.i("Action: Unrecognized action type: \(typeString)")
            return nil
        }
        
        var name: String?
        var context: [String : AnyObject]?
        
        switch type {
        case .link:
            if let content = json["content"] as? [String : AnyObject] {
                name = content["deepLink"] as? String
                context = content["deepLinkData"] as? [String : AnyObject]
            }
            break
            
        case .treewalk:
            name = json["content"] as? String
            break
            
        case .api:
            if let content = json["content"] as? [String : AnyObject] {
                name = content["endpoint"] as? String
                context = content["endpointPayload"] as? [String : AnyObject]
            } else {
                name = json["content"] as? String
            }
            break
            
        case .action:
            if let content = json["content"] as? [String : AnyObject] {
                name = content["action"] as? String
                context = content["context"] as? [String : AnyObject]
                
                guard let actionName = name, let _ = AppAction(rawValue: actionName) else {
                    DebugLog.i("Action: Unknown app action with name: \(name)")
                    return nil
                }
            } else {
                name = json["content"] as? String
            }
            break
            
        case .componentView:
            if let content = json["content"] as? [String : AnyObject] {
                name = content["name"] as? String
                context = content
            }
            break
        }
        
        guard let actionName = name else {
            DebugLog.i("Action: Missing action name in json: \(json)")
            return nil
        }
       
        return Action(type: type, name: actionName, context: context)
    }
}
