//
//  SRSButtonItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

enum SRSButtonItemType: String {
    case Link = "LINK"
    case InAppLink = "_N/A_"
    case SRS = "AID"
}

class SRSButtonItem: NSObject, JSONObject {
    
    // MARK: Required Properties
    
    var title: String
    var type: SRSButtonItemType
    
    // MARK: Link Properties
    
    var deepLink: String?
    var deepLinkData: [String : AnyObject]?

    // MARK: SRS Properties
    
    var srsValue: String?
    
    // MARK:- Init
    
    init(title: String, type: SRSButtonItemType) {
        self.title = title
        self.type = type
        super.init()
    }
    
    // MARK: JSONObject
    
    class func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json,
            let title = json["label"] as? String else {
                return nil
        }
        
        guard let valueJSON = json["value"] as? [String : AnyObject],
            let typeString = valueJSON["type"] as? String,
            let type = SRSButtonItemType(rawValue: typeString) else {
                return nil
        }
        
        
        let button = SRSButtonItem(title: title, type: type)
        
        switch button.type {
        case .InAppLink, .Link:
            if let content = valueJSON["content"] as? [String : AnyObject] {
                button.deepLink = content["deepLink"] as? String
                button.deepLinkData = content["deepLinkData"] as? [String : AnyObject]
            }
            break
            
        case .SRS:
            button.srsValue = valueJSON["content"] as? String
            break
        }
        
        return button
    }
}
