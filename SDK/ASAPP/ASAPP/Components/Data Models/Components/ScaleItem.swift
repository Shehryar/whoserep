//
//  ScaleItem.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 4/23/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

class ScaleItem: Component {
    
    enum ScaleType: String {
        case fiveNumber
        case fiveStar
        case nrs11
    }
    
    enum JSONKey: String {
        case scaleType
    }
    
    let scaleType: ScaleType
    
    // MARK: - Component Properties
    
    override var viewClass: UIView.Type {
        return ScaleView.self
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
        let scaleTypeString = content?.string(for: JSONKey.scaleType.rawValue) ?? ""
        let scaleType = ScaleType.init(rawValue: scaleTypeString) ?? .fiveNumber
        
        self.scaleType = scaleType
        
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
