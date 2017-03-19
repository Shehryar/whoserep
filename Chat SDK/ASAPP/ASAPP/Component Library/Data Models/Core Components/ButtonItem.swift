//
//  ButtonItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ButtonItem: NSObject, Component {

    // MARK: Properties
    
    let title: String
    
    let action: Action
    
    // MARK: Component Properties
    
    let type = ComponentType.button
    
    let id: String?
    
    let layout: ComponentLayout
    
    // MARK: Init
    
    init(title: String,
         action: Action,
         id: String?,
         layout: ComponentLayout) {
        self.title = title
        self.action = action
        self.id = id
        self.layout = layout
        super.init()
    }
    
    // MARK: Component Parsing
    
    static func make(with content: Any?,
                     id: String?,
                     layout: ComponentLayout) -> Component? {
        return nil
    }
}
