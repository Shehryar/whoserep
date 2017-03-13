//
//  BasicListSection.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class BasicListSection: NSObject {

    let title: String?
    let items: [BasicListItem]
    
    // TODO: item style...
    
    init(title: String?, items: [BasicListItem]) {
        self.title = title
        self.items = items
        super.init()
    }
}

// MARK:- JSON Parsing

extension BasicListSection {
    
    class func fromJSON(_ json: [String : AnyObject]?) -> BasicListSection? {
        guard let json = json else {
            return nil
        }
        
        guard let itemsJSON = json["items"] as? [[String : AnyObject]] else {
            DebugLog.w(caller: self, "Missing items. Returning nil.")
            return nil
        }
        
        var items = [BasicListItem]()
        for itemJSON in itemsJSON {
            if let item = BasicListItem.fromJSON(itemJSON) {
                items.append(item)
            }
        }
        
        guard !items.isEmpty else {
            DebugLog.w(caller: self, "Empty items. Returning nil.")
            return nil
        }
        
        let title = json["title"] as? String
        
        return BasicListSection(title: title, items: items)
    }
}
