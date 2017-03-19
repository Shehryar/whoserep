//
//  SeparatorItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SeparatorItem: NSObject, Component {

    enum Style: String {
        case line = "line"
        case gradient = "gradient"
        case block = "block"
        
        static func from(_ string: String?, defaultValue: Style = .line) -> Style {
            guard let string = string,
                let style = Style(rawValue: string) else {
                    return defaultValue
            }
            return style
        }
    }
    
    // MARK: Properties
    
    let style: SeparatorItem.Style
    
    let color: UIColor?
    
    // MARK: Component Properties
    
    let type = ComponentType.separator
    
    let id: String?
    
    let layout: ComponentLayout
    
    // MARK: Init
    
    init(style: SeparatorItem.Style,
         color: UIColor?,
         id: String?,
         layout: ComponentLayout) {
        self.style = style
        self.color = color
        self.id = id
        self.layout = layout
        super.init()
    }
    
    // MARK: Component Parsing
    
    static let defaultStyle = SeparatorItem.Style.line
    
    static func make(with content: Any?,
                     id: String?,
                     layout: ComponentLayout) -> Component? {
        let content = content as? [String : Any]
        let style = Style.from(content?["style"] as? String,
                               defaultValue: defaultStyle)
        let color = UIColor.colorFromHex(hex: content?["color"] as? String)
        
        return SeparatorItem(style: style,
                             color: color,
                             id: id,
                             layout: layout)
    }
    
}
