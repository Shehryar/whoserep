//
//  ASAPPInputColors.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

@objcMembers
public class ASAPPInputColors: NSObject {
    
    // MARK: Properties
    
    public var background: UIColor
    
    public var text: UIColor
    
    public var placeholderText: UIColor
    
    public var tint: UIColor
    
    public var border: UIColor?
    
    public var primaryButton: UIColor
    
    public var secondaryButton: UIColor
    
    // MARK: Init
    
    public init(background: UIColor,
                text: UIColor,
                placeholderText: UIColor,
                tint: UIColor,
                border: UIColor?,
                primaryButton: UIColor,
                secondaryButton: UIColor) {
        self.background = background
        self.text = text
        self.placeholderText = placeholderText
        self.tint = tint
        self.border = border
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        super.init()
    }
}
