//
//  ASAPPButtonColors.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class ASAPPButtonColors: NSObject {
    
    // MARK: Properties
    
    public var backgroundNormal: UIColor
    
    public var backgroundHighlighted: UIColor
    
    public var backgroundDisabled: UIColor
    
    public var textNormal: UIColor
    
    public var textHighlighted: UIColor
    
    public var textDisabled: UIColor
    
    public var border: UIColor?
    
    // MARK:- Init
    
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
    
    public init(textColor: UIColor) {
        self.backgroundNormal = UIColor.clear
        self.backgroundHighlighted = UIColor.clear
        self.backgroundDisabled = UIColor.clear
        
        self.textNormal = textColor
        self.textHighlighted = textColor.withAlphaComponent(0.6)
        self.textDisabled =  UIColor(red:0.6, green:0.6, blue:0.6, alpha:1)
        
        super.init()
    }
    
    public init(backgroundColor: UIColor, textColor: UIColor) {
        self.backgroundNormal = backgroundColor
        self.backgroundHighlighted = backgroundColor.highlightColor() ?? backgroundColor
        self.backgroundDisabled = backgroundColor
        
        self.textNormal = textColor
        self.textHighlighted = textColor
        self.textDisabled = textColor.withAlphaComponent(0.8)
        
        super.init()
    }
    
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
    
    public init(backgroundColor: UIColor) {
        self.backgroundNormal = backgroundColor
        self.backgroundHighlighted = backgroundColor.highlightColor() ?? backgroundColor
        self.backgroundDisabled = UIColor(red:0.6, green:0.6, blue:0.6, alpha:1)
        
        self.textNormal = UIColor.white
        self.textHighlighted = UIColor.white
        self.textDisabled = UIColor.white.withAlphaComponent(0.8)
        
        super.init()
    }
}
