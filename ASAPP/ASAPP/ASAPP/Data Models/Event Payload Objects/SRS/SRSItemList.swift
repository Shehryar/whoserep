//
//  SRSItemList.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

enum SRSItemListOrientation: String {
    case Vertical = "vertical"
    case Horizontal = "horizontal"
}

class SRSItemList: NSObject, JSONObject {
    var orientation: SRSItemListOrientation = .Vertical
    var items: [AnyObject]?
    
    // MARK: Readonly Properties for Modals
    var title: String? {
        guard let items = items else { return nil }
        
        var title: String?
        for item in items {
            if let label = item as? SRSLabel {
                title = label.text
                break
            }
        }
        return title
    }
    
    var buttons: [SRSButton]? {
        guard let items = items else { return nil }
        
        var buttons = [SRSButton]()
        for item in items {
            if let button = item as? SRSButton {
                buttons.append(button)
            }
        }
        return buttons
    }
    
    // MARK: JSONObject
    
    class func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json else { return nil }
        
        let list = SRSItemList()
        if let orientationString = json["orientation"] as? String,
            let orientation = SRSItemListOrientation(rawValue: orientationString) {
            list.orientation = orientation
        }
        
        if let itemsJSONArary = json["value"] as? [[String : AnyObject]] {
            var items = [AnyObject]()
            for itemJSON in itemsJSONArary {
                guard let itemTypeString = itemJSON["type"] as? String,
                    let itemType = SRSItemListItemType(rawValue: itemTypeString) else {
                    continue
                }
                
                var item: AnyObject?
                switch itemType {
                case .ItemList:
                    item = SRSItemList.instanceWithJSON(itemJSON) as? SRSItemList
                    break
                    
                case .Button:
                    item = SRSButton.instanceWithJSON(itemJSON) as? SRSButton
                    break
                    
                case .Label:
                    item = SRSLabel.instanceWithJSON(itemJSON) as? SRSLabel
                    break
                }
                
                if let item = item {
                    items.append(item)
                }
            }
            list.items = items
        }
        
        return list
    }
}

enum SRSItemListItemType: String {
    case ItemList = "itemList"
    case Button = "button"
    case Label = "label"
}
