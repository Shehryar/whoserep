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
        case verizon
        case cairo
    }
    
    enum ColorName: Int, CountableEnum, Codable {
        case demoNavBar
        case primary
        case dark
    }
    
    enum FontFamilyName: Int, CountableEnum, Codable {
        case asapp
        case boost
        case roboto
        case neueHaasGrotesk
        case system
    }
    
    enum StringName: Int, CountableEnum, Codable {
        case helpButton
        case chatTitle
    }
    
    enum Segue: Int, CountableEnum, Codable {
        case present
        case push
    }
    
    let name: String
    let brand: Brand
    let logo: Image
    let colors: [ColorName: Color]
    let strings: [StringName: String]
    let fontFamilyName: FontFamilyName
    let segue: Segue
    let version: Int
}

extension AppearanceConfig {
    static let lastChangedVersion = 181
    
    var isValid: Bool {
        return version >= AppearanceConfig.lastChangedVersion
    }
    
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
        case .neueHaasGrotesk:
            return DemoFonts.neueHaasGrotesk
        case .system:
            return DemoFonts.system
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
    
    static func create(name: String, brand: Brand, logo: Image, colors: [ColorName: Color] = [:], strings: [StringName: String] = [:], fontFamilyName: FontFamilyName = .asapp, segue: Segue = .push) -> AppearanceConfig {
        return AppearanceConfig(name: name, brand: brand, logo: logo, colors: colors, strings: strings, fontFamilyName: fontFamilyName, segue: segue, version: Bundle.main.buildVersion)
    }
}

extension AppearanceConfig: Equatable {
    static func == (lhs: AppearanceConfig, rhs: AppearanceConfig) -> Bool {
        return lhs.name == rhs.name &&
               lhs.brand == rhs.brand &&
               lhs.logo.id == rhs.logo.id &&
               lhs.colors == rhs.colors &&
               lhs.strings == rhs.strings &&
               lhs.fontFamilyName == rhs.fontFamilyName &&
               lhs.version == rhs.version
    }
}

extension Bundle {
    var buildVersion: Int {
        return Int(infoDictionary?["CFBundleVersion"] as? String ?? "") ?? 0
    }
}
