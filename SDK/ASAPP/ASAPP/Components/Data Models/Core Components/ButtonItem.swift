//
//  ButtonItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ButtonItem: Component {

    // MARK:- JSON Keys
    
    enum JSONKey: String {
        case action = "action"
        case buttonStyle = "style"
        case icon = "icon"
        case title = "title"
    }
    
    enum ButtonStyle: String {
        case primary = "primary"
        case secondary = "secondary"
        case text = "text"
        
        static func from(_ string: String?, defaultValue: ButtonStyle) -> ButtonStyle {
            guard let string = string,
                let style = ButtonStyle(rawValue: string) else {
                    return defaultValue
            }
            return style
        }
    }
    
    // MARK:- Defaults
    
    static let defaultButtonStyle = ButtonStyle.primary
    
    // MARK:- Properties
    
    let title: String
    
    let buttonStyle: ButtonStyle
    
    let icon: IconItem?
    
    let action: ComponentAction?
    
    // MARK:- Component Properties
    
    override var viewClass: UIView.Type {
        return ButtonView.self
    }
    
    // MARK:- Init
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        guard let title = content?.string(for: JSONKey.title.rawValue) else {
            DebugLog.w(caller: ButtonItem.self, "Missing title in content: \(content)")
            return nil
        }
        self.title = title
        self.buttonStyle = ButtonStyle.from(content?.string(for: JSONKey.buttonStyle.rawValue),
                                            defaultValue: ButtonItem.defaultButtonStyle)
        self.icon = ComponentFactory.component(with: content?[JSONKey.icon.rawValue], styles: styles) as? IconItem
        let actionJSON = content?[JSONKey.action.rawValue]
        self.action = ComponentActionFactory.action(with: actionJSON)
        
        super.init(id: id,
                   name: name,
                   value: value,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
