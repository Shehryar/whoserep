//
//  RadioButtonItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class RadioButtonItem: Component {
    
    // MARK:- Defaults
    
    static let defaultWidth: CGFloat = 18
    
    static let defaultHeight: CGFloat = 18
    
    static let defaultPadding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    
    // MARK:- Component Properties
    
    override var viewClass: UIView.Type {
        return RadioButton.self
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
