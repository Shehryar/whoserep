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
    
    let layout: ComponentLayout
    
    // MARK: Init
    
    init(title: LabelItem?,
         detail: LabelItem?,
         value: LabelItem?,
         icon: IconItem?,
         layout: ComponentLayout) {
        self.title = title
        self.detail = detail
        self.value = value
        self.icon = icon
        self.layout = layout
        super.init()
    }
    
    // MARK: Component Parsing
    
    static func make(with content: [String : AnyObject]?,
                     layout: ComponentLayout) -> Component? {
        guard let content = content else {
            return nil
        }
        
        let titleJSON = content["title"] as? [String : AnyObject]
        let title = ComponentFactory.component(with: titleJSON) as? LabelItem
        
        let detailJSON = content["detail"] as? [String : AnyObject]
        let detail = ComponentFactory.component(with: detailJSON) as? LabelItem
        
        let valueJSON = content["value"] as? [String : AnyObject]
        let value = ComponentFactory.component(with: valueJSON) as? LabelItem
        
        let iconJSON = content["icon"] as? [String : AnyObject]
        let icon = ComponentFactory.component(with: iconJSON) as? IconItem
        
        guard title != nil || detail != nil || value != nil else {
            DebugLog.w(caller: self, "Title, detail, or value must be non-nil. Returning nil from: \(content)")
            return nil
        }
        
        return BasicListItem(title: title,
                             detail: detail,
                             value: value,
                             icon: icon,
                             layout: layout)
    }
}
