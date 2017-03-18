//
//  StackViewItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class StackViewItem: NSObject, Component {

    enum SeparatorStyle: String {
        case none = "none"
        case line = "line"
        
        static func from(_ string: String?, defaultValue: SeparatorStyle = none) -> SeparatorStyle {
            guard let string = string,
                let style = SeparatorStyle(rawValue: string) else {
                    return defaultValue
            }
            return style
        }
    }
    
    // MARK: Properties
    
    let items: [Component]
    
    let separatorStyle: SeparatorStyle
    
    // MARK: Component Properties
    
    let type = ComponentType.stackView
    
    let layout: ComponentLayout
    
    // MARK: Layout
    
    init(items: [Component],
         separatorStyle: SeparatorStyle,
         layout: ComponentLayout) {
        self.items = items
        self.separatorStyle = separatorStyle
        self.layout = layout
        super.init()
    }
    
    // MARK:- Component Parsing
    
    static func make(with content: [String : AnyObject]?,
                     layout: ComponentLayout) -> Component? {
        guard let content = content else {
            return nil
        }
        guard let itemsJSON = content["items"] as? [[String : AnyObject]] else {
            DebugLog.w(caller: self, "Missing items json. Returning nil:\n\(content)")
            return nil
        }
        
        var items = [Component]()
        for itemJSON in itemsJSON {
            if let component = ComponentFactory.component(with: itemJSON) {
                items.append(component)
            }
        }
        guard !items.isEmpty else {
            DebugLog.w(caller: self, "Empty items json. Returning nil:\n\(content)")
            return nil
        }
        
        let separatorStyle = SeparatorStyle.from(content["separator_style"] as? String,
                                                 defaultValue: .none)
        
        return StackViewItem(items: items,
                             separatorStyle: separatorStyle,
                             layout: layout)
    }
}
