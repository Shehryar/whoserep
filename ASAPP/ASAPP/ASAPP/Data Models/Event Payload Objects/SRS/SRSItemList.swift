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
        return titleItem?.text
    }
    
    var titleItem: SRSLabelItem? {
        return items.first as? SRSLabelItem
    }
    
    // Returns all items that aren't the titleItem or buttonItems
    var contentItems: [AnyObject]? {
        var contentItems = [AnyObject]()
        for (index, item) in items.enumerated() {
            if item is SRSLabelItem && index == 0 {
                continue
            }
            if item is SRSButtonItem {
                continue
            }
            contentItems.append(item)
        }
        return contentItems
    }
    
    var buttonItems: [SRSButtonItem]? {
        var buttonItems = [SRSButtonItem]()
        for item in items {
            if let buttonItem = item as? SRSButtonItem {
                if !buttonItem.isInline {
                    buttonItems.append(buttonItem)
                }
            }
        }
        if buttonItems.count > 0 {
            return buttonItems
        }
        return nil
    }
    
    var immediateActionButtonItem: SRSButtonItem? {
        guard let buttonItems = buttonItems else { return nil }
        
        for buttonItem in buttonItems {
            if buttonItem.isAutoSelect {
                return buttonItem
            }
        }
        return nil
    }
    
    // MARK: Init
    
    init(items: [AnyObject], orientation: SRSItemListOrientation) {
        self.items = items
        self.orientation = orientation
        super.init()
    }
    
    // MARK: JSONObject
    
    class func instanceWithJSON(_ json: [String : AnyObject]?) -> JSONObject? {
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
                    infoItem?.orientation = .horizontal
                } else {
                    infoItem?.orientation = .vertical
                }
                item = infoItem
                break
                
            case .Separator:
                item = SRSSeparatorItem.instanceWithJSON(itemJSON) as? SRSSeparatorItem
                break
                
            case .Filler:
                item = SRSFillerItem.instanceWithJSON(itemJSON) as? SRSFillerItem
                break
                
            case .LoaderBar:
                item = SRSLoaderBarItem.instanceWithJSON(itemJSON) as? SRSLoaderBarItem
                break
                
            case .Image:
                item = SRSImageItem.instanceWithJSON(itemJSON) as? SRSImageItem
                break
                
            case .Map:
                item = SRSMapItem.instanceWithJSON(itemJSON) as? SRSMapItem
                break
                
            case .InlineButton:
                item = SRSButtonItem.instanceWithJSON(itemJSON) as? SRSButtonItem
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
    case InlineButton = "inlineButton"
    case Label = "label"
    case Separator = "separator"
    case Info = "info"
    case Filler = "filler"
    case LoaderBar = "loaderBar"
    case Image = "image"
    case Map = "map"
}
