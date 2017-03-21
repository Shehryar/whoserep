//
//  SeparatorItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SeparatorItem: NSObject, Component {

    enum SeparatorStyle: String {
        case line = "line"
        case gradient = "gradient"
        case block = "block"
        
        static func from(_ string: String?, defaultValue: SeparatorStyle = .line) -> SeparatorStyle {
            guard let string = string,
                let style = SeparatorStyle(rawValue: string) else {
                    return defaultValue
            }
            return style
        }
    }
    
    // MARK: Properties
    
    let separatorStyle: SeparatorItem.SeparatorStyle
    
    let color: UIColor?
    
    // MARK: Component Properties
    
    let type = ComponentType.separator
    
    let id: String?
    
    let style: ComponentStyle
    
    // MARK: Init
    
    init(separatorStyle: SeparatorItem.SeparatorStyle,
         color: UIColor?,
         id: String?,
         style: ComponentStyle) {
        self.separatorStyle = separatorStyle
        self.color = color
        self.id = id
        self.style = style
        super.init()
    }
    
    // MARK: Component Parsing
    
    static let defaultStyle = SeparatorItem.SeparatorStyle.line
    
    static func make(with content: Any?,
                     id: String?,
                     style: ComponentStyle) -> Component? {
        let content = content as? [String : Any]
        let separatorStyle = SeparatorStyle.from(content?["style"] as? String,
                                                 defaultValue: defaultStyle)
        let color = UIColor.colorFromHex(hex: content?["color"] as? String)
        
        return SeparatorItem(separatorStyle: separatorStyle,
                             color: color,
                             id: id,
                             style: style)
    }
    
}
