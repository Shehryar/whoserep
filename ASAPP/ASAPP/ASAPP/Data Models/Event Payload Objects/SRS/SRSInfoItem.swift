//
//  SRSInfoItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

enum SRSInfoItemOrientation {
    case vertical
    case horizontal
}

class SRSInfoItem: NSObject, JSONObject {
    
    var label: String
    var value: String
    var valueColor: UIColor?
    var iconName: String?
    var orientation: SRSInfoItemOrientation = .vertical
    
    init(label: String, value: String, valueColor: UIColor?, iconName: String?, orientation: SRSInfoItemOrientation? = nil) {
        self.label = label
        self.value = value
        self.valueColor = valueColor
        self.iconName = iconName
        if let orientation = orientation {
            self.orientation = orientation
        }
        super.init()
    }
    
    // MARK: JSONObject
    
    class func instanceWithJSON(_ json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json,
            let label = json["label"] as? String,
            let value = json["value"] as? String else {
                return nil
        }
        let valueColorHexString = json["valueColor"] as? String
        let valueColor = UIColor.colorFromHex(hex: valueColorHexString)
            
        return SRSInfoItem(label: label,
                           value: value,
                           valueColor: valueColor,
                           iconName: json["icon"] as? String)
    }
}
