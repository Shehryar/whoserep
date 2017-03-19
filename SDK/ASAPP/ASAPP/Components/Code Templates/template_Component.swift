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
    
    let type = ComponentType.label // UPDATE
    
    let id: String?
    
    let layout: ComponentLayout
    
    // MARK: Init
    
    init(id: String?,
         layout: ComponentLayout) {
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
        
        return ComponentTemplate(id: id, layout: layout) // UPDATE
    }
}
