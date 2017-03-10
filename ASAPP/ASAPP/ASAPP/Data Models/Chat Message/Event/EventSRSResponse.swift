//
//  EventSRSResponse.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class EventSRSResponse: NSObject {
    
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

extension EventSRSResponse {
    
    class func fromEventJSON(_ eventJSON: [String : AnyObject]?) -> EventSRSResponse? {
        guard let eventJSON = eventJSON else {
            return nil
        }
        
        // All sorts of weird nesting logic here...
        let srsJSON = (eventJSON["businessLogic"] as? [String : AnyObject]
            ?? eventJSON["BusinessLogic"] as? [String : AnyObject]
            ?? eventJSON["ClientMessage"] as? [String : AnyObject]
            ?? eventJSON)
        
        var displayContent = false
        if let displayContentValue = srsJSON["displayContent"] as? Bool {
            displayContent = displayContentValue
        }
        
        let response = EventSRSResponse(displayContent: displayContent)
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
                            if buttonItem.action.type == .link && buttonItem.action.name.lowercased() == "payment" {
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
