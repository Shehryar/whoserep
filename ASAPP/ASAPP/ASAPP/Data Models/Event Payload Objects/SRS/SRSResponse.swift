//
//  SRSResponse.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

enum SRSResponseDisplayType: String {
    case Inline = "inline"
    case ActionSheet = "actionsheet"
}

class SRSResponse: NSObject, JSONObject {
    var displayType: SRSResponseDisplayType
    var title: String?
    var classification: String?
    var itemList: SRSItemList?
    
    var immediateAction: SRSButtonItem? {
        if let buttonItems = itemList?.buttonItems {
            if buttonItems.count == 1 {
                return buttonItems.first
            }
        }
        return nil
    }
    
    init(displayType: SRSResponseDisplayType) {
        self.displayType = displayType
        super.init()
    }
    
    // MARK: JSONObject
    
    class func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json else {
                return nil
        }
        
        var type = SRSResponseDisplayType.ActionSheet
        if let typeString = json["display"] as? String,
            let parsedType = SRSResponseDisplayType(rawValue: typeString)  {
            type = parsedType
        }
        
        let response = SRSResponse(displayType: type)
        response.title = json["title"] as? String
        response.classification = json["classification"] as? String
        response.itemList = SRSItemList.instanceWithJSON(json["content"] as? [String : AnyObject]) as? SRSItemList
        
        return response
    }
}
