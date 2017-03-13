//
//  TitleButtonContainer.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TitleButtonContainer: NSObject {

    let title: String
    let button: SRSButtonItem?
    let content: AnyObject
    
    init(title: String, button: SRSButtonItem?, content: AnyObject) {
        self.title = title
        self.button = button
        super.init()
    }
}

// MARK:- JSON Parsing

extension TitleButtonContainer {
    
    class func fromJSON(_ json: [String : AnyObject]?) -> TitleButtonContainer? {
        guard let json = json else {
            return nil
        }
        guard let title = json["title"] as? String else {
            DebugLog.i(caller: self, "Missing title")
            return nil
        }
        
        let button = SRSButtonItem.fromJSON(json["button"] as? [String : AnyObject])
        
        
        return TitleButtonContainerItem(title: title, button: button)
    }
}

/**
 {
    "title" : "Sample Button",
    "button" : {
        // This is an SRSButtonItem
    }
 }
 
 */
