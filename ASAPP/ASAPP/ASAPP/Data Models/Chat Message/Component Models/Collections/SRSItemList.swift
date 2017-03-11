//
//  SRSItemList.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class SRSItemList: NSObject {
    
    let messageText: String?
    let contentItems: [AnyObject]?
    let inlineButtonItems: [SRSButtonItem]?
    let buttonItems: [SRSButtonItem]?
    let immediateActionButtonItem: SRSButtonItem?
    
    // MARK:- Init
    
    init(messageText: String?,
         contentItems: [AnyObject]?,
         inlineButtonItems: [SRSButtonItem]?,
         buttonItems: [SRSButtonItem]?,
         immediateActionButtonItem: SRSButtonItem?) {
        
        self.messageText = messageText
        self.contentItems = contentItems
        self.inlineButtonItems = inlineButtonItems
        self.buttonItems = buttonItems
        self.immediateActionButtonItem = immediateActionButtonItem
        super.init()
    }
}
 
// MARK:- JSON Parsing

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

extension SRSItemList {

    class func fromJSON(_ json: [String : AnyObject]?) -> SRSItemList? {
        guard let json = json,
            let itemsJSON = json["value"] as? [[String : AnyObject]] else {
                return nil
        }
        
        var messageText: String?
        var contentItems = [AnyObject]()
        var inlineButtonItems = [SRSButtonItem]()
        var buttonItems = [SRSButtonItem]()
        var immediateActionButtonItem: SRSButtonItem?
        
        for (idx, itemJSON) in itemsJSON.enumerated() {
            guard let itemTypeString = itemJSON["type"] as? String,
                let itemType = SRSItemListItemType(rawValue: itemTypeString) else {
                    DebugLog.i(caller: SRSItemList.self, "Missing or unknown item type in json: ")
                    continue
            }
            
            switch itemType {
            case .ItemList:
                if let items = SRSNestedItemListParser.getSRSLabelValueItemsFromItemListJSON(itemJSON) {
                    
                    print("\n\n\n\n\n\n\n\n\n\n\(String(describing: type(of: items)))\n\n\n\n\n")
//                    contentItems.append(contentsOf: items)
                }
                break
                
            case .Button:
                if let buttonItem = SRSButtonItem.fromJSON(itemJSON) {
                    buttonItems.append(buttonItem)
        
                    if buttonItem.isAutoSelect {
                        immediateActionButtonItem = buttonItem
                    }
                }
                break
                
            case .InlineButton:
                if let inlineButtonItem = SRSButtonItem.fromJSON(itemJSON) {
                    inlineButtonItems.append(inlineButtonItem)
                }
                break
                
            case .Label:
                if let labelItem = SRSLabelItem.instanceWithJSON(itemJSON) {
                    if idx == 0 {
                        messageText = labelItem.text
                    } else {
                        contentItems.append(labelItem)
                    }
                }
                break
                
            case .Info:
                if let labelValueItem = SRSNestedItemListParser.getSRSLabelValueItemFromInfoItemJSON(itemJSON, listOrientationIsVertical: true) {
                    contentItems.append(labelValueItem)
                }
                break
                
            case .Separator:
                if let separatorItem = SRSSeparatorItem.instanceWithJSON(itemJSON) {
                    contentItems.append(separatorItem)
                }
                break
                
            case .Filler:
                if let fillerItem = SRSFillerItem.instanceWithJSON(itemJSON) {
                    contentItems.append(fillerItem)
                }
                break
                
            case .LoaderBar:
                if let loaderBarItem = SRSLoaderBarItem.instanceWithJSON(itemJSON) {
                    contentItems.append(loaderBarItem)
                }
                break
                
            case .Image:
                if let imageItem = SRSImageItem.instanceWithJSON(itemJSON) {
                    contentItems.append(imageItem)
                }
                break
                
            case .Map:
                if let mapItem = SRSMapItem.instanceWithJSON(itemJSON) {
                    contentItems.append(mapItem)
                }
                break
                
            case .Icon:
                if let iconItem = SRSIconItem.instanceWithJSON(itemJSON) {
                    contentItems.append(iconItem)
                }
                break
            }
        }
        
        let _contentItems: [AnyObject]? = contentItems.isEmpty ? nil : contentItems
        let _inlineButtonItems: [SRSButtonItem]? = inlineButtonItems.isEmpty ? nil : inlineButtonItems
        let _buttonItems: [SRSButtonItem]? = buttonItems.isEmpty ? nil : buttonItems
        
        if messageText == nil && _contentItems == nil && _inlineButtonItems == nil {
            DebugLog.i(caller: SRSItemList.self, "Cannot create instance without content: \(json)")
            return nil
        }
        
        return SRSItemList(messageText: messageText,
                           contentItems: _contentItems,
                           inlineButtonItems: _inlineButtonItems,
                           buttonItems: _buttonItems,
                           immediateActionButtonItem: immediateActionButtonItem)
    }
}

