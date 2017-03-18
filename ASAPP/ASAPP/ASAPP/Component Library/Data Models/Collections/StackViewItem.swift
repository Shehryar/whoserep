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
    
    // MARK:- Component
    
    static func make(with content: [String : AnyObject]?,
                     layout: ComponentLayout) -> Component?{
        return nil
    }
}


