//
//  BrandingSettings.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 2/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit
import ASAPP

/**
 BrandingType
 */

enum BrandingType {
    case asapp
    case xfinity
    case sprint
    case boostMobile
    
    static let all = [
        asapp,
        xfinity,
        sprint,
        boostMobile
    ]
}

/**
 Branding
 */

class Branding: NSObject {

    let brandingType: BrandingType
    
    var logoImageSize: CGSize!
    
    var logoImageName: String!
    
    let colors: BrandingColors
    
    let fonts: BrandingFonts
    
    // MARK:- Init
    
    required init(brandingType: BrandingType) {
        self.brandingType = brandingType
        self.colors = BrandingColors(brandingType: brandingType)
        self.fonts = BrandingFonts(brandingType: brandingType)
        super.init()
        
        switch self.brandingType {
        case .asapp:
            logoImageName = "asapp-logo"
            logoImageSize = CGSize(width: 100, height: 22)
            break
            
        case .xfinity:
            logoImageName = "comcast-logo"
            logoImageSize = CGSize(width: 140, height: 28)
            break
            
        case .sprint:
            logoImageName = "sprint-logo"
            logoImageSize = CGSize(width: 140, height: 36)
            break
            
        case .boostMobile:
            logoImageName = "boost-logo"
            logoImageSize = CGSize(width: 140, height: 42)
            break
        }
    }
}

/**
 Branding Colors
 */

class BrandingColors: NSObject {
    
    let brandingType: BrandingType
    
    private(set) var styles: ASAPPStyles
    
    private(set) var backgroundColor: UIColor = UIColor.white
    private(set) var backgroundColor2: UIColor = UIColor(red:0.941, green:0.937, blue:0.949, alpha:1)
    private(set) var foregroundColor: UIColor = UIColor(red:0.220, green:0.231, blue:0.263, alpha:1)
    private(set) var foregroundColor2: UIColor = UIColor(red:0.483, green:0.505, blue:0.572, alpha:1)
    private(set) var separatorColor: UIColor = UIColor(red:0.874, green:0.875, blue:0.874, alpha:1)
    private(set) var accentColor: UIColor = UIColor(red:0.266, green:0.808, blue:0.600, alpha:1)
    private(set) var navBarColor: UIColor = UIColor.white
    private(set) var navBarTintColor: UIColor = UIColor(red:0.220, green:0.231, blue:0.265, alpha:1)
    private(set) var navBarTitleColor: UIColor = UIColor(red:0.220, green:0.231, blue:0.263, alpha:1)
    private(set) var statusBarStyle: UIStatusBarStyle = .default
    
    var isDarkNavStyle: Bool { return navBarColor.isDark() }
    var isDarkContentStyle: Bool  { return backgroundColor.isDark() }
    
    // MARK:- Init
    
    required init(brandingType: BrandingType) {
        self.brandingType = brandingType
        self.styles = ASAPPStyles()
        super.init()
        
        switch self.brandingType {
        case .asapp:
            
            break
            
        case .xfinity:
            styles = ASAPP.stylesForCompany("comcast")
            
            navBarColor = UIColor(red:0.074, green:0.075, blue:0.074, alpha:1)
            navBarTintColor = UIColor.white
            navBarTitleColor = UIColor.white
            statusBarStyle = .lightContent
            
            foregroundColor = UIColor(red:0.027, green:0.027, blue:0.027, alpha:1)
            foregroundColor2 = UIColor(red:0.580, green:0.580, blue:0.580, alpha:1)
            backgroundColor = UIColor.white
            backgroundColor2 = UIColor(red:0.898, green:0.898, blue:0.898, alpha:1)
            separatorColor = UIColor(red:0.772, green:0.773, blue:0.772, alpha:1)
            accentColor = UIColor(red:1, green:0.216, blue:0.212, alpha:1)
            break
            
        case .sprint:
            styles = ASAPP.stylesForCompany("sprint")
            
            navBarTintColor = UIColor.darkGray
            navBarTitleColor = UIColor.black
        
            foregroundColor = UIColor(red:0, green:0, blue:0, alpha:1)
            foregroundColor2 = UIColor(red:0.490, green:0.490, blue:0.490, alpha:1)
            backgroundColor = UIColor.white
            separatorColor = UIColor(red:0.882, green:0.882, blue:0.882, alpha:1)
            accentColor = UIColor(red:0.989, green:0.811, blue:0.003, alpha:1)
            break
            
        case .boostMobile:
            styles = ASAPP.stylesForCompany("sprint")
            
            navBarTintColor = UIColor.darkGray
            navBarTitleColor = UIColor.black
            
            foregroundColor = UIColor(red:0, green:0, blue:0, alpha:1)
            foregroundColor2 = UIColor(red:0.490, green:0.490, blue:0.490, alpha:1)
            backgroundColor = UIColor.white
            separatorColor = UIColor(red:0.882, green:0.882, blue:0.882, alpha:1)
            accentColor = UIColor(red:0.989, green:0.811, blue:0.003, alpha:1)
            break
        }
    }
}

/**
 Branding Fonts
 */

class BrandingFonts: NSObject {
    
    let brandingType: BrandingType
    
    private(set) var lightFont: UIFont = DemoFonts.latoLightFont(withSize: 14)
    private(set) var regularFont: UIFont = DemoFonts.latoRegularFont(withSize: 14)
    private(set) var mediumFont: UIFont = DemoFonts.latoRegularFont(withSize: 14)
    private(set) var boldFont: UIFont = DemoFonts.latoBoldFont(withSize: 14)
    
    // MARK:- Init
    
    required init(brandingType: BrandingType) {
        self.brandingType = brandingType
        super.init()
        
        switch self.brandingType {
        case .asapp:
            // Defaults
            break
            
        case .xfinity:
//            lightFont = DemoFonts.xfinitySansLgtFont()
//            regularFont = DemoFonts.xfinitySansRegFont()
//            mediumFont = DemoFonts.xfinitySansMedFont()
//            boldFont = DemoFonts.xfinitySansBoldFont()
            break
            
        case .sprint, .boostMobile:
//            lightFont = DemoFonts.sprintSansRegularFont()
//            regularFont = DemoFonts.sprintSansRegularFont()
//            mediumFont = DemoFonts.sprintSansMediumFont()
//            boldFont = DemoFonts.sprintSansBoldFont()
            break
        }
    }
}
