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
            strings.predictiveSendButton = "SEND"
            strings.chatInputSend = "SEND"
            
        case .boost:
            styles = Branding.createBoostStyles(appearanceConfig)
            strings.predictiveSendButton = "SEND"
            strings.chatInputSend = "SEND"
            
        case .telstra:
            styles = Branding.createTelstraStyles(appearanceConfig)
            strings.chatEndChatNavBarButton = "END"
            strings.predictiveWelcomeText = "Talk to us."
            strings.predictiveOtherSuggestions = "What can our agents help you with?"
        
        case .custom:
            styles = Branding.createCustomStyles(appearanceConfig)
        }
        
        if let helpButtonText = appearanceConfig.strings[.helpButton] {
            strings.asappButton = helpButtonText
        }
        strings.chatTitle = appearanceConfig.strings[.chatTitle]
        strings.predictiveTitle = appearanceConfig.strings[.predictiveTitle]
        
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
        let primary = config.getUIColor(.brandPrimary)
        
        // Boost special cases
        
        styles.segue = .present
        
        styles.colors.predictiveInput = ASAPPInputColors(
            background: UIColor(hexString: "#605f60")!,
            text: .white,
            placeholderText: UIColor(hexString: "#dedede")!,
            tint: primary,
            border: nil,
            primaryButton: primary,
            secondaryButton: primary)
        
        styles.sendButtonImage = nil
        
        return styles
    }
    
    fileprivate class func createTelstraStyles(_ config: AppearanceConfig) -> ASAPPStyles {
        let styles = createCustomStyles(config)
        
        let primary = config.getUIColor(.brandPrimary)
        
        // Telstra special cases
        
        styles.welcomeLayout = .chat
        styles.colors.navBarBackground = .white
        styles.colors.navBarTitle = primary
        styles.colors.navBarButton = primary
        styles.colors.predictiveNavBarBackground = .white
        styles.colors.predictiveNavBarTitle = primary
        styles.colors.predictiveNavBarButton = primary
        styles.colors.predictiveGradientColors = [
            UIColor.white.withAlphaComponent(0.9),
            primary,
            UIColor(red: 0.28, green: 0.23, blue: 0.49, alpha: 1)
        ]
        styles.colors.predictiveGradientLocations = [0.0, 0.33, 1]
        styles.colors.predictiveInput = ASAPPInputColors(
            background: UIColor(red: 1, green: 1, blue: 1, alpha: 0.9),
            text: UIColor(red: 0.07, green: 0.07, blue: 0.2, alpha: 0.8),
            placeholderText: UIColor(red: 0.07, green: 0.07, blue: 0.2, alpha: 0.5),
            tint: UIColor(red: 0.28, green: 0.23, blue: 0.49, alpha: 1),
            border: .white,
            primaryButton: primary,
            secondaryButton: primary)
        
        return styles
    }
    
    fileprivate class func createCustomStyles(_ config: AppearanceConfig) -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        styles.textStyles.updateStyles(for: config.fontFamily)
        
        let primary = config.getUIColor(.brandPrimary)
        let secondary = config.getUIColor(.brandSecondary)
        let textLight = config.getUIColor(.textLight)
        let textDark = config.getUIColor(.textDark)
        let buttonTextColor = primary.isDark() ? primary : secondary.isDark() ? secondary : textDark
        let predictiveBackground = secondary
        
        styles.colors.controlTint = primary
        styles.colors.buttonPrimary = ASAPPButtonColors(backgroundColor: primary)
        styles.colors.textButtonPrimary = ASAPPButtonColors(textColor: buttonTextColor)
        styles.navBarStyles.buttonStyle = .text
        styles.colors.navBarBackground = primary
        styles.colors.navBarTitle = styles.colors.navBarBackground.isDark() ? textLight : textDark
        styles.colors.navBarButton = styles.colors.navBarTitle
        styles.colors.predictiveNavBarBackground = styles.colors.navBarBackground
        styles.colors.predictiveNavBarTitle = styles.colors.navBarTitle
        styles.colors.predictiveNavBarButton = styles.colors.predictiveNavBarTitle
        styles.colors.messageText = textDark.colorWithRelativeBrightness(0.33)!
        styles.colors.replyMessageText = textDark
        styles.colors.quickReplyButton = ASAPPButtonColors(backgroundColor: .white, textColor: buttonTextColor)
        styles.colors.predictiveGradientColors = [predictiveBackground, predictiveBackground, predictiveBackground]
        styles.colors.predictiveTextPrimary = predictiveBackground.isDark() ? textLight : textDark
        styles.colors.predictiveTextSecondary = styles.colors.predictiveTextPrimary
        styles.colors.predictiveButtonPrimary = ASAPPButtonColors(backgroundColor: textLight.withAlphaComponent(0.1), textColor: textLight, border: textLight)
        styles.colors.predictiveButtonSecondary = ASAPPButtonColors(backgroundColor: textLight.withAlphaComponent(0.1), textColor: textLight, border: textLight)
        styles.colors.helpButtonBackground = primary
        styles.colors.helpButtonText = primary.isDark() ? textLight : textDark
        
        styles.textStyles.predictiveHeader = ASAPPTextStyle(font: config.fontFamily.bold, size: 28, letterSpacing: 1, color: textLight)
        styles.textStyles.predictiveSubheader = ASAPPTextStyle(font: config.fontFamily.regular, size: 17, letterSpacing: 0, color: textLight)
        
        styles.colors.predictiveInput = ASAPPInputColors(
            background: .white,
            text: textDark,
            placeholderText: textDark.colorWithRelativeBrightness(0.5)!,
            tint: primary,
            border: nil,
            primaryButton: primary,
            secondaryButton: primary)
        
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
        
        switch self.appearanceConfig.brand {
        case .asapp:
            break
            
        case .boost:
            navBarColor = UIColor(red: 0.01, green: 0.01, blue: 0.01, alpha: 1)
            navBarTintColor = textLight
            navBarTitleColor = textLight
            statusBarStyle = .lightContent
            accentColor = primary
            
        case .telstra:
            navBarTintColor = primary
            navBarTitleColor = primary
            accentColor = primary
            
        case .custom:
            navBarTintColor = textDark
            navBarTitleColor = textDark
            statusBarStyle = navBarColor.isDark() ? .lightContent : .default
            accentColor = primary
        }
    }
}
