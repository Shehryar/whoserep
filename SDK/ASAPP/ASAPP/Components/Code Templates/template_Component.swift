//
//  template_Component.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentTemplate: NSObject, Component {

    // MARK: Component Properties
    
    let id: String?
    
    let style: ComponentStyle
    
    // MARK: Init
    
    init(id: String?,
         style: ComponentStyle) {
        self.id = id
        self.style = style
        super.init()
    }
    
    // MARK: Component Parsing
    
    static func make(with content: Any?,
                     id: String?,
                     style: ComponentStyle,
                     styles: [String : Any]?) -> Component? {
        guard let content = content as? [String : Any] else {
            return nil
        }
        
        return ComponentTemplate(id: id, style: style) // UPDATE
    }
}
