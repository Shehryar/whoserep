//
//  SRSSeparatorItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSSeparatorItem: NSObject, JSONObject {

    // MARK: JSONObject
    
    static func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        return SRSSeparatorItem()
    }
}
