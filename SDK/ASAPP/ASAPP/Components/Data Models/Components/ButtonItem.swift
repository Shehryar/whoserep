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
        case icon = "icon"
        case title = "title"
    }
    
    // MARK:- Defaults
    
    static let defaultIconSpacing: CGFloat = 8
    
    // MARK:- Properties
    
    let title: String?
    
    let icon: IconItem?
    
    let action: Action
    
    // MARK:- Component Properties
    
    override var viewClass: UIView.Type {
        return ButtonView.self
    }
    
    // MARK:- Init
    
    required init?(id: String? = nil,
                   name: String? = nil,
                   value: Any? = nil,
                   isChecked: Bool? = nil,
                   style: ComponentStyle,
                   styles: [String : Any]? = nil,
                   content: [String : Any]? = nil) {
        let title = content?.string(for: JSONKey.title.rawValue)
        let icon = ComponentFactory.component(with: content?[JSONKey.icon.rawValue], styles: styles) as? IconItem
        guard title != nil || icon != nil else {
            DebugLog.w(caller: ButtonItem.self, "A buttonItem requires either a title or an icon.")
            return nil
        }
        self.title = title
        self.icon = icon
        
        guard let actionJSON = content?[JSONKey.action.rawValue] else {
            DebugLog.w(caller: ButtonItem.self, "Missing action: \(String(describing: content))")
            return nil
        }
        guard let action = ActionFactory.action(with: actionJSON) else {
            DebugLog.w(caller: ButtonItem.self, "Unable to parse action: \(String(describing: content))")
            return nil
        }
        self.action = action
        
        super.init(id: id,
                   name: name,
                   value: value,
                   isChecked: isChecked,
                   style: style,
                   styles: styles,
                   content: content)
    }
}