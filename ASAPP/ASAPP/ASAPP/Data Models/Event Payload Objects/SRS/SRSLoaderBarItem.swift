//
//  SRSLoaderBarItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/12/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSLoaderBarItem: NSObject, JSONObject {
    
    var loadingFinishedTime: NSDate?
    
    override init() {
        super.init()
        
        self.loadingFinishedTime = NSDate(timeIntervalSinceNow: 10)
    }
    
    // MARK: JSONObject
    
    static func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        return SRSLoaderBarItem()
    }


}
