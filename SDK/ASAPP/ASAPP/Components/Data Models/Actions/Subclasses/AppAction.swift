//
//  AppAction.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// Note from August 2, 2017,
// This class should be removed as soon as Condor is transitioned to the newer API

class AppAction: Action {
    
    enum JSONKey: String {
        case action
        case metadata
    }
    
    enum AppActionType: String {
        case leaveFeedback
        
        static func parse(_ value: Any?) -> AppActionType? {
            guard let value = value as? String else {
                return nil
            }
            return AppActionType(rawValue: value)
        }
    }
    
    let appActionType: AppActionType
    
    let eventMetadata: EventMetadata
    
    required init?(content: Any?) {
        guard let contentDict = content as? [String : Any],
            let appActionType = AppActionType.parse(contentDict[JSONKey.action.rawValue]) else {
                DebugLog.d(caller: AppAction.self, "Unknown or missing type: \(content ?? "NIL content")")
                return nil
        }
        guard let metadata = contentDict[JSONKey.metadata.rawValue] as? EventMetadata else {
            DebugLog.d(caller: AppAction.self, "Missing event metadata: \(String(describing: content))")
            return nil
        }
        
        self.appActionType = appActionType
        self.eventMetadata = metadata
        super.init(content: content)
    }

}
