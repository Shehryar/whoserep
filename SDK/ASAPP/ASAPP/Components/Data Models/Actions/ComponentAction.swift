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
    case finish = "finish"
    
    static func from(_ string: String?) -> ComponentActionType? {
        guard let string = string,
            let type = ComponentActionType(rawValue: string) else {
                return nil
        }
        return type
    }
}

class ComponentAction: NSObject {

    enum JSONKey: String {
        case content = "content"
        case data = "data"
        case inputFields = "inputFields"
        case requestPath = "requestPath"
        case requiredInputFields = "requiredInputFields"
        case type = "type"
    }
    
    // MARK:- Properties
    
    let type: ComponentActionType
    
    let requestPath: String?
    
    let data: [String : Any]?
    
    let dataInputFields: [String]?
    
    let requiredDataInputFields: [String]?
    
    init?(json: Any?) {
        guard let json = json as? [String : Any] else {
            return nil
        }
        
        guard let type = ComponentActionType.from(json.string(for: JSONKey.type.rawValue)) else {
            DebugLog.w(caller: ComponentAction.self, "Type is required: \(json)")
            return nil
        }
        self.type = type
        
        let content = json[JSONKey.content.rawValue] as? [String : Any]
        self.data = content?[JSONKey.data.rawValue] as? [String : Any]
        self.requestPath = content?.string(for: JSONKey.requestPath.rawValue)
        self.dataInputFields = content?.strings(for: JSONKey.inputFields.rawValue)
        self.requiredDataInputFields = content?.strings(for: JSONKey.requiredInputFields.rawValue)
        
        super.init()
    }
}
