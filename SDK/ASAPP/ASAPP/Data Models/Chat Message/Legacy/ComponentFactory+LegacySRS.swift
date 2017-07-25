//
//  Component+LegacySRS.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

extension ComponentFactory {
    
    static func convertSRSItems(_ items: [SRSItem]?) -> [Component]? {
        guard let items = items else {
            return nil
        }
        
        var components = [Component]()
        for (idx, item) in items.enumerated() {
            var style = ComponentStyle()
            if idx > 0 {
                style.margin = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
            }
            
            switch item.type {
            case .button:
                // No inline buttons allowed
                break
                
            case .filler:
                style.width = 20
                style.height = 8
                style.alignment = .center
                if let separatorItem = SeparatorItem(style: style) {
                    components.append(separatorItem)
                }                
                break
                
            case .icon:
                // Not yet
                break
                
            case .info:
                if let srsInfo = item as? SRSInfo,
                    let stackViewItem = getHorizontalStackViewItemForSRSInfo(srsInfo, style: style) {
                    components.append(stackViewItem)
                }
                break
                
            case .itemList:
                if let srsItemList = item as? SRSItemList,
                    let nestedComponents = getComponentsForNestedSRSItemList(srsItemList, style: style) {
                    components.append(contentsOf: nestedComponents)
                }
                break
                
            case .label:
                style.alignment = .center
                style.textAlign = .center
                if let srsLabel = item as? SRSLabel,
                    let labelItem = LabelItem(text: srsLabel.text, style: style) {
                    components.append(labelItem)
                }
                break
                
            case .separator:
                style.alignment = .fill
                if let separatorItem = SeparatorItem(style: style) {
                    components.append(separatorItem)
                }
                break
            }
        }
        
        return components.isEmpty ? nil : components
    }
    
    static func getHorizontalStackViewItemForSRSInfo(_ info: SRSInfo, style: ComponentStyle) -> StackViewItem? {
        var components = [Component]()
        
        var labelStyle = ComponentStyle()
        labelStyle.margin = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 12)
        labelStyle.alignment = .left
        labelStyle.textAlign = .left
        labelStyle.weight = 1
        if let labelText = info.label,
            let labelItem = LabelItem(text: labelText, style: labelStyle) {
            components.append(labelItem)
        }
        
        var valueStyle = ComponentStyle()
        valueStyle.margin = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        valueStyle.alignment = .right
        valueStyle.textAlign = .right
        valueStyle.weight = 1
        valueStyle.textType = .bodyBold
        if let valueText = info.value,
            let valueItem = LabelItem(text: valueText, style: valueStyle) {
            components.append(valueItem)
        }
        
        return StackViewItem(orientation: .horizontal, items: components, style: style)
    }
    
    static func getComponentsForNestedSRSItemList(_ itemList: SRSItemList, style: ComponentStyle) -> [Component]? {
        var components = [Component]()
        
        switch itemList.orientation {
        case .vertical:
            for item in itemList.items {
                if let stackViewItem = getHorizontalStackViewItemForSRSInfo(item, style: style) {
                    components.append(stackViewItem)
                }
            }
            break
            
        case .horizontal:
            for item in itemList.items {
                var valueStyle = ComponentStyle()
                valueStyle.margin = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
                valueStyle.alignment = .center
                valueStyle.textAlign = .center
                valueStyle.textType = .header2
                if let valueText = item.value,
                    let valueItem = LabelItem(text: valueText, style: valueStyle) {
                    components.append(valueItem)
                }
                
                var labelStyle = ComponentStyle()
                labelStyle.margin = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
                labelStyle.alignment = .center
                labelStyle.textAlign = .center
                if let labelText = item.label,
                    let labelItem = LabelItem(text: labelText, style: labelStyle) {
                    components.append(labelItem)
                }
            }
            break
        }
        
        return components.isEmpty ? nil : components
    }
}
