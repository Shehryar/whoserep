//
//  StackViewItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class StackViewItem: NSObject, Component {
    
    // MARK: Properties
    
    let items: [Component]
    
    // MARK: Component Properties
    
    let type = ComponentType.stackView
    
    let id: String?
    
    let layout: ComponentLayout
    
    // MARK: Layout
    
    init(items: [Component],
         id: String?,
         layout: ComponentLayout) {
        self.items = items
        self.id = id
        self.layout = layout
        super.init()
    }
    
    // MARK:- Component Parsing
    
    static func make(with content: Any?,
                     id: String?,
                     layout: ComponentLayout) -> Component? {
        guard let content = content as? [String : Any] else {
            return nil
        }
        guard let itemsJSON = content["items"] as? [[String : Any]] else {
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
        
        return StackViewItem(items: items,
                             id: id,
                             layout: layout)
    }
}
