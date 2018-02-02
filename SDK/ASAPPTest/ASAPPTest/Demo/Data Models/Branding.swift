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
            .brandPrimary: UIColor(red: 0.33, green: 0.35, blue: 0.39, alpha: 1),
            .brandSecondary: UIColor.black,
            .textLight: UIColor.white,
            .textDark: UIColor.black
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
            styles = ASAPPStyles()
            styles.sendButtonImage = nil
            views.chatTitle = Branding.createASAPPTitle(colors: colors, styles: styles, fontFamily: appearanceConfig.fontFamily)
            strings.chatInputSend = "SEND"
            
        case .boost:
            styles = Branding.createBoostStyles(appearanceConfig)
            strings.chatInputSend = "SEND"
            
        case .telstra:
            styles = Branding.createTelstraStyles(appearanceConfig)
            strings.chatEndChatNavBarButton = "END"
        
        case .custom:
            styles = Branding.createCustomStyles(appearanceConfig)
        }
        
        if let helpButtonText = appearanceConfig.strings[.helpButton] {
            strings.asappButton = helpButtonText
        }
        strings.chatTitle = appearanceConfig.strings[.chatTitle]
        
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

extension Branding {
    // MARK: - per-client demo styles
    
    fileprivate class func createBoostStyles(_ config: AppearanceConfig) -> ASAPPStyles {
        let styles = createCustomStyles(config)
        
        // Boost special cases
        
        styles.segue = .present
        styles.sendButtonImage = nil
        
        return styles
    }
    
    fileprivate class func createTelstraStyles(_ config: AppearanceConfig) -> ASAPPStyles {
        let styles = createCustomStyles(config)
        
        let primary = config.getUIColor(.brandPrimary)
        
        // Telstra special cases
        
        styles.colors.navBarBackground = .white
        styles.colors.navBarTitle = primary
        styles.colors.navBarButton = primary
        styles.colors.quickReplyButton = ASAPPButtonColors(backgroundColor: .white, textColor: primary)
        
        return styles
    }
    
    fileprivate class func createCustomStyles(_ config: AppearanceConfig) -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        styles.textStyles.updateStyles(for: config.fontFamily)
        
        let primary = config.getUIColor(.brandPrimary)
        let secondary = config.getUIColor(.brandSecondary)
        let textLight = config.getUIColor(.textLight)
        let textDark = config.getUIColor(.textDark)
        let buttonTextColor = UIColor.white.chooseFirstAcceptableColor(of: [primary, secondary, textDark])
        
        styles.colors.controlTint = primary
        styles.colors.buttonPrimary = ASAPPButtonColors(backgroundColor: primary)
        styles.colors.textButtonPrimary = ASAPPButtonColors(textColor: buttonTextColor)
        styles.navBarStyles.buttonStyle = .text
        styles.colors.navBarBackground = primary
        styles.colors.navBarTitle = styles.colors.navBarBackground.chooseFirstAcceptableColor(of: [textLight, textDark], largeText: true)
        styles.colors.navBarButton = styles.colors.navBarTitle
        styles.colors.messageText = textDark.colorWithRelativeBrightness(0.33)!
        styles.colors.replyMessageText = textLight
        styles.colors.quickReplyButton = ASAPPButtonColors(backgroundColor: .white, textColor: buttonTextColor)
        styles.colors.helpButtonBackground = primary
        styles.colors.helpButtonText = primary.isDark() ? textLight : textDark
        
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
        
        let primary = config.getUIColor(.brandPrimary)
        let textLight = config.getUIColor(.textLight)
        let textDark = config.getUIColor(.textDark)
        let demoNavBar = config.getUIColor(.demoNavBar)
        let demoNavBarText = navBarColor.isBright()
                                ? primary.isDark() ? primary : textDark
                                : primary.isBright() ? primary : textLight
        
        navBarColor = demoNavBar
        navBarTintColor = demoNavBarText
        navBarTitleColor = demoNavBarText
        statusBarStyle = navBarColor.isDark() ? .lightContent : .default
        accentColor = primary
    }
}
