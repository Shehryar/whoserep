//
//  SRSNestedItemListParser.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SRSNestedItemListParser: NSObject {

    /**
     This method will return an array of SRSLabelValueItem1/SRSLabelValueItem2 items or nil
     */
    class func getSRSLabelValueItemsFromItemListJSON(_ json: [String : AnyObject]?) -> [SRSLabelValueItem]? {
        guard let json = json,
            let itemsJson = json["value"] as? [[String : AnyObject]] else {
                return nil
        }
        
        var listOrientation = SRSItemListOrientation.Vertical
        if let orientationString = json["orientation"] as? String,
            let parsedOrientation = SRSItemListOrientation(rawValue: orientationString)  {
            listOrientation = parsedOrientation
        }
        
        var labelValueItems = [SRSLabelValueItem]()
        for itemJson in itemsJson {
            guard let itemTypeString = itemJson["type"] as? String,
                let itemType = SRSItemListItemType(rawValue: itemTypeString) else {
                    continue
            }
            if itemType != .Info {
                continue
            }
            
            if let labelValueItem = getSRSLabelValueItemFromInfoItemJSON(itemJson, listOrientation: listOrientation) {
                labelValueItems.append(labelValueItem)
            }
        }
        
        return labelValueItems.count > 0 ? labelValueItems : nil
    }
    
    /**
     This will return an instance of SRSLabelValueItem1, SRSLabelValueItem2, or nil
     */
    class func getSRSLabelValueItemFromInfoItemJSON(_ json: [String : AnyObject]?, listOrientation: SRSItemListOrientation) -> SRSLabelValueItem? {
        guard let json = json else {
            return nil
        }
        
        // Label
        var labelItem: SRSLabelItem?
        if let labelText = json["label"] as? String {
            labelItem = SRSLabelItem(text: labelText)
            if let colorString = json["labelColor"] as? String {
                labelItem?.color = UIColor.colorFromHex(hex: colorString)
            }
        }
        
        // Value
        var valueItem: SRSLabelItem?
        if let valueText = json["value"] as? String {
            valueItem = SRSLabelItem(text: valueText)
            if let colorString = json["valueColor"] as? String {
                valueItem?.color = UIColor.colorFromHex(hex: colorString)
            }
        }
        
        if labelItem == nil && valueItem == nil {
            return nil
        }
        
        let type: SRSLabelValueItemType = listOrientation == .Horizontal ? .vertical : .horizontal
        
        return SRSLabelValueItem(type: type, label: labelItem, value: valueItem)
    }
    
}