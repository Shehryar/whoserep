//
//  LegacyActionType.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 6/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK: - LegacyActionType

enum LegacyActionType: String {
    case api = "ACTION"
    case appAction = "APP_ACTION"
    case componentView = "COMPONENT_VIEW"
    case deepLink = "LINK"
    case treewalk = "AID"
    
    // MARK: JSON Parsing
    
    static func from(_ value: Any?) -> LegacyActionType? {
        guard let value = value as? String else {
            return nil
        }
        return LegacyActionType(rawValue: value)
    }
}

// MARK: - LegacyAppAction

 enum LegacyAppAction: String {
    case ask
    case leaveFeedback
 }
 
