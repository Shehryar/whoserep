//
//  SRSLabel.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class SRSLabel: NSObject, JSONObject {
    var text: String?
    
    // MARK: JSONObject
    
    class func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json,
            let title = json["label"] as? String else {
                return nil
        }
        
        let label = SRSLabel()
        label.text = title
        
        return label
    }
}
