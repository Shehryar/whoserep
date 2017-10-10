//
//  ASAPPFontFamily.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation

@objcMembers
public class ASAPPFontFamily: NSObject {
    public let light: UIFont
    public let regular: UIFont
    public let medium: UIFont
    public let bold: UIFont
    
    // MARK:- Init
    
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
    
    public override init() {
        light = UIFont(name: "Lato-Light", size: 14)!
        regular = UIFont(name: "Lato-Regular", size: 14)!
        medium = UIFont(name: "Lato-Bold", size: 14)!
        bold = UIFont(name: "Lato-Black", size: 14)!
        
        super.init()
    }
}
