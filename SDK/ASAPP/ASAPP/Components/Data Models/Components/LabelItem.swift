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
        case text = "text"
    }

    // MARK: Component Properties
    
    override var viewClass: UIView.Type {
        return LabelView.self
    }
    
    let text: String
 
    // MARK: Init
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   isChecked: Bool?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        
        guard let text = content?.string(for: JSONKey.text.rawValue) else {
            DebugLog.w(caller: LabelItem.self, "Missing text: \(String(describing: content))")
            return nil
        }
        self.text = text
        
        super.init(id: id,
                   name: name,
                   value: value,
                   isChecked: isChecked,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
