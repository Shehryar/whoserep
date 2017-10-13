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
    
    let action: Action
    
    let isAutoSelect: Bool
    
    init(title: String, action: Action, isAutoSelect: Bool = false) {
        self.title = title
        self.action = action
        self.isAutoSelect = isAutoSelect
        super.init()
    }
}

// MARK: - JSON Parsing

extension QuickReply {
    
    enum JSONKey: String {
        case title
        case action
        case isAutoSelect
    }
    
    class func fromJSON(_ json: Any?) -> QuickReply? {
        guard let json = json as? [String : Any] else {
            return nil
        }
        
        guard let title = json.string(for: JSONKey.title.rawValue) else {
            DebugLog.w(caller: self, "QuickReply missing required title: \(json)")
            return nil
        }
        
        guard let action = ActionFactory.action(with: json[JSONKey.action.rawValue]) else {
            DebugLog.w(caller: self, "QuickReply missing required action: \(json)")
            return nil
        }
        
        let isAutoSelect = json.bool(for: JSONKey.isAutoSelect.rawValue) ?? false
        
        return QuickReply(title: title, action: action, isAutoSelect: isAutoSelect)
    }
    
    class func arrayFromJSON(_ jsonArray: Any?) -> [QuickReply]? {
        guard let jsonArray = jsonArray as? [[String : Any]] else {
            return nil
        }
        
        var quickReplies = [QuickReply]()
        for quickReplyJSON in jsonArray {
            if let quickReply = QuickReply.fromJSON(quickReplyJSON) {
                quickReplies.append(quickReply)
            }
        }
        return quickReplies.isEmpty ? nil : quickReplies
    }
}
