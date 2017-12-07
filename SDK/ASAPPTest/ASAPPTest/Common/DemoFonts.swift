//
//  DemoFonts.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/24/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

class DemoFonts: NSObject {
    static let asapp = ASAPPFontFamily()
    
    static let boost = ASAPPFontFamily(
        light: UIFont(name: "SprintSans-Regular", size: 16)!,
        regular: UIFont(name: "SprintSans-Regular", size: 16)!,
        medium: UIFont(name: "SprintSans-Medium", size: 16)!,
        bold: UIFont(name: "SprintSans-Bold", size: 16)!)
}
