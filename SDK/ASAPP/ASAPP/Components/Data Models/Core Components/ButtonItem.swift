//
//  ButtonItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ButtonItem: NSObject, Component {

    enum Style: String {
        case block = "block"
        case text = "text"
        
        static func from(_ string: String?, defaultValue: Style) -> Style {
            guard let string = string,
                let style = Style(rawValue: string) else {
                    return defaultValue
            }
            return style
        }
    }
    
    // MARK: Properties
    
    let title: String
    
    let style: Style
    
    let icon: IconItem?
    
    let action: Action?
    
    // MARK: Component Properties
    
    let type = ComponentType.button
    
    let id: String?
    
    let layout: ComponentLayout
    
    // MARK: Init
    
    init(title: String,
         style: Style,
         icon: IconItem?,
         action: Action?,
         id: String?,
         layout: ComponentLayout) {
        self.title = title
        self.style = style
        self.icon = icon
        self.action = action
        self.id = id
        self.layout = layout
        super.init()
    }
    
    // MARK: Component Parsing
    
    static func make(with content: Any?,
                     id: String?,
                     layout: ComponentLayout) -> Component? {
        guard let content = content as? [String : Any] else {
            return nil
        }
        guard let title = content["title"] as? String else {
            DebugLog.e(caller: self, "Title is required. Returning nil.")
            return nil
        }
        
        let style = Style.from(content["style"] as? String, defaultValue: .block)
        let icon = ComponentFactory.component(with: content["icon"]) as? IconItem
        
        return ButtonItem(title: title,
                          style: style,
                          icon: icon,
                          action: nil,
                          id: id,
                          layout: layout)
    }
}
