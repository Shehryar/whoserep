//
//  SRSInfoItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class SRSInfoItem: NSObject, JSONObject {
    
    var label: String
    var value: String
    var iconName: String?
    
    init(label: String, value: String, iconName: String?) {
        self.label = label
        self.value = value
        self.iconName = iconName
        super.init()
    }
    
    // MARK: JSONObject
    
    static func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json,
            let label = json["label"] as? String,
            let value = json["value"] as? String else {
                return nil
        }
        
        return SRSInfoItem(label: label, value: value, iconName: json["icon"] as? String)
    }
}
