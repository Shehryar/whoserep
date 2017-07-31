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
    
    var buttonType: ButtonType = .primary
    
    var color: UIColor?
    
    var cornerRadius: CGFloat = 0
    
    var fontSize: CGFloat?
    
    var gravity: VerticalAlignment = .top
    
    var height: CGFloat = 0
    
    var letterSpacing: CGFloat = 0
    
    var margin: UIEdgeInsets = .zero
    
    var padding: UIEdgeInsets = .zero
    
    var textAlign: NSTextAlignment?
    
    var textType: TextType = .body
    
    var weight: Int = 0
    
    var width: CGFloat = 0
}

// MARK:- JSON Parsing

extension ComponentStyle {
    
    enum JSONKey: String {
        // Keep alphabetical
        case align = "align"
        case backgroundColor = "backgroundColor"
        case borderColor = "borderColor"
        case borderWidth = "borderWidth"
        case buttonType = "buttonType"
        case color = "color"
        case cornerRadius = "cornerRadius"
        case fontSize = "fontSize"
        case gravity = "gravity"
        case height = "height"
        case letterSpacing = "letterSpacing"
        case margin = "margin"
        case padding = "padding"
        case textAlign = "textAlign"
        case textType = "textType"
        case weight = "weight"
        case width = "width"
    }
    
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
        if let buttonType = json.buttonType(for: JSONKey.buttonType.rawValue) {
            style.buttonType = buttonType
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
        if let textType = json.textType(for: JSONKey.textType.rawValue) {
            style.textType = textType
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