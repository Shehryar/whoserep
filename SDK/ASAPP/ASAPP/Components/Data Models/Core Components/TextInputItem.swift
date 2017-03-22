//
//  TextInputItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TextInputItem: Component {
    
    // MARK:- JSON Keys
    
    enum JSONKey: String {
        case placeholder = "placeholder"
    }
    
    // MARK:- Defaults
    
    static let defaultColor = UIColor(red:0.263, green:0.278, blue:0.310, alpha:1)
    
    // MARK:- Properties
    
    override var viewClass: UIView.Type {
        return TextInputView.self
    }

    let placeholder: String?
    
    // MARK:- Init
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        self.placeholder = content?.string(for: JSONKey.placeholder.rawValue)
        
        super.init(id: id,
                   name: name,
                   value: value,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
