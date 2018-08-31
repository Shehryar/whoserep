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
    /// Case style of text.
    @objc(ASAPPCaseStyle)
    public enum ASAPPCaseStyle: Int {
        /// UPPERCASE
        case upper
        
        /// Start Case
        case start
        
        /// Original case, without Changes
        case original
    }
    
    // MARK: Properties (final)
    
    let letterSpacing: CGFloat
    
    var font: UIFont {
        return fontRef.changingOnlySize(size)
    }
    
    private(set) var defaultSize: CGFloat
    
    private(set) var `case`: ASAPPCaseStyle
    
    private(set) var color: UIColor
    
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
     - parameter case: The case style. Defaults to .original.
     */
    public init(font: UIFont, size: CGFloat, letterSpacing: CGFloat, color: UIColor, case: ASAPPCaseStyle = .original) {
        self.defaultSize = size
        self.fontRef = font
        self.letterSpacing = letterSpacing
        self.color = color
        self.case = `case`
        super.init()
    }
    
    internal func updateFont(_ font: UIFont) {
        self.fontRef = font
    }
    
    internal func updateColor(_ color: UIColor) {
        self.color = color
    }
}
