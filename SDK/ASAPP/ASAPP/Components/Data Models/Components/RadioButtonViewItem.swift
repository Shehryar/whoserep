//
//  RadioButtonViewItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class RadioButtonViewItem: Component {
    
    // MARK:- JSON Keys
    
    enum JSONKey: String {
        case root = "root"
    }
    
    // MARK:- Properties
    
    let root: Component
    
    // MARK:- Component Properties
    
    override var viewClass: UIView.Type {
        return RadioButtonView.self
    }
    
    override var nestedComponents: [Component]? {
        return [root]
    }
    
    // MARK:- Init
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   isChecked: Bool?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        guard let root = ComponentFactory.component(with: content?[JSONKey.root.rawValue], styles: styles) else {
            DebugLog.w(caller: RadioButtonViewItem.self, "root is required: \(String(describing: content))")
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
