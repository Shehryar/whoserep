//
//  SRSResponse.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class SRSResponse: NSObject, JSONObject {
    var title: String?
    var classification: String?
    
    var itemList: SRSItemList?
    var itemCarousel: SRSItemCarousel?
    
    var buttonItems: [SRSButtonItem]? {
        return itemList?.buttonItems ?? itemCarousel?.buttonItems
    }
    
    var immediateAction: SRSButtonItem? {
        return itemList?.immediateActionButtonItem
    }
    
    var displayContent: Bool
    
    init(displayContent: Bool) {
        self.displayContent = displayContent
        super.init()
    }
    
    // MARK: JSONObject
    
    class func instanceWithJSON(_ json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json else {
                return nil
        }
        
        // This may be an action message, in which case the srs response is embedded under an additional key, "BusinessLogic"
        
        let srsJSON = json["businessLogic"] as? [String : Any] ?? json["BusinessLogic"] as? [String : Any] ?? json
    
        var displayContent = false
        if let displayContentValue = srsJSON["displayContent"] as? Bool {
            displayContent = displayContentValue
        }
        
        let response = SRSResponse(displayContent: displayContent)
        response.title = srsJSON["title"] as? String
        response.classification = srsJSON["classification"] as? String
        if srsJSON["contentType"] as? String == "carousel" {
            response.itemCarousel = SRSItemCarousel.instanceWithJSON(srsJSON["content"] as? [String : AnyObject]) as? SRSItemCarousel
        } else {
            response.itemList = SRSItemList.instanceWithJSON(srsJSON["content"] as? [String : AnyObject]) as? SRSItemList
        }
        
        
        if DEMO_CONTENT_ENABLED {
            if let classification = response.classification {
                if classification.lowercased() == "bpp" {
                    if let buttonItems = response.itemList?.buttonItems {
                        for buttonItem in buttonItems {
                            if buttonItem.deepLink?.lowercased() == "payment" {
                                buttonItem.isAutoSelect = true
                                response.displayContent = false
                            }
                        }
                    }
                }
            }
        }
        
        return response
    }
}
