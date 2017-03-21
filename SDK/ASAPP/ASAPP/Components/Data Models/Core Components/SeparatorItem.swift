//
//  SeparatorItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SeparatorItem: NSObject, Component {

    static let defaultColor = UIColor(red:0.820, green:0.827, blue:0.851, alpha:1.000)
    
    // MARK: Component Properties
    
    let id: String?
    
    let style: ComponentStyle
    
    // MARK: Init
    
    init(id: String?, style: ComponentStyle) {
        self.id = id
        self.style = style
        super.init()
    }
    
    // MARK: Component Parsing
    
    static func make(with content: Any?,
                     id: String?,
                     style: ComponentStyle,
                     styles: [String : Any]?) -> Component? {
        return SeparatorItem(id: id, style: style)
    }
    
}
