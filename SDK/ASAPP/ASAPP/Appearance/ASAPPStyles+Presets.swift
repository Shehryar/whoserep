//
//  ASAPPStyles+Presets.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public extension ASAPPStyles {
    
    public class func stylesForAppId(_ appId: String) -> ASAPPStyles {
        switch appId {
        case "comcast": return comcastStyles()
        case "boost": return boostStyles()
        case "sprint": return sprintStyles()
        default: return ASAPPStyles()
        }
    }
    
    internal class func comcastStyles() -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        let textBlue = UIColor(red:0.267, green:0.302, blue:0.396, alpha:1.000)
        let textGray = UIColor(red:0.659, green:0.678, blue:0.729, alpha:1.000)
        let linkBlue = UIColor(red:0.243, green:0.541, blue:0.796, alpha:1.000)
        
        // Nav button style
        
        styles.navBarButtonStyle = .text
        
        // Text Styles
        
        let regular = "XFINITYSans-Reg"
        let bold = "XFINITYSans-Med"
        let black = "XFINITYSans-Bold"
        
        let ts = styles.textStyles
        ts.navTitle = ASAPPTextStyle(fontName: bold, size: 15, letterSpacing: 0, color: UIColor.white)
        ts.predictiveHeader = ASAPPTextStyle(fontName: regular, size: 30, letterSpacing: 0.9, color: UIColor.white)
        ts.header1 = ASAPPTextStyle(fontName: black, size: 24, letterSpacing: 0.5, color: textBlue)
        ts.header2 = ASAPPTextStyle(fontName: black, size: 18, letterSpacing: 0.5, color: textBlue)
        ts.subheader = ASAPPTextStyle(fontName: black, size: 10, letterSpacing: 1.5, color: textGray)
        ts.body = ASAPPTextStyle(fontName: regular, size: 15, letterSpacing: 0.5, color: textBlue)
        ts.bodyBold  = ASAPPTextStyle(fontName: bold, size: 15, letterSpacing: 0.5, color: textBlue)
        ts.detail1 = ASAPPTextStyle(fontName: regular, size: 12, letterSpacing: 0.5, color: textGray)
        ts.detail2 = ASAPPTextStyle(fontName: bold, size: 10, letterSpacing: 0.75, color: textGray)
        ts.error = ASAPPTextStyle(fontName: bold, size: 15, letterSpacing: 0.5, color: UIColor.asapp_burntSiennaRed)
        ts.button = ASAPPTextStyle(fontName: black, size: 14, letterSpacing: 1.5, color: textBlue)
        ts.link = ASAPPTextStyle(fontName: black, size: 12, letterSpacing: 1.5, color: linkBlue)
        
        
        // Colors
        
        styles.colors.navBarBackground = UIColor(red:0.184, green:0.220, blue:0.275, alpha:1.000)
        styles.colors.navBarTitle = UIColor.white
        styles.colors.navBarButton = UIColor.white
    
        styles.colors.messageText = textBlue
        styles.colors.messageBackground = UIColor.white
        
        styles.colors.replyMessageText = textBlue
        styles.colors.replyMessageBackground = UIColor(red:0.918, green:0.925, blue:0.937, alpha:1.000)
        styles.colors.replyMessageBorder = UIColor(red:0.918, green:0.925, blue:0.937, alpha:1.000)
        
        styles.colors.quickRepliesBackground = UIColor.white
        styles.colors.quickReplyButton = ASAPPButtonColors(backgroundColor: UIColor.white,
                                                           textColor: textBlue)
        
        styles.colors.predictiveGradientTop = UIColor(red:0.231, green:0.643, blue:0.875, alpha:1.000)
        styles.colors.predictiveGradientMiddle = UIColor(red:0.243, green:0.553, blue:0.804, alpha:1.000)
        styles.colors.predictiveGradientBottom = UIColor(red:0.251, green:0.467, blue:0.745, alpha:1.000)
        
        styles.colors.predictiveTextPrimary = UIColor.white
        styles.colors.predictiveTextSecondary = UIColor.white
        styles.colors.predictiveButtonPrimary = ASAPPButtonColors(backgroundColor: UIColor(red:0.365, green:0.663, blue:0.891, alpha:1.000),
                                                                  textColor: UIColor.white)
        styles.colors.predictiveButtonSecondary = ASAPPButtonColors(backgroundColor: UIColor(red:0.345, green:0.639, blue:0.851, alpha:1.000),
                                                                    textColor: UIColor.white)
        styles.colors.predictiveInput = ASAPPInputColors(background: UIColor(red:0.478, green:0.631, blue:0.824, alpha:1.000),
                                                         text: UIColor.white,
                                                         placeholderText: UIColor.white.withAlphaComponent(0.7),
                                                         tint: UIColor.white,
                                                         border: nil,
                                                         primaryButton: UIColor.white,
                                                         secondaryButton: UIColor.white)
        
        return styles
    }
    
    internal class func boostStyles() -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        let boostOrange = UIColor(hexString: "#f7901e")!
        
        // Nav button style
        
        styles.navBarButtonStyle = .text
        
        // Text Styles
       
        styles.textStyles.predictiveHeader = ASAPPTextStyle(fontName: "BoostNeo-Bold", size: 30, letterSpacing: 0.9, color: .white)
        
        // Colors
        
        styles.colors.navBarBackground = .black
        styles.colors.navBarTitle = .white
        styles.colors.navBarButton = .white
        
        let messageColor = UIColor(hexString: "#797f90")!
        styles.colors.messageText = messageColor
        styles.colors.messageBorder = messageColor
        
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
    
    internal class func sprintStyles() -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        return styles
    }
}
