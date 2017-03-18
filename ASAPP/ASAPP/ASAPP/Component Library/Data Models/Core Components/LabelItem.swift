//
//  LabelItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class LabelItem: NSObject, Component {
    
    enum FontStyle: String {
        case light = "light"
        case regular = "regular"
        case bold = "bold"
        case black = "black"
        
        static func from(_ string: String?, defaultValue: FontStyle = regular) -> FontStyle {
            guard let string = string,
                let style = FontStyle(rawValue: string) else {
                    return defaultValue
            }
            return style
        }
    }
    
    // MARK: Properties
    
    let text: String
    
    let alignment: NSTextAlignment
    
    let fontStyle: FontStyle
    
    let size: CGFloat
    
    let color: UIColor?
    
    let letterSpacing: CGFloat
    
    // MARK: Component Properties
    
    let type = ComponentType.label
    
    let layout: ComponentLayout
    
    // MARK: Init
    
    init(text: String,
         alignment: NSTextAlignment,
         fontStyle: FontStyle,
         size: CGFloat,
         color: UIColor?,
         letterSpacing: CGFloat,
         layout: ComponentLayout) {
        self.text = text
        self.alignment = alignment
        self.fontStyle = fontStyle
        self.size = size
        self.color = color
        self.letterSpacing = letterSpacing
        self.layout = layout
        super.init()
    }
    
    // MARK:- Component Parsing
    
    static let defaultAlignment = NSTextAlignment.center
    static let defaultFontStyle = FontStyle.regular
    static let defaultSize: CGFloat = 15
    static let defaultLetterSpacing: CGFloat = 0

    static func make(with content: [String : AnyObject]?, layout: ComponentLayout) -> Component? {
        guard let content = content else {
            return nil
        }
        guard let text = content["text"] as? String else {
            DebugLog.w(caller: self, "Missing text: \(content)")
            return nil
        }
        
        let alignment = NSTextAlignment.from(content["alignment"] as? String,
                                             defaultValue: defaultAlignment)
        let fontStyle = FontStyle.from(content["font_style"] as? String,
                                       defaultValue: defaultFontStyle)
        let size = (content["size"] as? CGFloat) ?? defaultSize
        let color = UIColor.colorFromHex(hex: content["color"] as? String)
        let letterSpacing = (content["letter_spacing"] as? CGFloat) ?? defaultLetterSpacing
        
        return LabelItem(text: text,
                         alignment: alignment,
                         fontStyle: fontStyle,
                         size: size,
                         color: color,
                         letterSpacing: letterSpacing,
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
