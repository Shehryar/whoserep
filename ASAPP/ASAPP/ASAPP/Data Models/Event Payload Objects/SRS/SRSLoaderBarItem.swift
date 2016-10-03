//
//  SRSLoaderBarItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/12/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSLoaderBarItem: NSObject, JSONObject {
    
    var finishedText: String?

    // MARK: JSONObject
    
    class func instanceWithJSON(_ json: [String : AnyObject]?) -> JSONObject? {
        let loaderItem =  SRSLoaderBarItem()
        if let json = json {
            loaderItem.finishedText = json["finished_text"] as? String
        }
        
        return loaderItem
    }
}
