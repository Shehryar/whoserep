//
//  QuickReply.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/28/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class QuickReply {
    let title: String
    
    let action: Action
    
    let icon: IconItem?
    let isTransient: Bool
    
    init(title: String, action: Action, icon: IconItem?, isTransient: Bool = false) {
        self.title = title
        self.action = action
        self.icon = icon
        self.isTransient = isTransient
    }
}

extension QuickReply: Hashable {
    var hashValue: Int {
        return title.hashValue
    }
    
    static func == (lhs: QuickReply, rhs: QuickReply) -> Bool {
        return lhs.title == rhs.title
    }
}

// MARK: - JSON Parsing

extension QuickReply {
    
    enum JSONKey: String {
        case title
        case action
        case icon
        case isTransient
    }
    
    class func fromJSON(_ json: Any?) -> QuickReply? {
        guard let json = json as? [String: Any] else {
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
        
        var icon: IconItem?
        if let iconDict = json.jsonObject(for: JSONKey.icon.rawValue) {
            icon = ComponentFactory.component(with: iconDict.string(for: "name"), styles: nil) as? IconItem
        }
        
        let isTransient = json.bool(for: JSONKey.isTransient.rawValue) ?? false
        
        return QuickReply(title: title, action: action, icon: icon, isTransient: isTransient)
    }
    
    class func arrayFromJSON(_ jsonArray: Any?) -> [QuickReply]? {
        guard let jsonArray = jsonArray as? [[String: Any]] else {
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
