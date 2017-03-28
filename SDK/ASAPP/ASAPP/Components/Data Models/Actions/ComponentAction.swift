//
//  ComponentAction.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum ComponentActionType: String {
    case api = "api"
    case componentView = "componentView"
    case finish = "finish"
    
    static func from(_ string: String?) -> ComponentActionType? {
        guard let string = string,
            let type = ComponentActionType(rawValue: string) else {
                return nil
        }
        return type
    }
    
    func getActionClass() -> ComponentAction.Type {
        switch self {
        case .api: return APIAction.self
        case .componentView: return ComponentViewAction.self
        case .finish: return FinishAction.self
        }
    }
}

class ComponentAction: NSObject {

    // MARK:- Properties
    
    required init?(content: Any?) {
        super.init()
    }
}

enum ComponentActionFactory {
    
    enum JSONKey: String {
        case content = "content"
        case type = "type"
    }
    
    static func action(with json: Any?) -> ComponentAction? {
        guard let json = json as? [String : Any] else {
            return nil
        }
        
        guard let typeString = json.string(for: JSONKey.type.rawValue) else {
            DebugLog.w(caller: self, "Action type required: \(json)")
            return nil
        }
        
        guard let type = ComponentActionType(rawValue: typeString) else {
            DebugLog.w(caller: self, "Action type required: \(json)")
            return nil
        }
        
        return type.getActionClass().init(content: json[JSONKey.content.rawValue])
    }
}


