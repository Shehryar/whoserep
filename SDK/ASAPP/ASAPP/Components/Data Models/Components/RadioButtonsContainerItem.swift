//
//  RadioButtonsContainerItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class RadioButtonsContainerItem: Component {
    
    // MARK: - JSON Keys
    
    enum JSONKey: String {
        case root
    }
    
    // MARK: - Properties
    
    let root: Component
    
    // MARK: - Component Properties
    
    override var viewClass: UIView.Type {
        return RadioButtonsContainerView.self
    }
    
    override var nestedComponents: [Component]? {
        return [root]
    }
    
    // MARK: - Init
    
    required init?(id: String? = nil,
                   name: String? = nil,
                   value: Any? = nil,
                   isChecked: Bool? = nil,
                   isRequired: Bool? = nil,
                   style: ComponentStyle,
                   styles: [String: Any]? = nil,
                   content: [String: Any]? = nil) {
        guard let root = ComponentFactory.component(with: content?[JSONKey.root.rawValue], styles: styles) else {
            DebugLog.w(caller: RadioButtonsContainerItem.self, "root is required: \(String(describing: content))")
            return nil
        }
        self.root = root
        
        super.init(id: id,
                   name: name,
                   value: value,
                   isChecked: isChecked,
                   isRequired: isRequired,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
