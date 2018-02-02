//
//  AppearanceConfig.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 12/7/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation
import UIKit
import ASAPP

struct AppearanceConfig: Codable {
    enum Brand: Int, CountableEnum, Codable {
        case asapp
        case boost
        case telstra
        case custom
    }
    
    enum ColorName: Int, CountableEnum, Codable {
        case demoNavBar
        case brandPrimary
        case brandSecondary
        case textDark
        case textLight
    }
    
    enum FontFamilyName: Int, CountableEnum, Codable {
        case asapp
        case boost
        case roboto
    }
    
    enum StringName: Int, CountableEnum, Codable {
        case helpButton
        case chatTitle
    }
    
    let name: String
    let brand: Brand
    let logo: Image
    let colors: [ColorName: Color]
    let strings: [StringName: String]
    let fontFamilyName: FontFamilyName
}

extension AppearanceConfig {
    var fontFamily: ASAPPFontFamily {
        return AppearanceConfig.fontFamily(for: fontFamilyName)
    }
    
    static func fontFamily(for name: FontFamilyName) -> ASAPPFontFamily {
        switch name {
        case .asapp:
            return DemoFonts.asapp
        case .boost:
            return DemoFonts.boost
        case .roboto:
            return DemoFonts.roboto
        }
    }
    
    var logoImage: UIImage {
        return logo.uiImage
    }
    
    func getUIColor(_ colorName: AppearanceConfig.ColorName) -> UIColor {
        let color = colors[colorName]
        let defaultColor = Branding.defaultColors[colorName]!
        return (color ?? defaultColor)!.uiColor
    }
}

extension AppearanceConfig: Equatable {
    static func == (lhs: AppearanceConfig, rhs: AppearanceConfig) -> Bool {
        return lhs.name == rhs.name &&
               lhs.brand == rhs.brand &&
               lhs.logo.id == rhs.logo.id &&
               lhs.colors == rhs.colors &&
               lhs.strings == rhs.strings &&
               lhs.fontFamilyName == rhs.fontFamilyName
    }
}
