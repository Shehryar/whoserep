//
//  CheckboxItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class CheckboxItem: Component {

    // MARK:- JSON Keys
    
    enum JSONKey: String {
        case label = "label"
    }
    
    // MARK:- Defaults
    
    static let defaultWidth: CGFloat = 20
    
    static let defaultHeight: CGFloat = 20
    
    // MARK:- Properties
    
    override var viewClass: UIView.Type {
        return CheckboxView.self
    }
    
    let label: LabelItem
    
    // MARK:- Init
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        
        guard let component = ComponentFactory.component(with: content?[JSONKey.label.rawValue], styles: styles),
            let label = component as? LabelItem else {
                DebugLog.w(caller: CheckboxItem.self, "Label is required: \(content)")
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
