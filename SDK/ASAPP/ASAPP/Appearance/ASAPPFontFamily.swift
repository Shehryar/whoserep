//
//  ASAPPFontFamily.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation

/**
 Represents a font family used by default styles.`.
 */
@objc(ASAPPFontFamily)
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
    
    /// The lightest-weight italic style.
    public let lightItalic: UIFont?
    
    /// The second-lightest-weight italic style.
    public let regularItalic: UIFont?
    
    /// The second-heaviest-weight italic style.
    public let mediumItalic: UIFont?
    
    /// The heaviest-weight italic style.
    public let boldItalic: UIFont?
    
    // MARK: - Init
    
    /**
     Creates an `ASAPPFontFamily` instance given the `UIFont` for each weight.
     
     - parameter light: A light-weight `UIFont`.
     - parameter regular: A regular-weight `UIFont`.
     - parameter medium: A medium-weight or semi-bold `UIFont`.
     - parameter bold: A heavy-weight `UIFont`.
     - parameter lightItalic: A light-weight italic `UIFont`, optional.
     - parameter regularItalic: A regular-weight italic `UIFont`, optional.
     - parameter mediumItalic: A medium-weight or semi-bold italic `UIFont`, optional.
     - parameter boldItalic: A heavy-weight italic `UIFont`, optional.
     */
    public init(light: UIFont,
                regular: UIFont,
                medium: UIFont,
                bold: UIFont,
                lightItalic: UIFont? = nil,
                regularItalic: UIFont? = nil,
                mediumItalic: UIFont? = nil,
                boldItalic: UIFont? = nil) {
        self.light = light
        self.regular = regular
        self.medium = medium
        self.bold = bold
        self.lightItalic = lightItalic
        self.regularItalic = regularItalic
        self.mediumItalic = mediumItalic
        self.boldItalic = boldItalic
        
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
        lightItalic = UIFont(name: "Lato-LightItalic", size: 14)!
        regularItalic = UIFont(name: "Lato-Italic", size: 14)!
        mediumItalic = UIFont(name: "Lato-BoldItalic", size: 14)!
        boldItalic = UIFont(name: "Lato-BlackItalic", size: 14)!
        
        super.init()
    }
}
