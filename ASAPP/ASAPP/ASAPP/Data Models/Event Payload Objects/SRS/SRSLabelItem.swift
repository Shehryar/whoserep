//
//  SRSLabelItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class SRSLabelItem: NSObject, JSONObject {
    
    var text: String
    
    init(text: String) {
        self.text = text
        super.init()
    }
    
    // MARK: JSONObject
    
    class func instanceWithJSON(_ json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json,
            let text = json["label"] as? String else {
                return nil
        }
    
        return SRSLabelItem(text: text)
    }
}
