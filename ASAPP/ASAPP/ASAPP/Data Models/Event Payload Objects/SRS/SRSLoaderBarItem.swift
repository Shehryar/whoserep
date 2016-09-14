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

    // MARK: JSONObject
    
    class func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        var loaderItem =  SRSLoaderBarItem()
        if let json = json {
            if let finishedAt = json["finishedAt"] as? Double {
                loaderItem.loadingFinishedTime = NSDate(timeIntervalSince1970: finishedAt)
            }
        }
        
        return loaderItem
    }
}
