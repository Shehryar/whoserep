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
    static let asapp = ASAPPFontFamily(
        light: UIFont(name: "Lato-Light", size: 14)!,
        regular: UIFont(name: "Lato-Regular", size: 14)!,
        medium: UIFont(name: "Lato-Bold", size: 14)!,
        bold: UIFont(name: "Lato-Black", size: 14)!)
    
    static let boost = ASAPPFontFamily(
        light: UIFont(name: "SprintSans-Regular", size: 16)!,
        regular: UIFont(name: "SprintSans-Regular", size: 16)!,
        medium: UIFont(name: "SprintSans-Medium", size: 16)!,
        bold: UIFont(name: "SprintSans-Bold", size: 16)!)
    
    static let roboto = ASAPPFontFamily(
        light: UIFont(name: "Roboto-Light", size: 16)!,
        regular: UIFont(name: "Roboto-Regular", size: 16)!,
        medium: UIFont(name: "Roboto-Medium", size: 16)!,
        bold: UIFont(name: "Roboto-Bold", size: 16)!)
    
    static let neueHaasGrotesk = ASAPPFontFamily(
        light: UIFont(name: "NHaasGroteskDSStd-55Rg", size: 16)!,
        regular: UIFont(name: "NHaasGroteskDSStd-55Rg", size: 16)!,
        medium: UIFont(name: "NHaasGroteskDSStd-65Md", size: 16)!,
        bold: UIFont(name: "NHaasGroteskDSStd-75Bd", size: 16)!)
    
    static let system = ASAPPFontFamily(
        light: UIFont.systemFont(ofSize: 16, weight: .light),
        regular: UIFont.systemFont(ofSize: 16, weight: .regular),
        medium: UIFont.systemFont(ofSize: 16, weight: .bold),
        bold: UIFont.systemFont(ofSize: 16, weight: .heavy))
}
