//
//  SeparatorItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SeparatorItem: NSObject, Component {

    enum JSONKey: String {
        case color = "color"
    }
    
    // MARK: Properties
    
    let color: UIColor?
    
    // MARK: Component Properties
    
    let type = ComponentType.separator
    
    let id: String?
    
    let style: ComponentStyle
    
    // MARK: Init
    
    init(color: UIColor?,
         id: String?,
         style: ComponentStyle) {
        self.color = color
        self.id = id
        self.style = style
        super.init()
    }
    
    // MARK: Component Parsing
    
    static func make(with content: Any?,
                     id: String?,
                     style: ComponentStyle) -> Component? {
        let content = content as? [String : Any]
        let color = UIColor.colorFromHex(hex: content?[JSONKey.color.rawValue] as? String)
        
        return SeparatorItem(color: color,
                             id: id,
                             style: style)
    }
    
}
