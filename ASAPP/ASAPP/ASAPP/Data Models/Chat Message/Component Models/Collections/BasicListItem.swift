//
//  BasicListItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class BasicListItem: NSObject {

    let title: String?
    let detail: String?
    let value: String?
    let icon: String?
    
    init(title: String?, detail: String?, value: String?, icon: String?) {
        self.title = title
        self.detail = detail
        self.value = value
        self.icon = icon
        super.init()
    }
}

extension BasicListItem {
    
    class func fromJSON(_ json: [String : AnyObject]?) -> BasicListItem? {
        guard let json = json else {
            return nil
        }
        
        let title = json["title"] as? String
        let detail = json["detail"] as? String
        let value = json["value"] as? String
        let iconName = json["icon"] as? String
        
        // TODO: Icon factory -- don't show bad icons that we don't have on hand
        
        guard title != nil || detail != nil || value != nil else {
            DebugLog.w(caller: self, "Cannot create an empty item. Returning nil: \(json)")
            return nil
        }
        
        return BasicListItem(title: title, detail: detail, value: value, icon: iconName)
    }
}
