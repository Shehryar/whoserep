//
//  ASAPPFontFamily.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation
import UIKit

/**
 Represents a font family used by default styles.
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
     Creates an `ASAPPFontFamily` instance given the font name for each weight.
     
     - parameter light: name of light font file.
     - parameter regular: name of regular font file.
     - parameter medium: name of medium or semi-bold font file.
     - parameter bold: name of bold font file.
     */
    public init?(lightFontName: String,
                 regularFontName: String,
                 mediumFontName: String,
                 boldFontName: String) {
        guard let light = UIFont(name: lightFontName, size: 16),
            let medium = UIFont(name: lightFontName, size: 16),
            let regular = UIFont(name: lightFontName, size: 16),
            let bold = UIFont(name: lightFontName, size: 16) else { return nil }
        self.light = light
        self.medium = medium
        self.regular = regular
        self.bold = bold
        
        super.init()
    }
    
    /**
     Creates an `ASAPPFontFamily` instance representing the SDK's default font family (the system font).
     */
    public override init() {
        light = UIFont.systemFont(ofSize: 16, weight: .light)
        regular = UIFont.systemFont(ofSize: 16, weight: .regular)
        medium = UIFont.systemFont(ofSize: 16, weight: .bold)
        bold = UIFont.systemFont(ofSize: 16, weight: .heavy)
        
        super.init()
    }
}
