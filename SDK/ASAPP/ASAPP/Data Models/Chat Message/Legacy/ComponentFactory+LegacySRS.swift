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
                
                break
                
            case .info:
                
                break
                
            case .itemList:
                
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
}
