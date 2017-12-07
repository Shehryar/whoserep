//
//  ActionType.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/2/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK: ActionType

enum ActionType: String {
    case api
    case componentView
    case deepLink
    case finish
    case http
    case treewalk
    case userLogin
    case web
    case unknown
    
    // MARK: JSON Parsing
    
    static func from(_ value: Any?) -> ActionType? {
        guard let value = value as? String else {
            return nil
        }
        return ActionType(rawValue: value)
    }
}

// MARK: - Action Classes

extension ActionType {
    
    func getActionClass() -> Action.Type {
        switch self {
        case .api: return APIAction.self
        case .componentView: return ComponentViewAction.self
        case .deepLink: return DeepLinkAction.self
        case .finish: return FinishAction.self
        case .http: return HTTPAction.self
        case .treewalk: return TreewalkAction.self
        case .userLogin: return UserLoginAction.self
        case .web: return WebPageAction.self
        case .unknown: return Action.self
        }
    }
}

// MARK: ActionType-based Action Extensions

extension Action {
    
    var type: ActionType {
        switch self {
        case is APIAction: return .api
        case is ComponentViewAction: return .componentView
        case is DeepLinkAction: return .deepLink
        case is FinishAction: return .finish
        case is HTTPAction: return .http
        case is TreewalkAction: return .treewalk
        case is UserLoginAction: return .userLogin
        case is WebPageAction: return .web
        default: return .unknown
        }
    }
    
    var willExitASAPP: Bool {
        switch self {
        case is DeepLinkAction,
             is UserLoginAction,
             is WebPageAction:
            return true
            
        case is APIAction,
             is ComponentViewAction,
             is HTTPAction,
             is TreewalkAction,
             is FinishAction:
            return false
         
        default: return false
        }
    }
    
    var performsUIBlockingNetworkRequest: Bool {
        switch self {
        case is APIAction,
             is HTTPAction,
             is TreewalkAction:
            return true
            
        case is ComponentViewAction,
             is DeepLinkAction,
             is FinishAction,
             is UserLoginAction,
             is WebPageAction:
            return false
            
        default: return false
        }
    }
}
