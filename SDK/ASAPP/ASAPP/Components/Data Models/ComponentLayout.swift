//
//  ComponentLayout.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum VerticalAlignment: String {
    case top = "top"
    case middle = "middle"
    case bottom = "bottom"
    case fill = "fill"
    
    static func from(_ string: String?, defaultValue: VerticalAlignment) -> VerticalAlignment {
        guard let string = string,
            let alignment = VerticalAlignment(rawValue: string) else {
                return defaultValue
        }
        return alignment
    }
}

enum HorizontalAlignment: String {
    case left = "left"
    case center = "center"
    case right = "right"
    case fill = "fill"
    
    static func from(_ string: String?, defaultValue: HorizontalAlignment) -> HorizontalAlignment {
        guard let string = string,
            let alignment = HorizontalAlignment(rawValue: string) else {
                return defaultValue
        }
        return alignment
    }
}

// MARK:- ComponentLayout

class ComponentLayout: NSObject {
    
    // MARK: Default Values
    
    static let defaultMargin = UIEdgeInsets.zero
    
    static let defaultPadding = UIEdgeInsets.zero
    
    static let defaultAlignment = HorizontalAlignment.left
    
    static let defaultGravity = VerticalAlignment.top
    
    static let defaultWeight: Int = 0
    
    // MARK: Properties
    
    let margin: UIEdgeInsets
    
    let padding: UIEdgeInsets
    
    let alignment: HorizontalAlignment
    
    let gravity: VerticalAlignment
    
    let weight: Int
    
    // MARK: Init
    
    init(margin: UIEdgeInsets = ComponentLayout.defaultMargin,
         padding: UIEdgeInsets = ComponentLayout.defaultPadding,
         alignment: HorizontalAlignment = ComponentLayout.defaultAlignment,
         gravity: VerticalAlignment = ComponentLayout.defaultGravity,
         weight: Int = ComponentLayout.defaultWeight) {
        
        self.margin = margin
        self.padding = padding
        self.alignment = alignment
        self.gravity = gravity
        self.weight = weight
        super.init()
    }
    
    // MARK: JSON
    
    class func fromJSON(_ json: Any?) -> ComponentLayout {
        guard let json = json as? [String : Any] else {
            return ComponentLayout()
        }
        
        let margin = json.inset(for: "margin", defaultValue: .zero)
        let padding = json.inset(for: "padding", defaultValue: .zero)
        let alignment = HorizontalAlignment.from(json["align"] as? String,
                                                 defaultValue: .left)
        let gravity = VerticalAlignment.from(json["gravity"] as? String,
                                             defaultValue: .top)
        let weight = (json["weight"] as? Int) ?? defaultWeight
        
        return ComponentLayout(margin: margin,
                               padding: padding,
                               alignment: alignment,
                               gravity: gravity,
                               weight: weight)
    }
}
