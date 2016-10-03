//
//  SRSFillerItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSFillerItem: NSObject, JSONObject {
    
    // MARK: JSONObject
    
    class func instanceWithJSON(_ json: [String : AnyObject]?) -> JSONObject? {
        return SRSFillerItem()
    }
}
