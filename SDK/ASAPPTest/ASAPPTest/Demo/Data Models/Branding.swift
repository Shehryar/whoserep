//
//  BrandingSettings.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 2/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit
import ASAPP

enum BrandingType: String {
    case asapp
    case xfinity = "comcast"
    case boost
    
    static let all = [
        asapp,
        xfinity,
        boost
    ]
    
    static func from(_ value: Any?) -> BrandingType? {
        guard let value = value as? String else {
            return nil
        }
        return BrandingType(rawValue: value)
    }
}

// MARK:- Branding

class Branding: NSObject {

    let brandingType: BrandingType
    
    var logoImageSize: CGSize!
    
    var logoImageName: String!
    
    var logoImage: UIImage? {
        return UIImage(named: logoImageName)
    }
    
    let colors: BrandingColors
    
    let fontFamily: ASAPPFontFamily
    
    let styles: ASAPPStyles
    
    let strings: ASAPPStrings
    
    let views: ASAPPViews
    
    // MARK:- Init
    
    required init(brandingType: BrandingType) {
        self.brandingType = brandingType
        colors = BrandingColors(brandingType: brandingType)
        strings = ASAPPStrings()
        views = ASAPPViews()
        
        switch brandingType {
        case .asapp:
            fontFamily = DemoFonts.asapp
            styles = ASAPPStyles.stylesForAppId(brandingType.rawValue)
            logoImageName = "asapp-logo"
            logoImageSize = CGSize(width: 115, height: 22)
            views.chatTitle = Branding.createASAPPTitle(colors: colors, styles: styles, fontFamily: fontFamily)
        case .xfinity:
            fontFamily = DemoFonts.xfinity
            styles = ASAPPStyles.stylesForAppId(brandingType.rawValue, fontFamily: fontFamily)
            logoImageName = "comcast-logo"
            logoImageSize = CGSize(width: 86, height: 28)
            strings.chatTitle = "XFINITY Assistant"
            strings.predictiveTitle = "XFINITY Assistant"
            strings.predictiveBackToChatButton = "History"
            strings.chatEmptyMessage = "Tap 'Ask' to get started."
            strings.chatAskNavBarButton = "Ask"
            strings.chatEndChatNavBarButton = "End Chat"
        case .boost:
            fontFamily = DemoFonts.boost
            styles = ASAPPStyles.stylesForAppId(brandingType.rawValue, fontFamily: fontFamily)
            let boostMedium = UIFont(name: "BoostNeo-Bold", size: 30)!
            styles.textStyles.predictiveHeader = ASAPPTextStyle(font: boostMedium, size: 30, letterSpacing: 0.9, color: .white)
            logoImageName = "boost-logo-light"
            logoImageSize = CGSize(width: 109, height: 32)
        }
        
        super.init()
    }
    
    private class func createASAPPTitle(colors: BrandingColors, styles: ASAPPStyles, fontFamily: ASAPPFontFamily) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        
        let text = UILabel()
        text.text = "Help"
        text.font = fontFamily.regular.withSize(22)
        text.textColor = colors.navBarTitleColor
        let textSize = text.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: 44.0))
        
        let spacing: CGFloat = 5
        
        let logo = UIImageView(image: #imageLiteral(resourceName: "asapp-logo"))
        var logoFrame = CGRect(x: 0, y: 7, width: 87.6, height: 16.8)
        logoFrame.origin.x = (logoFrame.size.width + spacing + textSize.width) / -2
        logo.frame = logoFrame
        
        text.frame = CGRect(origin: CGPoint(x: logo.frame.maxX + spacing, y: 2), size: textSize)
        
        container.addSubview(logo)
        container.addSubview(text)
        container.sizeToFit()
        
        return container
    }
}

class BrandingColors: NSObject {
    
    let brandingType: BrandingType
    
    private(set) var backgroundColor: UIColor = UIColor.white
    private(set) var secondaryBackgroundColor: UIColor = UIColor(red: 0.941, green: 0.937, blue: 0.949, alpha: 1)
    private(set) var foregroundColor: UIColor = UIColor(red: 0.220, green: 0.231, blue: 0.263, alpha: 1)
    private(set) var secondaryTextColor: UIColor = UIColor(red: 0.483, green: 0.505, blue: 0.572, alpha: 1)
    private(set) var separatorColor: UIColor = UIColor(red: 0.874, green: 0.875, blue: 0.874, alpha: 1)
    private(set) var accentColor: UIColor = UIColor(red: 0.266, green: 0.808, blue: 0.600, alpha: 1)
    private(set) var navBarColor: UIColor = UIColor.white
    private(set) var navBarTintColor: UIColor = UIColor(red: 0.220, green: 0.231, blue: 0.265, alpha: 1)
    private(set) var navBarTitleColor: UIColor = UIColor(red: 0.220, green: 0.231, blue: 0.263, alpha: 1)
    private(set) var statusBarStyle: UIStatusBarStyle = .default
    
    var isDarkNavStyle: Bool { return navBarColor.isDark() }
    var isDarkContentStyle: Bool { return backgroundColor.isDark() }
    
    // MARK:- Init
    
    required init(brandingType: BrandingType) {
        self.brandingType = brandingType
        super.init()
        
        switch self.brandingType {
        case .asapp:
            break
            
        case .xfinity:
            navBarColor = UIColor(red: 0.169, green: 0.204, blue: 0.263, alpha: 1)
            navBarTintColor = UIColor.white
            navBarTitleColor = UIColor.white
            statusBarStyle = .lightContent
            
            foregroundColor = UIColor(red: 0.027, green: 0.027, blue: 0.027, alpha: 1)
            secondaryTextColor = UIColor(red: 0.580, green: 0.580, blue: 0.580, alpha: 1)
            backgroundColor = UIColor.white
            secondaryBackgroundColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
            separatorColor = UIColor(red: 0.772, green: 0.773, blue: 0.772, alpha: 1)
            accentColor = UIColor(red: 0.000, green: 0.443, blue: 0.710, alpha: 1)
            
        case .boost:
            navBarColor = UIColor(red: 0.01, green: 0.01, blue: 0.01, alpha: 1)
            navBarTintColor = UIColor.white
            navBarTitleColor = UIColor.white
            statusBarStyle = .lightContent
            
            foregroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            secondaryTextColor = UIColor(red: 0.490, green: 0.490, blue: 0.490, alpha: 1)
            backgroundColor = UIColor.white
            separatorColor = UIColor(red: 0.882, green: 0.882, blue: 0.882, alpha: 1)
            accentColor = UIColor(red: 0.961, green: 0.514, blue: 0.071, alpha: 1)
        }
    }
}
