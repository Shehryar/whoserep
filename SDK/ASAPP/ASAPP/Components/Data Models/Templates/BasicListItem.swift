//
//  BasicListItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class BasicListItem: NSObject, Component {

    // MARK: Properties
    
    let title: LabelItem?
    
    let detail: LabelItem?
    
    let value: LabelItem?
    
    let icon: IconItem?
    
    // MARK: Component Properties
    
    let type = ComponentType.basicListItem
    
    let id: String?
    
    let layout: ComponentLayout
    
    // MARK: Init
    
    init(title: LabelItem?,
         detail: LabelItem?,
         value: LabelItem?,
         icon: IconItem?,
         id: String?,
         layout: ComponentLayout) {
        self.title = title
        self.detail = detail
        self.value = value
        self.icon = icon
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
        
        let title = ComponentFactory.component(with: content["title"]) as? LabelItem
        let detail = ComponentFactory.component(with: content["detail"]) as? LabelItem
        let value = ComponentFactory.component(with: content["value"]) as? LabelItem
        let icon = ComponentFactory.component(with: content["icon"]) as? IconItem
        
        guard title != nil || detail != nil || value != nil else {
            DebugLog.w(caller: self, "Title, detail, or value must be non-nil. Returning nil from: \(content)")
            return nil
        }
        
        return BasicListItem(title: title,
                             detail: detail,
                             value: value,
                             icon: icon,
                             id: id,
                             layout: layout)
    }
}
