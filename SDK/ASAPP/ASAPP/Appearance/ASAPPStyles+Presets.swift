//
//  ASAPPStyles+Presets.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public extension ASAPPStyles {
    /**
      Applies the SDK's default font family to per-app style presets.
     
     - parameter appId: A `String` identifying your app.
     - returns: An instance of `ASAPPStyles`.
     */
    public class func stylesForAppId(_ appId: String) -> ASAPPStyles {
        return stylesForAppId(appId, fontFamily: Fonts.default)
    }
    
    /**
     Applies a custom font family to per-app style presets.
     
     - parameter appId: A `String` identifying your app.
     - parameter fontFamily: An `ASAPPFontFamily` instance. Optional.
     - returns: An instance of `ASAPPStyles`.
     */
    public class func stylesForAppId(_ appId: String, fontFamily: ASAPPFontFamily? = nil) -> ASAPPStyles {
        let fontFamily = fontFamily ?? Fonts.default
        
        ASAPP.loadFonts()
        switch appId {
        case "comcast": return comcastStyles(fontFamily: fontFamily)
        case "boost": return boostStyles(fontFamily: fontFamily)
        default:
            let styles = ASAPPStyles()
            styles.textStyles.updateStyles(for: fontFamily)
            return styles
        }
    }
    
    internal class func comcastStyles(fontFamily: ASAPPFontFamily) -> ASAPPStyles {
        let styles = ASAPPStyles()
        styles.textStyles.updateStyles(for: fontFamily)
        
        let textBlue = UIColor(red: 0.267, green: 0.302, blue: 0.396, alpha: 1)
        let textGray = UIColor(red: 0.659, green: 0.678, blue: 0.729, alpha: 1)
        let linkBlue = UIColor(red: 0.243, green: 0.541, blue: 0.796, alpha: 1)
        let navBlue = UIColor(red: 0.149, green: 0.573, blue: 0.827, alpha: 1)
        
        // Text Styles
        
        let regular = fontFamily.regular
        let medium = fontFamily.medium
        let bold = fontFamily.bold
        
        let ts = styles.textStyles
        ts.navTitle = ASAPPTextStyle(font: regular, size: 17, letterSpacing: 0, color: .white)
        ts.navButton = ASAPPTextStyle(font: medium, size: 16, letterSpacing: 0, color: textBlue)
        ts.predictiveHeader = ASAPPTextStyle(font: Fonts.default.light, size: 24, letterSpacing: 0.5, color: UIColor.ASAPP.cometBlue)
        ts.header1 = ASAPPTextStyle(font: bold, size: 24, letterSpacing: 0.5, color: textBlue)
        ts.header2 = ASAPPTextStyle(font: bold, size: 18, letterSpacing: 0.5, color: textBlue)
        ts.subheader = ASAPPTextStyle(font: bold, size: 10, letterSpacing: 1.5, color: textGray)
        ts.body = ASAPPTextStyle(font: regular, size: 15, letterSpacing: 0.5, color: textBlue)
        ts.bodyBold  = ASAPPTextStyle(font: medium, size: 15, letterSpacing: 0.5, color: textBlue)
        ts.detail1 = ASAPPTextStyle(font: regular, size: 12, letterSpacing: 0.5, color: textGray)
        ts.detail2 = ASAPPTextStyle(font: medium, size: 10, letterSpacing: 0.75, color: textGray)
        ts.error = ASAPPTextStyle(font: medium, size: 15, letterSpacing: 0.5, color: UIColor.ASAPP.burntSiennaRed)
        ts.button = ASAPPTextStyle(font: bold, size: 14, letterSpacing: 1.5, color: textBlue)
        ts.link = ASAPPTextStyle(font: bold, size: 12, letterSpacing: 1.5, color: linkBlue)
        
        // Segue type
        
        styles.segue = .push
        
        // Nav button style
        
        styles.navBarStyles.buttonStyle = .text
        
        // Colors
        
        styles.colors.helpButtonBackground = UIColor(red: 0.134, green: 0.160, blue: 0.205, alpha: 1)
        
        styles.colors.controlTint = navBlue
        
        styles.colors.navBarBackground = .black
        styles.colors.navBarTitle = .white
        styles.colors.navBarButton = navBlue
        styles.colors.navBarButtonForeground = .white
        styles.colors.navBarButtonBackground = navBlue
        
        styles.colors.messageBackground = UIColor(red: 0.000, green: 0.494, blue: 0.745, alpha: 1)
        styles.colors.messageBorder = UIColor(red: 0.000, green: 0.494, blue: 0.745, alpha: 1)
        styles.colors.messageText = .white
        
        styles.colors.quickRepliesBackgroundPattern = false
        styles.colors.quickRepliesBackground = .white
        styles.colors.quickReplyButton = ASAPPButtonColors(backgroundColor: .white, textColor: UIColor(red: 0.000, green: 0.494, blue: 0.745, alpha: 1))
        
        styles.colors.predictiveNavBarBackground = .black
        styles.colors.predictiveNavBarButton = navBlue
        styles.colors.predictiveNavBarButtonBackground = .clear
        styles.colors.predictiveNavBarButtonForeground = navBlue
        styles.colors.predictiveGradientTop = .white
        styles.colors.predictiveGradientMiddle = .white
        styles.colors.predictiveGradientBottom = .white
        styles.colors.predictiveTextPrimary = UIColor(red: 0.180, green: 0.216, blue: 0.271, alpha: 1)
        styles.colors.predictiveTextSecondary = UIColor(red: 0.302, green: 0.302, blue: 0.302, alpha: 1)
        styles.colors.predictiveButtonPrimary = ASAPPButtonColors(backgroundColor: UIColor(red: 0.000, green: 0.443, blue: 0.710, alpha: 1))
        styles.colors.predictiveButtonSecondary = ASAPPButtonColors(backgroundColor: UIColor(red: 0.000, green: 0.443, blue: 0.710, alpha: 1))
        styles.colors.predictiveInput = ASAPPInputColors(
            background: .white,
            text: UIColor(red: 0.180, green: 0.216, blue: 0.271, alpha: 1),
            placeholderText: UIColor(red: 0.459, green: 0.478, blue: 0.525, alpha: 1),
            tint: UIColor(red: 0.008, green: 0.451, blue: 0.714, alpha: 1),
            border: UIColor(red: 0.631, green: 0.659, blue: 0.714, alpha: 1),
            primaryButton: UIColor(red: 0.008, green: 0.451, blue: 0.714, alpha: 1),
            secondaryButton: UIColor(red: 0.008, green: 0.451, blue: 0.714, alpha: 1))
        
        return styles
    }
    
    internal class func boostStyles(fontFamily: ASAPPFontFamily) -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        let boostOrange = UIColor(hexString: "#f7901e")!
        
        // Nav button style
        
        styles.navBarStyles.buttonStyle = .text
        
        // Colors
        
        styles.colors.navBarBackground = .black
        styles.colors.navBarTitle = .white
        styles.colors.navBarButton = .white
        
        styles.colors.messageText = UIColor(hexString: "#797f90")!
        styles.colors.messageBorder = UIColor(hexString: "#d9dbdf")!
        
        styles.colors.replyMessageText = UIColor(hexString: "#444852")!
        let replyColor = UIColor(hexString: "#eaecef")!
        styles.colors.replyMessageBackground = replyColor
        styles.colors.replyMessageBorder = replyColor
        
        styles.colors.quickRepliesBackground = .white
        styles.colors.quickReplyButton = ASAPPButtonColors(backgroundColor: .white, textColor: UIColor(hexString: "#5b657e")!)
        
        let predictiveColor = UIColor(hexString: "#373737")!
        styles.colors.predictiveGradientTop = predictiveColor
        styles.colors.predictiveGradientMiddle = predictiveColor
        styles.colors.predictiveGradientBottom = predictiveColor
        
        let controlTint = UIColor(hexString: "#13a4a2")!
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
        
        return styles
    }
}
