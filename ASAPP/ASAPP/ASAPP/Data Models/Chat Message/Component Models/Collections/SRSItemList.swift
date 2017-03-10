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

class SRSItemList: NSObject {
    var orientation: SRSItemListOrientation
    var items: [AnyObject]
    
    // MARK: Readonly Properties 
    
    var messageText: String? {
        return messageTextItem?.text
    }
    
    var messageTextItem: SRSLabelItem? {
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
    
    var inlineButtonItems: [SRSButtonItem]? {
        var buttonItems = [SRSButtonItem]()
        for item in items {
            if let buttonItem = item as? SRSButtonItem {
                if buttonItem.isInline {
                    buttonItems.append(buttonItem)
                }
            }
        }
        if buttonItems.count > 0 {
            return buttonItems
        }
        return nil
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
    
    class func instanceWithJSON(_ json: [String : AnyObject]?) -> SRSItemList? {
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
            var nestedItems: [AnyObject]?
            
            switch itemType {
            case .ItemList:
                nestedItems = SRSNestedItemListParser.getSRSLabelValueItemsFromItemListJSON(itemJSON)
                break
                
            case .Button:
                item = SRSButtonItem.fromJSON(itemJSON, isInline: false)
                break
                
            case .InlineButton:
                item = SRSButtonItem.fromJSON(itemJSON, isInline: true)
                break
                
            case .Label:
                item = SRSLabelItem.instanceWithJSON(itemJSON)
                break
                
            case .Info:
                item = SRSNestedItemListParser.getSRSLabelValueItemFromInfoItemJSON(itemJSON, listOrientation: orientation)
                break
                
            case .Separator:
                item = SRSSeparatorItem.instanceWithJSON(itemJSON)
                break
                
            case .Filler:
                item = SRSFillerItem.instanceWithJSON(itemJSON)
                break
                
            case .LoaderBar:
                item = SRSLoaderBarItem.instanceWithJSON(itemJSON)
                break
                
            case .Image:
                item = SRSImageItem.instanceWithJSON(itemJSON)
                break
                
            case .Map:
                item = SRSMapItem.instanceWithJSON(itemJSON)
                break
            
            case .Icon:
                item = SRSIconItem.instanceWithJSON(itemJSON)
                break
            }
            
            if let item = item {
                items.append(item)
            } else if let nestedItems = nestedItems {
                items.append(contentsOf: nestedItems)
            }
        }
        
        if items.isEmpty {
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
    case Icon = "icon"
}
