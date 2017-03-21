//
//  ButtonItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ButtonItem: NSObject, Component {

    enum JSONKey: String {
        case title = "title"
        case buttonStyle = "style"
        case icon = "icon"
    }
    
    enum ButtonStyle: String {
        case block = "block"
        case text = "text"
        
        static func from(_ string: String?, defaultValue: ButtonStyle) -> ButtonStyle {
            guard let string = string,
                let style = ButtonStyle(rawValue: string) else {
                    return defaultValue
            }
            return style
        }
    }
    
    // MARK: Properties
    
    let title: String
    
    let buttonStyle: ButtonStyle
    
    let icon: IconItem?
    
    let action: Action?
    
    // MARK: Component Properties
    
    let id: String?
    
    let style: ComponentStyle
    
    // MARK: Init
    
    init(title: String,
         buttonStyle: ButtonStyle,
         icon: IconItem?,
         action: Action?,
         id: String?,
         style: ComponentStyle) {
        self.title = title
        self.buttonStyle = buttonStyle
        self.icon = icon
        self.action = action
        self.id = id
        self.style = style
        super.init()
    }
    
    // MARK: Component Parsing
    
    static func make(with content: Any?,
                     id: String?,
                     style: ComponentStyle) -> Component? {
        guard let content = content as? [String : Any] else {
            return nil
        }
        guard let title = content[JSONKey.title.rawValue] as? String else {
            DebugLog.e(caller: self, "Title is required. Returning nil.")
            return nil
        }
        
        let buttonStyle = ButtonStyle.from(content[JSONKey.buttonStyle.rawValue] as? String,
                                           defaultValue: .block)
        let icon = ComponentFactory.component(with: content[JSONKey.icon.rawValue]) as? IconItem
        
        return ButtonItem(title: title,
                          buttonStyle: buttonStyle,
                          icon: icon,
                          action: nil,
                          id: id,
                          style: style)
    }
}
