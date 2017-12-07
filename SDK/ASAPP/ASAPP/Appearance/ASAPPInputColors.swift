//
//  ASAPPInputColors.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

/**
 Used to configure the colors of text input area in the predictive view and chat view.
 */
@objcMembers
public class ASAPPInputColors: NSObject {
    
    // MARK: Properties
    
    /// The color of the background of the input area.
    public var background: UIColor
    
    /// The color of the text.
    public var text: UIColor
    
    /// The color of the placeholder text, visible before anything has been typed.
    public var placeholderText: UIColor
    
    /// The tint color of the text area (used by the cursor).
    public var tint: UIColor
    
    /// The color of the border of the text area.
    public var border: UIColor?
    
    /// The fill (or text) color of the send button.
    public var primaryButton: UIColor
    
    /// The color of the media attachment button.
    public var secondaryButton: UIColor
    
    // MARK: Init
    
    /**
     Creates an instance of `ASAPPInputColors` with the given parameters.
     
     - parameter background: The background color.
     - parameter placeholderText: The placeholder text color.
     - parameter tint: The tint color.
     - parameter border: The border color.
     - parameter primaryButton: The primary button color.
     - parameter secondaryButton: The secondary button color.
     */
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
