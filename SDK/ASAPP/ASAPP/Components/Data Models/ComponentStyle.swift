//
//  ComponentStyle.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- ComponentStyle

struct ComponentStyle {
    
    // MARK: Properties
    
    var alignment: HorizontalAlignment = .left
    
    var backgroundColor: UIColor?
    
    var borderColor: UIColor?
    
    var borderWidth: CGFloat = 0
    
    var color: UIColor?
    
    var cornerRadius: CGFloat = 0
    
    var fontSize: CGFloat = 15
    
    var fontWeight: FontWeight = .regular
    
    var gravity: VerticalAlignment = .top
    
    var height: CGFloat = 0
    
    var letterSpacing: CGFloat = 0
    
    var margin: UIEdgeInsets = .zero
    
    var padding: UIEdgeInsets = .zero
    
    var textAlign: NSTextAlignment = .left
    
    var weight: Int = 0
    
    var width: CGFloat = 0
}


// MARK:- JSON Parsing

extension ComponentStyle {
    
    static func fromJSON(_ json: Any?) -> ComponentStyle {
        guard let json = json as? [String : Any] else {
            return ComponentStyle()
        }
        
        var style = ComponentStyle()
        
        if let alignment = json.horizontalAlignment(for: JSONKey.align.rawValue) {
            style.alignment = alignment
        }
        if let backgroundColor = json.hexColor(for: JSONKey.backgroundColor.rawValue) {
            style.backgroundColor = backgroundColor
        }
        if let borderColor = json.hexColor(for: JSONKey.borderColor.rawValue) {
            style.borderColor = borderColor
        }
        if let borderWidth = json.float(for: JSONKey.borderWidth.rawValue) {
            style.borderWidth = borderWidth
        }
        if let color = json.hexColor(for: JSONKey.color.rawValue) {
            style.color = color
        }
        if let cornerRadius = json.float(for: JSONKey.cornerRadius.rawValue) {
            style.cornerRadius = cornerRadius
        }
        if let fontSize = json.float(for: JSONKey.fontSize.rawValue) {
            style.fontSize = fontSize
        }
        if let fontWeight = json.fontWeight(for: JSONKey.fontWeight.rawValue) {
            style.fontWeight = fontWeight
        }
        if let gravity = json.verticalAlignment(for: JSONKey.gravity.rawValue) {
            style.gravity = gravity
        }
        if let height = json.float(for: JSONKey.height.rawValue) {
            style.height = height
        }
        if let letterSpacing = json.float(for: JSONKey.letterSpacing.rawValue) {
            style.letterSpacing = letterSpacing
        }
        style.margin = json.inset(for: JSONKey.margin.rawValue, defaultValue: style.margin)
        style.padding = json.inset(for: JSONKey.padding.rawValue, defaultValue: style.padding)
        if let textAlign = json.textAlignment(for: JSONKey.textAlign.rawValue) {
            style.textAlign = textAlign
        }
        if let weight = json.int(for: JSONKey.weight.rawValue) {
            style.weight = weight
        }
        if let width = json.float(for: JSONKey.width.rawValue) {
            style.width = width
        }
        
        return style
    }
    
    static func getStyle(from json: Any?, styleClass: String?, styles: [String : Any]?) -> ComponentStyle {
        guard let styleClass = styleClass,
            let styles = styles else {
                return fromJSON(json)
        }
        
        var combinedStyleJSON = [String : Any]()
        
        // Style class may actually be a space-separate list of classes
        let styleClassNames = styleClass.components(separatedBy: " ")
        for styleClassName in styleClassNames {
            if let classStyle = styles[styleClassName] as? [String : Any] {
                combinedStyleJSON.add(classStyle)
            }
        }
        
        if let json = json as? [String : Any] {
            combinedStyleJSON.add(json)
        }
        
        return fromJSON(combinedStyleJSON)
    }
}

// MARK:- JSONKeys

extension ComponentStyle {
    
    enum JSONKey: String {
        // Keep alphabetical
        case align = "align"
        case backgroundColor = "backgroundColor"
        case borderColor = "borderColor"
        case borderWidth = "borderWidth"
        case color = "color"
        case cornerRadius = "cornerRadius"
        case fontSize = "fontSize"
        case fontWeight = "fontWeight"
        case gravity = "gravity"
        case height = "height"
        case letterSpacing = "letterSpacing"
        case margin = "margin"
        case padding = "padding"
        case textAlign = "textAlign"
        case weight = "weight"
        case width = "width"
    }
}

// MARK:- Horizontal Alignment

enum HorizontalAlignment: String {
    case left = "left"
    case center = "center"
    case right = "right"
    case fill = "fill"
    
    static func from(_ string: String?) -> HorizontalAlignment? {
        guard let string = string,
            let alignment = HorizontalAlignment(rawValue: string) else {
                return nil
        }
        return alignment
    }
    
    static func from(_ string: String?, defaultValue: HorizontalAlignment) -> HorizontalAlignment {
        return from(string) ?? defaultValue
    }
}

// MARK:- Vertical Alignment

enum VerticalAlignment: String {
    case top = "top"
    case middle = "middle"
    case bottom = "bottom"
    case fill = "fill"
    
    static func from(_ string: String?) -> VerticalAlignment? {
        guard let string = string,
            let alignment = VerticalAlignment(rawValue: string) else {
                return nil
        }
        return alignment
    }
    
    static func from(_ string: String?, defaultValue: VerticalAlignment) -> VerticalAlignment {
       return from(string) ?? defaultValue
    }
}

// MARK:- NSTextAlignment

extension NSTextAlignment {
    
    static func from(_ stringValue: String?) -> NSTextAlignment? {
        guard let stringValue = stringValue else {
            return nil
        }
        
        switch stringValue.lowercased() {
        case "left": return .left
        case "center": return .center
        case "right": return .right
        case "justified": return .justified
        default: return nil
        }
    }
    
    static func from(_ stringValue: String?, defaultValue: NSTextAlignment) -> NSTextAlignment {
        return from(stringValue) ?? defaultValue
    }
}

// MARK:- FontWeight

enum FontWeight: String {
    case light = "light"
    case regular = "regular"
    case bold = "bold"
    case black = "black"
    
    static func from(_ string: String?) -> FontWeight? {
        guard let string = string,
            let style = FontWeight(rawValue: string) else {
                return nil
        }
        return style
    }
    
    static func from(_ string: String?, defaultValue: FontWeight = regular) -> FontWeight {
        return from(string) ?? defaultValue
    }
}
