//
//  CheckboxItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class CheckboxItem: Component {

    // MARK:- Defaults
    
    static let defaultWidth: CGFloat = 18
    
    static let defaultHeight: CGFloat = 18
    
    static let defaultPadding = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)

    // MARK:- Component Properties
    
    override var viewClass: UIView.Type {
        return Checkbox.self
    }
    
    // MARK:- Init
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   isChecked: Bool?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        // No content
        
        super.init(id: id,
                   name: name,
                   value: value,
                   isChecked: isChecked,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
