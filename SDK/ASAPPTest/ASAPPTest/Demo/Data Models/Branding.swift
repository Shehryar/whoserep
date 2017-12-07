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
    case boost
    case telstra
    
    static let all = [
        asapp,
        boost,
        telstra
    ]
    
    static func from(_ value: Any?) -> BrandingType? {
        guard let value = value as? String else {
            return nil
        }
        return BrandingType(rawValue: value)
    }
}

// MARK: - Branding

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
    
    // MARK: - Init
    
    required init(brandingType: BrandingType) {
        self.brandingType = brandingType
        colors = BrandingColors(brandingType: brandingType)
        strings = ASAPPStrings()
        views = ASAPPViews()
        
        switch brandingType {
        case .asapp:
            fontFamily = DemoFonts.asapp
            styles = ASAPPStyles()
            styles.shapeStyles.sendButtonImage = nil
            logoImageName = "asapp-logo"
            logoImageSize = CGSize(width: 115, height: 22)
            views.chatTitle = Branding.createASAPPTitle(colors: colors, styles: styles, fontFamily: fontFamily)
            strings.predictiveSendButton = "SEND"
            strings.chatInputSend = "SEND"
            
        case .boost:
            fontFamily = DemoFonts.boost
            styles = Branding.createBoostStyles(fontFamily)
            logoImageName = "boost-logo-light"
            logoImageSize = CGSize(width: 109, height: 32)
            strings.predictiveSendButton = "SEND"
            strings.chatInputSend = "SEND"
            
        case .telstra:
            fontFamily = DemoFonts.asapp
            styles = Branding.createTelstraStyles(fontFamily)
            logoImageName = "telstra-logo"
            logoImageSize = CGSize(width: 31.5, height: 34)
            strings.chatTitle = "24x7 Chat"
            strings.predictiveTitle = "24x7 Chat"
            strings.chatEndChatNavBarButton = "END"
            strings.predictiveWelcomeText = "Talk to us."
            strings.predictiveOtherSuggestions = "What can our agents help you with?"
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

extension Branding {
    // MARK: - per-client demo styles
    
    fileprivate class func createBoostStyles(_ fontFamily: ASAPPFontFamily) -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        styles.textStyles.updateStyles(for: fontFamily)
        
        let boostOrange = UIColor(hexString: "#f7901e")!
        let replyColor = UIColor(hexString: "#eaecef")!
        let predictiveColor = UIColor(hexString: "#373737")!
        let controlTint = UIColor(hexString: "#13a4a2")!
        
        styles.navBarStyles.buttonStyle = .text
        styles.colors.navBarBackground = .black
        styles.colors.navBarTitle = .white
        styles.colors.navBarButton = .white
        styles.colors.messageText = UIColor(hexString: "#797f90")!
        styles.colors.messageBorder = UIColor(hexString: "#d9dbdf")!
        styles.colors.replyMessageText = UIColor(hexString: "#444852")!
        styles.colors.replyMessageBackground = replyColor
        styles.colors.replyMessageBorder = replyColor
        styles.colors.quickRepliesBackground = .white
        styles.colors.quickReplyButton = ASAPPButtonColors(backgroundColor: .white, textColor: UIColor(hexString: "#5b657e")!)
        styles.colors.predictiveGradientColors = [predictiveColor, predictiveColor, predictiveColor]
        styles.colors.predictiveTextPrimary = .white
        styles.colors.predictiveTextSecondary = .white
        styles.colors.predictiveButtonPrimary = ASAPPButtonColors(
            backgroundNormal: predictiveColor,
            backgroundHighlighted: boostOrange,
            backgroundDisabled: predictiveColor,
            textNormal: boostOrange,
            textHighlighted: .white,
            textDisabled: boostOrange,
            border: boostOrange)
        styles.colors.predictiveButtonSecondary = styles.colors.predictiveButtonPrimary
        styles.colors.predictiveInput = ASAPPInputColors(
            background: UIColor(hexString: "#605f60")!,
            text: .white,
            placeholderText: UIColor(hexString: "#dedede")!,
            tint: controlTint,
            border: nil,
            primaryButton: controlTint,
            secondaryButton: controlTint)
        
        styles.colors.controlTint = controlTint
        styles.colors.buttonPrimary = ASAPPButtonColors(backgroundColor: boostOrange)
        styles.colors.textButtonPrimary = ASAPPButtonColors(textColor: boostOrange)
        
        styles.colors.helpButtonBackground = boostOrange
        
        let boostMedium = UIFont(name: "BoostNeo-Bold", size: 30)!
        styles.textStyles.predictiveHeader = ASAPPTextStyle(font: boostMedium, size: 30, letterSpacing: 0.9, color: .white)
        
        styles.shapeStyles.sendButtonImage = nil
        
        return styles
    }
    
    fileprivate class func createTelstraStyles(_ fontFamily: ASAPPFontFamily) -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        styles.textStyles.updateStyles(for: fontFamily)
        
        let telstraBlue = UIColor(red: 0, green: 0.6, blue: 0.89, alpha: 1)
        
        styles.segue = .push
        styles.welcomeLayout = .chat
        styles.navBarStyles.buttonStyle = .text
        styles.colors.helpButtonBackground = telstraBlue
        styles.colors.navBarBackground = .white
        styles.colors.navBarTitle = telstraBlue
        styles.colors.navBarButton = telstraBlue
        styles.colors.navBarButtonForeground = telstraBlue
        styles.colors.predictiveNavBarTitle = telstraBlue
        styles.colors.predictiveNavBarBackground = .white
        styles.colors.predictiveNavBarButton = telstraBlue
        styles.colors.predictiveNavBarButtonForeground = telstraBlue
        styles.colors.predictiveTextPrimary = .white
        styles.colors.predictiveTextSecondary = .white
        styles.colors.predictiveGradientColors = [
            UIColor.white.withAlphaComponent(0.9),
            telstraBlue,
            UIColor(red: 0.28, green: 0.23, blue: 0.49, alpha: 1)
        ]
        styles.colors.predictiveGradientLocations = [0.0, 0.33, 1]
        styles.colors.predictiveButtonPrimary = ASAPPButtonColors(backgroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.1), textColor: .white, border: .white)
        styles.colors.predictiveButtonSecondary = ASAPPButtonColors(backgroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.1), textColor: .white, border: .white)
        styles.colors.predictiveInput = ASAPPInputColors(
            background: UIColor(red: 1, green: 1, blue: 1, alpha: 0.9),
            text: UIColor(red: 0.07, green: 0.07, blue: 0.2, alpha: 0.8),
            placeholderText: UIColor(red: 0.07, green: 0.07, blue: 0.2, alpha: 0.5),
            tint: UIColor(red: 0.28, green: 0.23, blue: 0.49, alpha: 1),
            border: .white,
            primaryButton: telstraBlue,
            secondaryButton: telstraBlue)
        styles.colors.messageText = .darkGray
        styles.colors.messageBorder = UIColor(red: 0.86, green: 0.87, blue: 0.88, alpha: 1)
        styles.colors.replyMessageText = .black
        styles.colors.replyMessageBackground = UIColor(red: 0.92, green: 0.93, blue: 0.94, alpha: 1)
        styles.colors.replyMessageBorder = UIColor(red: 0.80, green: 0.81, blue: 0.84, alpha: 1)
        styles.textStyles.predictiveHeader = ASAPPTextStyle(font: DemoFonts.asapp.bold, size: 28, letterSpacing: 1, color: .white)
        styles.textStyles.predictiveSubheader = ASAPPTextStyle(font: DemoFonts.asapp.regular, size: 17, letterSpacing: 0, color: .white)
        
        return styles
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
    
    // MARK: - Init
    
    required init(brandingType: BrandingType) {
        self.brandingType = brandingType
        super.init()
        
        switch self.brandingType {
        case .asapp:
            break
            
        case .boost:
            navBarColor = UIColor(red: 0.01, green: 0.01, blue: 0.01, alpha: 1)
            navBarTintColor = .white
            navBarTitleColor = .white
            statusBarStyle = .lightContent
            
            foregroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            secondaryTextColor = UIColor(red: 0.490, green: 0.490, blue: 0.490, alpha: 1)
            backgroundColor = .white
            separatorColor = UIColor(red: 0.882, green: 0.882, blue: 0.882, alpha: 1)
            accentColor = UIColor(red: 0.961, green: 0.514, blue: 0.071, alpha: 1)
            
        case .telstra:
            navBarColor = .white
            navBarTintColor = UIColor(red: 0, green: 0.6, blue: 0.89, alpha: 1)
            navBarTitleColor = UIColor(red: 0, green: 0.6, blue: 0.89, alpha: 1)
            statusBarStyle = .default
            
            foregroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            secondaryTextColor = UIColor(red: 0.490, green: 0.490, blue: 0.490, alpha: 1)
            backgroundColor = .white
            separatorColor = UIColor(red: 0.882, green: 0.882, blue: 0.882, alpha: 1)
            accentColor = UIColor(red: 0, green: 0.6, blue: 0.89, alpha: 1)
        }
    }
}
