//
//  ActionType.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/2/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum ActionType: String {
    case api            = "api"
    case componentView  = "componentView"
    case deepLink       = "deepLink"
    case finish         = "finish"
    case treewalk       = "treewalk"
    case web            = "web"
    
    // MARK: JSON Parsing
    
    static func from(_ value: Any?) -> ActionType? {
        guard let value = value as? String else {
            return nil
        }
        if let actionType = ActionType(rawValue: value) {
            return actionType
        }
        
        // Old Values
        switch value {
        case "LINK": return .deepLink
        case "AID": return .treewalk
        case "ACTION": return .api
//        case "APP_ACTION": return .action
        case "COMPONENT_VIEW": return .componentView
        default: return nil
        }
    }
}

// MARK:- Action Classes

extension ActionType {
    
    func getActionClass() -> Action.Type {
        switch self {
        case .api: return APIAction.self
        case .componentView: return ComponentViewAction.self
        case .deepLink: return DeepLinkAction.self
        case .finish: return FinishAction.self
        case .treewalk: return TreewalkAction.self
        case .web: return WebPageAction.self
        }
    }
}

// MARK:- AppAction

/*

enum AppAction: String {
    case ask = "ask"
    case addCreditCard = "addCreditCard"
    case leaveFeedback = "leaveFeedback"
}
 
*/


