//
//  BrandingSettings.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 2/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit
import ASAPP

// MARK: - Branding

class Branding: NSObject {

    let appearanceConfig: AppearanceConfig
    
    var fontFamily: ASAPPFontFamily {
        return appearanceConfig.fontFamily
    }
    
    static var defaultColors: [AppearanceConfig.ColorName: Color] = {
        let asappColors = ASAPPColors()
        let dict: [AppearanceConfig.ColorName: UIColor] = [
            .demoNavBar: UIColor.white,
            .primary: UIColor(red: 0.33, green: 0.35, blue: 0.39, alpha: 1),
            .dark: UIColor.black
        ]
        return dict.mapValues { Color(uiColor: $0)! }
    }()
    
    let colors: BrandingColors
    
    let styles: ASAPPStyles
    
    let strings: ASAPPStrings
    
    let views: ASAPPViews
    
    // MARK: - Init
    
    required init(appearanceConfig: AppearanceConfig) {
        self.appearanceConfig = appearanceConfig
        colors = BrandingColors(appearanceConfig: appearanceConfig)
        strings = ASAPPStrings()
        views = ASAPPViews()
        
        switch appearanceConfig.brand {
        case .asapp:
            styles = Branding.createASAPPStyles(appearanceConfig)
            views.chatTitle = Branding.createChatTitle(image: #imageLiteral(resourceName: "asapp-logo"), frame: CGRect(x: 0, y: 7, width: 76, height: 14.6))
            
        case .boost:
            styles = Branding.createSpearStyles(appearanceConfig)
            
        case .cairo:
            styles = Branding.createCairoStyles(appearanceConfig)
            
        case .telstra:
            styles = Branding.createTetrisStyles(appearanceConfig)
            
        case .verizon:
            styles = Branding.createRomeStyles(appearanceConfig)
            views.chatTitle = Branding.createChatTitle(image: #imageLiteral(resourceName: "fios-logo"), frame: CGRect(x: 0, y: 5, width: 48, height: 20))
        
        case .custom:
            styles = Branding.createCustomStyles(appearanceConfig)
        }
        
        strings.chatTitle = appearanceConfig.strings[.chatTitle]
        
        super.init()
    }
    
    private class func createChatTitle(image: UIImage, frame: CGRect) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        
        let logo = UIImageView(image: image)
        var logoFrame = frame
        logoFrame.origin.x = logoFrame.size.width / -2
        logo.frame = logoFrame
        
        container.addSubview(logo)
        container.sizeToFit()
        
        return container
    }
}

extension Branding {
    // MARK: - per-client demo styles
    
    fileprivate class func createASAPPStyles(_ config: AppearanceConfig) -> ASAPPStyles {
        let styles = ASAPPStyles()
        styles.textStyles.updateStyles(for: config.fontFamily)
        return styles
    }
    
    fileprivate class func createSpearStyles(_ config: AppearanceConfig) -> ASAPPStyles {
        let styles = createCustomStyles(config)
        
        // Boost special cases
        
        // space left intentionally blank
        
        return styles
    }
    
    fileprivate class func createCairoStyles(_ config: AppearanceConfig) -> ASAPPStyles {
        let styles = createCustomStyles(config)
        
        // Cairo special cases
        
        styles.primaryButtonRoundingStyle = .radius(4)
        
        let primary = config.getUIColor(.primary)
        let highlightedBlue = UIColor(red: 0, green: 0.55, blue: 1, alpha: 1)
        let disabledGrey = UIColor(red: 0.39, green: 0.45, blue: 0.54, alpha: 1)
        let backgroundGrey = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        
        styles.colors.replyMessageBackground = UIColor(red: 0.85, green: 0.87, blue: 0.9, alpha: 1)
        styles.colors.messagesListGradientColors = [backgroundGrey, backgroundGrey]
        
        styles.colors.buttonPrimary = ASAPPButtonColors(
            backgroundNormal: primary,
            backgroundHighlighted: highlightedBlue,
            backgroundDisabled: UIColor(red: 0.85, green: 0.87, blue: 0.9, alpha: 1),
            textNormal: .white,
            textHighlighted: .white,
            textDisabled: disabledGrey,
            border: nil)
        
        styles.colors.buttonSecondary = ASAPPButtonColors(
            backgroundColor: .clear,
            textColor: primary,
            border: primary)
        
        styles.colors.textButtonPrimary = ASAPPButtonColors(
            backgroundNormal: .clear,
            backgroundHighlighted: .clear,
            backgroundDisabled: .clear,
            textNormal: primary,
            textHighlighted: highlightedBlue,
            textDisabled: disabledGrey,
            border: nil)
        
        styles.textStyles.button = ASAPPTextStyle(font: config.fontFamily.medium, size: 16, letterSpacing: 0.2, color: primary, case: .start)
        styles.textStyles.link = ASAPPTextStyle(font: config.fontFamily.medium, size: 16, letterSpacing: 0.2, color: primary, case: .start)
        
        return styles
    }
    
