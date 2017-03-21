//
//  LabelItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class LabelItem: NSObject, Component {
    
    enum JSONKey: String {
        case text = "text"
        
        case alignment = "textAlign"
        case fontWeight = "fontWeight"
        case fontSize = "fontSize"
        case color = "color"
        case letterSpacing = "letterSpacing"
    }
    
    // MARK: Defaults
    
    static let defaultAlignment = NSTextAlignment.left
    static let defaultFontWeight = FontWeight.regular
    static let defaultSize: Int = 15
    static let defaultLetterSpacing: CGFloat = 0
    
    // MARK: Properties
    
    let text: String
    
    let alignment: NSTextAlignment
    
    let fontWeight: FontWeight
    
    let fontSize: CGFloat
    
    let color: UIColor?
    
    let letterSpacing: CGFloat
    
    // MARK: Component Properties
    
    let type = ComponentType.label
    
    let id: String?
    
    let style: ComponentStyle
    
    // MARK: Init
    
    init(text: String,
         alignment: NSTextAlignment,
         fontWeight: FontWeight,
         fontSize: CGFloat,
         color: UIColor?,
         letterSpacing: CGFloat,
         id: String?,
         style: ComponentStyle) {
        
        self.text = text
        self.alignment = alignment
        self.fontWeight = fontWeight
        self.fontSize = fontSize
        self.color = color
        self.letterSpacing = letterSpacing
        self.id = id
        self.style = style
        super.init()
    }
    
    // MARK:- Component Parsing

    static func make(with content: Any?,
                     id: String?,
                     style: ComponentStyle) -> Component? {
        guard let content = content as? [String : Any] else {
            return nil
        }
        guard let text = content[JSONKey.text.rawValue] as? String else {
            DebugLog.w(caller: self, "Missing text: \(content)")
            return nil
        }
        
        let alignment = NSTextAlignment.from(content[JSONKey.alignment.rawValue] as? String,
                                             defaultValue: defaultAlignment)
        let fontWeight = FontWeight.from(content[JSONKey.fontWeight.rawValue] as? String,
                                       defaultValue: defaultFontWeight)
        let fontSize = CGFloat(content[JSONKey.fontSize.rawValue] as? Int ?? defaultSize)
        let color = UIColor.colorFromHex(hex: content[JSONKey.color.rawValue] as? String)
        let letterSpacing = (content[JSONKey.letterSpacing.rawValue] as? CGFloat) ?? defaultLetterSpacing
        
        return LabelItem(text: text,
                         alignment: alignment,
                         fontWeight: fontWeight,
                         fontSize: fontSize,
                         color: color,
                         letterSpacing: letterSpacing,
                         id: id,
                         style: style)
    }
}
