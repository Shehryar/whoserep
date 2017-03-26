//
//  ScrollViewItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ScrollViewItem: Component {

    // MARK:- JSON Keys
    
    enum JSONKey: String {
        case content = "content"
    }
    
    // MARK:- Properties
    
    override var viewClass: UIView.Type {
        return ScrollView.self
    }
    
    let displayContent: Component
    
    // MARK:- Init
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        guard let displayContent = ComponentFactory.component(with: content?[JSONKey.content.rawValue],
                                                              styles: styles)
            else {
                DebugLog.w(caller: ScrollViewItem.self, "Missing \(JSONKey.content.rawValue): \(content)")
                return nil
        }
        self.displayContent = displayContent
        
        super.init(id: id,
                   name: name,
                   value: value,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
