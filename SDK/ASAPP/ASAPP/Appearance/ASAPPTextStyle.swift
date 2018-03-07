//
//  TextStyle.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

/**
 Used to define a text style.
 */
@objc(ASAPPTextStyle)
@objcMembers
public class ASAPPTextStyle: NSObject {
    
    // MARK: Properties (final)
    
    private(set) var defaultSize: CGFloat
    
    let letterSpacing: CGFloat
    
    let color: UIColor
    
    var font: UIFont {
        return fontRef.withSize(size)
    }
    
    private(set) var uppercase: Bool = false
    
    private var fontRef: UIFont
    
    // MARK: Properties (dynamic)
    
    var size: CGFloat {
        return TextSizeCategory.dynamicFontSize(defaultSize)
    }
    
    // MARK: Init
    
    /**
     Creates an instance of `ASAPPTextStyle` with the given parameters.
     
     - parameter font: The font.
     - parameter size: The default size.
     - parameter letterSpacing: The amount of space between characters.
     - parameter color: The text color.
     - parameter uppercase: Whether the text is rendered as all uppercase.
     */
    public init(font: UIFont, size: CGFloat, letterSpacing: CGFloat, color: UIColor, uppercase: Bool = false) {
        self.defaultSize = size
        self.fontRef = font
        self.letterSpacing = letterSpacing
        self.color = color
        self.uppercase = uppercase
        super.init()
    }
    
    internal func updateFont(_ font: UIFont) {
        self.fontRef = font
    }
}
