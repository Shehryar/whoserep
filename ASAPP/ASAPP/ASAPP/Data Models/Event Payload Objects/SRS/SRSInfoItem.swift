//
//  SRSInfoItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

enum SRSInfoItemOrientation {
    case Vertical
    case Horizontal
}

class SRSInfoItem: NSObject, JSONObject {
    
    var label: String
    var value: String
    var iconName: String?
    var orientation: SRSInfoItemOrientation = .Vertical
    
    init(label: String, value: String, iconName: String?, orientation: SRSInfoItemOrientation? = nil) {
        self.label = label
        self.value = value
        self.iconName = iconName
        if let orientation = orientation {
            self.orientation = orientation
        }
        super.init()
    }
    
    // MARK: JSONObject
    
    class func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json,
            let label = json["label"] as? String,
            let value = json["value"] as? String else {
                return nil
        }
    
        return SRSInfoItem(label: label, value: value, iconName: json["icon"] as? String)
    }
}
