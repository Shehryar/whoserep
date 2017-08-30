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
        case root
    }
    
    // MARK:- Properties
    
    let root: Component
    
    // MARK:- Component Properties
    
    override var viewClass: UIView.Type {
        return ScrollView.self
    }
    
    override var nestedComponents: [Component]? {
        return [root]
    }
    
    // MARK:- Init
    
    required init?(id: String? = nil,
                   name: String? = nil,
                   value: Any? = nil,
                   isChecked: Bool? = nil,
                   style: ComponentStyle,
                   styles: [String : Any]? = nil,
                   content: [String : Any]? = nil) {
        guard let root = ComponentFactory.component(with: content?[JSONKey.root.rawValue],
                                                    styles: styles)
            else {
                DebugLog.w(caller: ScrollViewItem.self, "Missing \(JSONKey.root.rawValue): \(String(describing: content))")
                return nil
        }
        self.root = root
        
        super.init(id: id,
                   name: name,
                   value: value,
                   isChecked: isChecked,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
