//
//  QuickReply.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/28/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class QuickReply: NSObject {

    let title: String
    
    let action: ComponentAction
    
    let isAutoSelect: Bool
    
    init(title: String, action: ComponentAction, isAutoSelect: Bool = false) {
        self.title = title
        self.action = action
        self.isAutoSelect = isAutoSelect
        super.init()
    }
}

// MARK:- JSON Parsing

extension QuickReply {
    
    enum JSONKey: String {
        case title = "title"
        case action = "action"
        case isAutoSelect = "isAutoSelect"
    }
    
    class func fromJSON(_ json: Any?) -> QuickReply? {
        guard let json = json as? [String : Any] else {
            return nil
        }
        
        guard let title = json.string(for: JSONKey.title.rawValue) else {
            DebugLog.w(caller: self, "QuickReply missing required title: \(json)")
            return nil
        }
        
        guard let action = ComponentActionFactory.action(with: json[JSONKey.action.rawValue]) else {
            DebugLog.w(caller: self, "QuickReply missing required action: \(json)")
            return nil
        }
        
        let isAutoSelect = json.bool(for: JSONKey.isAutoSelect.rawValue) ?? false
        
        return QuickReply(title: title, action: action, isAutoSelect: isAutoSelect)
    }
}
