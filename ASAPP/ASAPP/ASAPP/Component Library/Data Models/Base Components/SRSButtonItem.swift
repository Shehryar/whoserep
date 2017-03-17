//
//  SRSButtonItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class SRSButtonItem: NSObject {
    
    let title: String
    let action: Action
    var isAutoSelect: Bool
    
    // MARK: Init
    
    init(title: String, action: Action, isAutoSelect: Bool = false) {
        self.title = title
        self.action = action
        self.isAutoSelect = isAutoSelect
        super.init()
    }
}

// MARK:- JSON Parsing

extension SRSButtonItem {

    class func fromJSON(_ json: [String : AnyObject]?) -> SRSButtonItem? {
        guard let json = json else {
            return nil
        }
        guard let title = json["label"] as? String else {
            DebugLog.i("ButtonItem: Missing title in json: \(json)")
            return nil
        }
        guard let action = Action.fromJSON(json["value"] as? [String : AnyObject]) else {
            DebugLog.i("ButtonItem: Missing action in json: \(json)")
            return nil
        }
        
        let isAutoSelect = (json["isAutoSelect"] as? Bool) ?? false
        
        return SRSButtonItem(title: title,
                             action: action,
                             isAutoSelect: isAutoSelect)
    }
}


