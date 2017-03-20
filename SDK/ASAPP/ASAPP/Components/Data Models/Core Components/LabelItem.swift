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
        case alignment = "alignment"
        case fontWeight = "font_weight"
        case fontSize = "font_size"
        case color = "color"
        case numberOfLines = "number_of_lines"
        case letterSpacing = "letter_spacing"
    }
    
    static let defaultAlignment = NSTextAlignment.left
    static let defaultFontWeight = FontWeight.regular
    static let defaultSize: Int = 15
    static let defaultNumberOfLines: Int = 0
    static let defaultLetterSpacing: CGFloat = 0
    
    // MARK: Properties
    
    let text: String
    
    let alignment: NSTextAlignment
    
    let fontWeight: FontWeight
    
    let fontSize: CGFloat
    
    let color: UIColor?
    
    let numberOfLines: Int
    
    let letterSpacing: CGFloat
    
    // MARK: Component Properties
    
    let type = ComponentType.label
    
    let id: String?
    
    let layout: ComponentLayout
    
    // MARK: Init
    
    init(text: String,
         alignment: NSTextAlignment,
         fontWeight: FontWeight,
         fontSize: CGFloat,
         color: UIColor?,
         numberOfLines: Int,
         letterSpacing: CGFloat,
         id: String?,
         layout: ComponentLayout) {
        
        self.text = text
        self.alignment = alignment
        self.fontWeight = fontWeight
        self.fontSize = fontSize
        self.color = color
        self.numberOfLines = numberOfLines
        self.letterSpacing = letterSpacing
        self.id = id
        self.layout = layout
        super.init()
    }
    
    // MARK:- Component Parsing

    static func make(with content: Any?,
                     id: String?,
                     layout: ComponentLayout) -> Component? {
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
        let numberOfLines = (content[JSONKey.numberOfLines.rawValue] as? Int) ?? defaultNumberOfLines
        let letterSpacing = (content[JSONKey.letterSpacing.rawValue] as? CGFloat) ?? defaultLetterSpacing
        
        return LabelItem(text: text,
                         alignment: alignment,
                         fontWeight: fontWeight,
                         fontSize: fontSize,
                         color: color,
                         numberOfLines: numberOfLines,
                         letterSpacing: letterSpacing,
                         id: id,
                         layout: layout)
    }
}

extension NSTextAlignment {
    static func from(_ stringValue: String?, defaultValue: NSTextAlignment) -> NSTextAlignment {
        guard let stringValue = stringValue else {
            return defaultValue
        }
        
        switch stringValue.lowercased() {
        case "left": return .left
        case "center": return .center
        case "right": return .right
        case "justified": return .justified
        default: return defaultValue
        }
    }
}
