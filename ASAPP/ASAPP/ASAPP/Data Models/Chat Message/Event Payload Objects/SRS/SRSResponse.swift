//
//  SRSResponse.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class SRSResponse: NSObject {
    
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
    
    // MARK: Read-only Properties
    
    var messageText: String? {
        return itemList?.messageText ?? itemCarousel?.messageText
    }
    
    // MARK:- Init
    
    init(displayContent: Bool) {
        self.displayContent = displayContent
        super.init()
    }
}

// MARK:- JSON Handling

extension SRSResponse {
    
    class func fromEventJSON(_ eventJSON: [String : AnyObject]?) -> SRSResponse? {
        guard let eventJSON = eventJSON else {
            return nil
        }
        
        // All sorts of weird nesting logic here...
        
        let srsJSON = (eventJSON["businessLogic"] as? [String : Any]
            ?? eventJSON["BusinessLogic"] as? [String : Any]
            ?? eventJSON["ClientMessage"] as? [String : Any]
            ?? eventJSON["Echo"] as? [String : Any]
            ?? eventJSON)
        
        var displayContent = false
        if let displayContentValue = srsJSON["displayContent"] as? Bool {
            displayContent = displayContentValue
        }
        
        let response = SRSResponse(displayContent: displayContent)
        response.classification = srsJSON["classification"] as? String
        if srsJSON["contentType"] as? String == "carousel" {
            response.itemCarousel = SRSItemCarousel.instanceWithJSON(srsJSON["content"] as? [String : AnyObject])
        } else {
            response.itemList = SRSItemList.instanceWithJSON(srsJSON["content"] as? [String : AnyObject])
        }
        
        
        if ASAPP.isDemoContentEnabled() {
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
