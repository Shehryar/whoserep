//
//  SRSMapItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

enum SRSMapItemType {
    case Tech
    case Equipment
}

class SRSMapItem: NSObject, JSONObject {
    
    var imageType: SRSMapItemType = .Tech
    
    // MARK: JSONObject
    
    class func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        let mapItem = SRSMapItem()
        if let json = json,
            let imageTypeString = json["image_type"] as? String {
            switch imageTypeString {
            case "tech":
                mapItem.imageType = .Tech
                break
                
            case "equipment":
                mapItem.imageType = .Equipment
                break
                
            default: break
            }
        }
        
        return mapItem
    }
}
