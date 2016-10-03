//
//  SRSMapItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

enum SRSMapItemType {
    case tech
    case equipment
}

class SRSMapItem: NSObject, JSONObject {
    
    var imageType: SRSMapItemType = .tech
    
    // MARK: JSONObject
    
    class func instanceWithJSON(_ json: [String : AnyObject]?) -> JSONObject? {
        let mapItem = SRSMapItem()
        if let json = json,
            let imageTypeString = json["image_type"] as? String {
            switch imageTypeString {
            case "tech":
                mapItem.imageType = .tech
                break
                
            case "equipment":
                mapItem.imageType = .equipment
                break
                
            default: break
            }
        }
        
        return mapItem
    }
}
