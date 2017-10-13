//
//  ASAPPButtonColors.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

/**
 Used for configuring the styles of a button. For example, assign an instance to `ASAPPColors.quickReplyButton`.
 */
@objcMembers
public class ASAPPButtonColors: NSObject {
    
    // MARK: Properties
    
    /// The color of the button's background.
    public var backgroundNormal: UIColor
    
    /// The color of the button's background when tapped or otherwise highlighted.
    public var backgroundHighlighted: UIColor
    
    /// The color of the button's background when disabled.
    public var backgroundDisabled: UIColor
    
    /// The color of the button's text.
    public var textNormal: UIColor
    
    /// The color of the button's text when tapped or otherwise highlighted.
    public var textHighlighted: UIColor
    
    /// The color of the button's text when disabled.
    public var textDisabled: UIColor
    
    /// The color of the button's border.
    public var border: UIColor?
    
    // MARK: - Init
    
    /**
     Creates an instance of `ASAPPButtonColors` with the given properties.
     
     - parameter backgroundNormal: The normal background color.
     - parameter backgroundHighlighted: The highlighted background color.
     - parameter backgroundDisabled: The disabled background color.
     - parameter textNormal: The normal text color.
     - parameter textHighlighted: The highlighted text color.
     - parameter border: The border color. Optional.
     */
    public init(backgroundNormal: UIColor,
                backgroundHighlighted: UIColor,
                backgroundDisabled: UIColor,
                textNormal: UIColor,
                textHighlighted: UIColor,
                textDisabled: UIColor,
                border: UIColor?) {
        self.backgroundNormal = backgroundNormal
        self.backgroundHighlighted = backgroundHighlighted
        self.backgroundDisabled = backgroundDisabled
        self.textNormal = textNormal
        self.textHighlighted = textHighlighted
        self.textDisabled = textDisabled
        self.border = border
        super.init()
    }
    
    /**
     Creates an instance of `ASAPPButtonColors` with a text color. Highlighted and disabled text colors
     are automatically generated. Background colors are set to `UIColor.clear`.
     
     - parameter textColor: The normal text color.
     */
    public init(textColor: UIColor) {
        self.backgroundNormal = UIColor.clear
        self.backgroundHighlighted = UIColor.clear
        self.backgroundDisabled = UIColor.clear
        
        self.textNormal = textColor
        self.textHighlighted = textColor.withAlphaComponent(0.6)
        self.textDisabled =  UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        
        super.init()
    }
    
    /**
     Creates an instance of `ASAPPButtonColors` with a background and text color. A highlighted background
     color and a disabled text color are automatically generated.
     
     - parameter backgroundColor: The background color.
     - parameter textColor: The text color.
     */
    public init(backgroundColor: UIColor, textColor: UIColor) {
        self.backgroundNormal = backgroundColor
        self.backgroundHighlighted = backgroundColor.highlightColor() ?? backgroundColor
        self.backgroundDisabled = backgroundColor
        
        self.textNormal = textColor
        self.textHighlighted = textColor
        self.textDisabled = textColor.withAlphaComponent(0.8)
        
        super.init()
    }
    
    /**
     Creates an instance of `ASAPPButtonColors` with a background, text, and border color. A highlighted
     background and disabled text color are automatically generated.
     
     - parameter backgroundColor: The background color.
     - parameter textColor: The text color.
     - parameter borderColor: The border color. Optional.
     */
    public init(backgroundColor: UIColor, textColor: UIColor, border: UIColor?) {
        self.backgroundNormal = backgroundColor
        self.backgroundHighlighted = backgroundColor.highlightColor() ?? backgroundColor
        self.backgroundDisabled = backgroundColor
        
        self.textNormal = textColor
        self.textHighlighted = textColor
        self.textDisabled = textColor.withAlphaComponent(0.8)
        
        self.border = border
        
        super.init()
    }
    
    /**
     Creates an instance of `ASAPPButtonColors` with a background color. A highlighted and a disabled background
     color are automatically generated. The text color is automatically set to `UIColor.white`.
     
     - parameter backgroundColor: The background color.
     */
    public init(backgroundColor: UIColor) {
        self.backgroundNormal = backgroundColor
        self.backgroundHighlighted = backgroundColor.highlightColor() ?? backgroundColor
        self.backgroundDisabled = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        
        self.textNormal = UIColor.white
        self.textHighlighted = UIColor.white
        self.textDisabled = UIColor.white.withAlphaComponent(0.8)
        
        super.init()
    }
}
