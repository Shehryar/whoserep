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
    case ActionSheet = "actionSheet"
}

class SRSResponse: NSObject, JSONObject {
    var displayType: SRSResponseDisplayType
    var title: String?
    var classification: String?
    var itemList: SRSItemList?
    
    var immediateAction: SRSButtonItem? {
        return itemList?.immediateActionButtonItem
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
        if let displayContent = json["displayContent"] as? Bool {
            if displayContent {
                type = .Inline
            }
        }
        
        let response = SRSResponse(displayType: type)
        response.title = json["title"] as? String
        response.classification = json["classification"] as? String
        response.itemList = SRSItemList.instanceWithJSON(json["content"] as? [String : AnyObject]) as? SRSItemList
        
        
        // MITCH MITCH MITCH TEST TEST TESTING
        if let classification = response.classification {
            if classification.lowercaseString == "bpp" {
                if let buttonItems = response.itemList?.buttonItems {
                    for buttonItem in buttonItems {
                        if buttonItem.deepLink?.lowercaseString == "payment" {
                            buttonItem.isAutoSelect = true
                            response.displayType = .ActionSheet
                        }
                    }
                }
            }
        }
        
        return response
    }
}
