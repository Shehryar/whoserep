//
//  SRSLoaderBarItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/12/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSLoaderBarItem: NSObject, JSONObject {
    
    // MARK: JSONObject
    
    static func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        return SRSLoaderBarItem()
    }


}
