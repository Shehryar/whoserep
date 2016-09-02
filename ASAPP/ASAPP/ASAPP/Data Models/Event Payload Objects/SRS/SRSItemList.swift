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
    var orientation: SRSItemListOrientation
    var items: [AnyObject]
    
    // MARK: Readonly Properties 
    
    var title: String? {
        var title: String?
        for item in items {
            if let labelItem = item as? SRSLabelItem {
                title = labelItem.text
                break
            }
        }
        return title
    }
    
    var buttonItems: [SRSButtonItem]? {
        var buttons = [SRSButtonItem]()
        for item in items {
            if let button = item as? SRSButtonItem {
                buttons.append(button)
            }
        }
        return buttons
    }
    
    // MARK: Init
    
    init(items: [AnyObject], orientation: SRSItemListOrientation) {
        self.items = items
        self.orientation = orientation
        super.init()
    }
    
    // MARK: JSONObject
    
    class func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json,
            let itemsJSONArary = json["value"] as? [[String : AnyObject]] else {
                return nil
        }
        
        var orientation = SRSItemListOrientation.Vertical
        if let orientationString = json["orientation"] as? String,
            let parsedOrientation = SRSItemListOrientation(rawValue: orientationString)  {
            orientation = parsedOrientation
        }
        
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
                item = SRSButtonItem.instanceWithJSON(itemJSON) as? SRSButtonItem
                break
                
            case .Label:
                item = SRSLabelItem.instanceWithJSON(itemJSON) as? SRSLabelItem
                break
                
            case .Info:
                let infoItem = SRSInfoItem.instanceWithJSON(itemJSON) as? SRSInfoItem
                if orientation == .Vertical {
                    infoItem?.orientation = .Horizontal
                } else {
                    infoItem?.orientation = .Vertical
                }
                item = infoItem
                break
                
            case .Separator:
                item = SRSSeparatorItem.instanceWithJSON(itemJSON) as? SRSSeparatorItem
                break
                
            case .Filler:
                item = SRSFillerItem.instanceWithJSON(itemJSON) as? SRSFillerItem
                break
            }
            
            if let item = item {
                items.append(item)
            }
        }
        
        guard !items.isEmpty else {
            return nil
            
        }
        
        return SRSItemList(items: items, orientation: orientation)
    }
}

enum SRSItemListItemType: String {
    case ItemList = "itemlist"
    case Button = "button"
    case Label = "label"
    case Separator = "separator"
    case Info = "info"
    case Filler = "filler"
}
