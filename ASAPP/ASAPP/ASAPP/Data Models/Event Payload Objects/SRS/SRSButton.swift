//
//  SRSButton.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class SRSButton: NSObject, JSONObject {
    var title: String
    var value: SRSButtonValue?
    
    init(title: String) {
        self.title = title
        super.init()
    }
    
    // MARK: JSONObject
    
    class func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json,
            let title = json["label"] as? String else {
                return nil
        }
        
        let button = SRSButton(title: title)
        button.value = SRSButtonValue.instanceWithJSON(json["value"] as? [String : AnyObject]) as? SRSButtonValue
        
        return button
    }
}

// MARK:- SRSButtonValue

enum SRSButtonValueType: String {
    case Link = "LINK"
    case InAppLink = "_N/A_"
    case SRS = "AID"
}

class SRSButtonValue: NSObject, JSONObject {
    var type: SRSButtonValueType
    var deepLink: String?
    var deepLinkData: [String : AnyObject]?
    var srsValue: String?
    
    init(type: SRSButtonValueType) {
        self.type = type
        super.init()
    }
    
    // MARK: JSONObject
    
    class func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json,
            let typeString = json["type"] as? String,
            let type = SRSButtonValueType(rawValue: typeString) else {
            return nil
        }
        
        let value = SRSButtonValue(type: type)
        switch type {
        case .Link:
            if let content = json["content"] as? [String : AnyObject] {
                value.deepLink = content["deepLink"] as? String
                value.deepLinkData = content["deepLinkData"] as? [String : AnyObject]
            }
            break
            
        case .InAppLink:
            if let content = json["content"] as? [String : AnyObject] {
                value.deepLink = content["deepLink"] as? String
                value.deepLinkData = content["deepLinkData"] as? [String : AnyObject]
            }
            break
            
        case .SRS:
            value.srsValue = json["content"] as? String
            break
        }
        
        return value
    }
}
