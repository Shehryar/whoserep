//
//  Action+LegacySRS.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

extension ActionFactory {
    
    enum LegacyActionType: String {
        case appAction = "APP_ACTION"
        case deepLink = "LINK"
        case treewalk = "AID"
        
        static func parse(_ value: Any?) -> LegacyActionType? {
            guard let value = value as? String else {
                return nil
            }
            return LegacyActionType(rawValue: value)
        }
    }
 
    static func legacyAction(with json: Any?) -> Action? {
        guard let json = json as? [String : Any],
            let valueJSON = json["value"] as? [String : Any] else {
                return nil
        }
        
        let typeString = valueJSON.string(for: "type")
        guard let type = LegacyActionType.parse(typeString) else {
            DebugLog.w(caller: self, "Action type not recognized: \(valueJSON)")
            return nil
        }
        
        switch type {
        case .appAction:
            // TODO
            break
            
        case .deepLink:
            if let content = valueJSON.jsonObject(for: "content"),
                let deepLink = content.string(for: "deepLink"),
                let data = content.jsonObject(for: "deepLinkData") {
                return DeepLinkAction(content: [
                    "name" : deepLink,
                    "data" : data
                    ])
            }
            break
            
        case .treewalk:
            if let classification = valueJSON.string(for: "content") {
                return TreewalkAction(content: [
                    "classification" : classification
                    ])
            }
            break
        }
        
        return nil
    }

}
