//
//  TextStyle.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

@objcMembers
public class ASAPPTextStyle: NSObject {
    
    // MARK: Properties (final)
    
    private(set) var defaultSize: CGFloat
    
    let letterSpacing: CGFloat
    
    let color: UIColor
    
    var font: UIFont {
        return fontRef.withSize(size)
    }
    
    private var fontRef: UIFont
    
    // MARK: Properties (dynamic)
    
    var size: CGFloat {
        return TextSizeCategory.dynamicFontSize(defaultSize)
    }
    
    // MARK: Init
    
    public init(font: UIFont, size: CGFloat, letterSpacing: CGFloat, color: UIColor) {
        self.defaultSize = size
        self.fontRef = font
        self.letterSpacing = letterSpacing
        self.color = color
        super.init()
    }
    
    internal func updateFont(_ font: UIFont) {
        self.defaultSize = font.pointSize
        self.fontRef = font
    }
}
