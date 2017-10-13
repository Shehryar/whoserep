//
//  ASAPPFontFamily.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation

/**
 Represents a font family used by default styles. Individual `ASAPPTextStyle`s will override the font family given to `ASAPPStyles.stylesForAppId(_:fontFamily:)`.
 */
@objcMembers
public class ASAPPFontFamily: NSObject {
    /// The lightest weight.
    public let light: UIFont
    
    /// The second-lightest weight, used for body text.
    public let regular: UIFont
    
    /// The second-heaviest weight.
    public let medium: UIFont
    
    /// The heaviest weight.
    public let bold: UIFont
    
    // MARK: - Init
    
    /**
     Creates an `ASAPPFontFamily` instance given the `UIFont` for each weight.
     
     - parameter light: A light-weight `UIFont`.
     - parameter regular: A regular-weight `UIFont`.
     - parameter medium: A medium-weight or semi-bold `UIFont`.
     - parameter bold: A heavy-weight `UIFont`.
     */
    public init(light: UIFont,
                regular: UIFont,
                medium: UIFont,
                bold: UIFont) {
        self.light = light
        self.regular = regular
        self.medium = medium
        self.bold = bold
        
        super.init()
    }
    
    /**
     Creates an `ASAPPFontFamily` instance representing the SDK's default font family.
     */
    public override init() {
        light = UIFont(name: "Lato-Light", size: 14)!
        regular = UIFont(name: "Lato-Regular", size: 14)!
        medium = UIFont(name: "Lato-Bold", size: 14)!
        bold = UIFont(name: "Lato-Black", size: 14)!
        
        super.init()
    }
}