    fileprivate class func createTetrisStyles(_ config: AppearanceConfig) -> ASAPPStyles {
        let styles = createCustomStyles(config)
        
        // Telstra special cases
        
        let primary = config.getUIColor(.primary)
        styles.colors.navBarTitle = primary
        styles.colors.navBarButton = primary
        
        return styles
    }
    
    fileprivate class func createRomeStyles(_ config: AppearanceConfig) -> ASAPPStyles {
        let styles = createCustomStyles(config)
        
        // Verizon special cases
        
        styles.primaryButtonRoundingStyle = .pill
        
        styles.textStyles.header1 = ASAPPTextStyle(font: config.fontFamily.regular, size: 24, letterSpacing: 0, color: UIColor.black.withAlphaComponent(0.9))
        styles.textStyles.header2 = ASAPPTextStyle(font: config.fontFamily.bold, size: 22, letterSpacing: 0, color: .black)
        styles.textStyles.header3 = ASAPPTextStyle(font: config.fontFamily.medium, size: 18, letterSpacing: 0, color: .black)
        styles.textStyles.subheader = ASAPPTextStyle(font: config.fontFamily.medium, size: 11, letterSpacing: 0, color: UIColor.black.withAlphaComponent(0.5))
        styles.textStyles.body = ASAPPTextStyle(font: config.fontFamily.regular, size: 16, letterSpacing: 0, color: UIColor.black.withAlphaComponent(0.85))
        styles.textStyles.bodyBold  = ASAPPTextStyle(font: config.fontFamily.medium, size: 16, letterSpacing: 0, color: .black)
        styles.textStyles.body2 = ASAPPTextStyle(font: config.fontFamily.regular, size: 15, letterSpacing: 0, color: UIColor.black.withAlphaComponent(0.85))
        styles.textStyles.bodyBold2 = ASAPPTextStyle(font: config.fontFamily.medium, size: 15, letterSpacing: 0, color: .black)
        styles.textStyles.detail1 = ASAPPTextStyle(font: config.fontFamily.regular, size: 13, letterSpacing: 0, color: UIColor.black.withAlphaComponent(0.55))
        styles.textStyles.detail2 = ASAPPTextStyle(font: config.fontFamily.regular, size: 12, letterSpacing: 0, color: UIColor.black.withAlphaComponent(0.55))
        
        styles.colors.warning = UIColor(red: 0.8, green: 0.02, blue: 0.04, alpha: 1)
        styles.allowedOrientations = .iPadLandscapeAllowed
        
        return styles
    }
    
    fileprivate class func createCustomStyles(_ config: AppearanceConfig) -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        styles.textStyles.updateStyles(for: config.fontFamily)
        
        let primary = config.getUIColor(.primary)
        let dark = config.getUIColor(.dark)
        
        styles.colors.primary = primary
        styles.colors.dark = dark
        styles.textStyles.updateColors(with: dark)
        
        return styles
    }
}

class BrandingColors: NSObject {
    
    let appearanceConfig: AppearanceConfig
    
    private(set) var backgroundColor = UIColor.white
    private(set) var secondaryBackgroundColor = UIColor(red: 0.941, green: 0.937, blue: 0.949, alpha: 1)
    private(set) var foregroundColor = UIColor.black
    private(set) var secondaryTextColor = UIColor(red: 0.490, green: 0.490, blue: 0.490, alpha: 1)
    private(set) var separatorColor = UIColor(red: 0.882, green: 0.882, blue: 0.882, alpha: 1)
    private(set) var accentColor = UIColor(red: 0.266, green: 0.808, blue: 0.600, alpha: 1)
    private(set) var navBarColor = UIColor.white
    private(set) var navBarTintColor = UIColor(red: 0.220, green: 0.231, blue: 0.265, alpha: 1)
    private(set) var navBarTitleColor = UIColor(red: 0.220, green: 0.231, blue: 0.263, alpha: 1)
    private(set) var statusBarStyle = UIStatusBarStyle.default
    
    var isDarkNavStyle: Bool { return navBarColor.isDark() }
    var isDarkContentStyle: Bool { return backgroundColor.isDark() }
    
    // MARK: - Init
    
    required init(appearanceConfig config: AppearanceConfig) {
        self.appearanceConfig = config
        super.init()
        
        let primary = config.getUIColor(.primary)
        let textLight = UIColor.white
        let textDark = config.getUIColor(.dark)
        let demoNavBar = config.getUIColor(.demoNavBar)
        let demoNavBarText = demoNavBar.chooseFirstAcceptableColor(of: [primary, textDark, textLight], largeText: true)
        
        navBarColor = demoNavBar
        navBarTintColor = demoNavBarText
        navBarTitleColor = demoNavBarText
        statusBarStyle = navBarColor.isDark() ? .lightContent : .default
        accentColor = primary
    }
}
