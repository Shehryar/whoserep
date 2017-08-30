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
        case apiAction = "ACTION"
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
 
    static func legacyAction(with json: Any?, buttonTitle: String, metadata: EventMetadata) -> Action? {
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
        case .apiAction:
            var endpoint: String?
            var endpointPayload: [String : Any]?
            if let endpointString = valueJSON.string(for: "content") {
                endpoint = endpointString
                endpointPayload = nil
            } else if let contentJSON = valueJSON.jsonObject(for: "content") {
                endpoint = contentJSON.string(for: "endpoint")
                endpointPayload = contentJSON.jsonObject(for: "endpointPayload")
            }
            
            if let endpoint = endpoint {
                let apiAction = APIAction(content: [
                    APIAction.JSONKey.requestPath.rawValue: "srs/\(endpoint)"
                    ])
                apiAction?.tempRequestTopLevelParams["Text"] = buttonTitle
                
                if let endpointPayload = endpointPayload {
                    apiAction?.tempRequestTopLevelParams["Payload"] = endpointPayload
                }
                return apiAction
            }
            
        case .appAction:
            if let content = valueJSON.jsonObject(for: "content"),
                let action = content.string(for: "action") {
                return AppAction(content: [
                    AppAction.JSONKey.action.rawValue: action,
                    AppAction.JSONKey.metadata.rawValue: metadata
                    ])
            }
            
        case .deepLink:
            if let content = valueJSON.jsonObject(for: "content"),
                let deepLink = content.string(for: "deepLink"),
                let data = content.jsonObject(for: "deepLinkData") {
                return DeepLinkAction(content: [
                    "name": deepLink,
                    "data": data
                ])
            }
            
        case .treewalk:
            if let classification = valueJSON.string(for: "content") {
                return TreewalkAction(content: [
                    "classification": classification
                ])
            }
        }
        
        return nil
    }
}
