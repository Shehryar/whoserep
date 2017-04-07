//
//  RadioButtonItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class RadioButtonItem: Component {
    
    // MARK:- JSON Keys
    
    enum JSONKey: String {
        case label = "label"
    }
    
    // MARK:- Defaults
    
    static let defaultWidth: CGFloat = 16
    
    static let defaultHeight: CGFloat = 16
    
    // MARK:- Properties
    
    let label: LabelItem
    
    // MARK:- Component Properties
    
    override var viewClass: UIView.Type {
        return RadioButtonView.self
    }
    
    override var nestedComponents: [Component]? {
        return [label]
    }
    
    // MARK:- Init
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        guard let label = ComponentFactory.component(with: content?[JSONKey.label.rawValue], styles: styles) as? LabelItem else {
            DebugLog.w(caller: RadioButtonItem.self, "Label is required. Returning nil from: \(String(describing: content))")
            return nil
        }
        self.label = label
        
        super.init(id: id,
                   name: name,
                   value: value,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
