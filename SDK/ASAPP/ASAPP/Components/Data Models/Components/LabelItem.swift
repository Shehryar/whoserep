//
//  LabelItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class LabelItem: Component {
    
    // MARK: JSON Keys
    
    enum JSONKey: String {
        case text
    }

    // MARK: Component Properties
    
    override var viewClass: UIView.Type {
        return LabelView.self
    }
    
    let text: String
 
    // MARK: Init
    
    init?(text: String, style: ComponentStyle) {
        self.text = text
        super.init(style: style)
    }
    
    required init?(id: String? = nil,
                   name: String? = nil,
                   value: Any? = nil,
                   isChecked: Bool? = nil,
                   isRequired: Bool? = nil,
                   style: ComponentStyle,
                   styles: [String: Any]? = nil,
                   content: [String: Any]? = nil) {
        
        guard let text = content?.string(for: JSONKey.text.rawValue) else {
            DebugLog.w(caller: LabelItem.self, "Missing text: \(String(describing: content))")
            return nil
        }
        self.text = text
        
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
