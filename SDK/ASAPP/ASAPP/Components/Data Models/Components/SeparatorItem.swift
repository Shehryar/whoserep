//
//  SeparatorItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SeparatorItem: Component {
    
    enum SeparatorStyle: String {
        case horizontal = "horizontal"
        case vertical = "vertical"
        
        static func from(_ value: Any?) -> SeparatorStyle? {
            guard let value = value as? String else {
                return nil
            }
            return SeparatorStyle(rawValue: value)
        }
    }
    
    // MARK:- JSON Keys
    
    enum JSONKey: String {
        case style = "separatorStyle"
    }
    
    // MARK:- Defaults
    
    static let defaultSeparatorStyle = SeparatorStyle.horizontal
    
    // MARK:- Properties
    
    override var viewClass: UIView.Type {
        return SeparatorView.self
    }
    
    let separatorStyle: SeparatorStyle
    
    // MARK:- Init
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        
        self.separatorStyle = SeparatorStyle.from(content?[JSONKey.style.rawValue])
            ?? SeparatorItem.defaultSeparatorStyle
        
        super.init(id: id,
                   name: name,
                   value: value,
                   style: style,
                   styles: styles,
                   content: content)
    }
    
}
