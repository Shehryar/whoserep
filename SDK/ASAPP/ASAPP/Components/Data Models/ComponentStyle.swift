//
//  ComponentStyle.swift
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

// MARK:- ComponentStyle

class ComponentStyle: NSObject {
    
    enum JSONKey: String {
        case margin = "margin"
        case padding = "padding"
        case align = "align"
        case gravity = "gravity"
        case weight = "weight"
    }
    
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
    
    init(margin: UIEdgeInsets = ComponentStyle.defaultMargin,
         padding: UIEdgeInsets = ComponentStyle.defaultPadding,
         alignment: HorizontalAlignment = ComponentStyle.defaultAlignment,
         gravity: VerticalAlignment = ComponentStyle.defaultGravity,
         weight: Int = ComponentStyle.defaultWeight) {
        
        self.margin = margin
        self.padding = padding
        self.alignment = alignment
        self.gravity = gravity
        self.weight = weight
        super.init()
    }
    
    // MARK: JSON
    
    class func fromJSON(_ json: Any?) -> ComponentStyle {
        guard let json = json as? [String : Any] else {
            return ComponentStyle()
        }
        
        let margin = json.inset(for: JSONKey.margin.rawValue, defaultValue: .zero)
        let padding = json.inset(for: JSONKey.padding.rawValue, defaultValue: .zero)
        let alignment = HorizontalAlignment.from(json[JSONKey.align.rawValue] as? String,
                                                 defaultValue: .left)
        let gravity = VerticalAlignment.from(json[JSONKey.gravity.rawValue] as? String,
                                             defaultValue: .top)
        let weight = (json[JSONKey.weight.rawValue] as? Int) ?? defaultWeight
        
        return ComponentStyle(margin: margin,
                               padding: padding,
                               alignment: alignment,
                               gravity: gravity,
                               weight: weight)
    }
}
