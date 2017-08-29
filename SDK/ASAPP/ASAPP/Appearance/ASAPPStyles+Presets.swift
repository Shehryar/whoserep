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
        
        // Text Styles
        
        let regular = "XFINITYSans-Reg"
        let bold = "XFINITYSans-Med"
        let black = "XFINITYSans-Bold"
        
        let ts = styles.textStyles
        ts.navTitle = ASAPPTextStyle(fontName: bold, size: 15, letterSpacing: 0, color: UIColor.white)
        ts.predictiveHeader = ASAPPTextStyle(fontName: FontNames.latoLight, size: 24, letterSpacing: 0.5, color: UIColor.asapp_cometBlue)
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
        
        // Nav button style
        
        styles.navBarButtonStyle = .bubble
        
        // Colors
        
        styles.colors.helpButtonBackground = UIColor(red:0.134, green:0.160, blue:0.205, alpha:1.000)
        
        styles.colors.controlTint = UIColor(red:0.000, green:0.443, blue:0.710, alpha:1.000)
        
        styles.colors.navBarBackground = UIColor.black
        styles.colors.navBarTitle = UIColor.white
        styles.colors.navBarButton = UIColor.white
        styles.colors.navBarButtonForeground = UIColor.white
        styles.colors.navBarButtonBackground = UIColor(red:0.000, green:0.443, blue:0.710, alpha:1.000)
        
        styles.colors.messageBackground = UIColor(red:0.000, green:0.494, blue:0.745, alpha:1.000)
        styles.colors.messageBorder = UIColor(red:0.000, green:0.494, blue:0.745, alpha:1.000)
        styles.colors.messageText = UIColor.white
        
        styles.colors.quickRepliesBackgroundPattern = false
        styles.colors.quickRepliesBackground = UIColor.white
        styles.colors.quickReplyButton = ASAPPButtonColors(backgroundColor: UIColor.white, textColor: UIColor(red:0.000, green:0.494, blue:0.745, alpha:1.000))
        
        styles.colors.predictiveNavBarBackground = UIColor.black
        styles.colors.predictiveNavBarButton = UIColor(red:0.000, green:0.443, blue:0.710, alpha:1.000)
        styles.colors.predictiveNavBarButtonBackground = UIColor(red:0.000, green:0.443, blue:0.710, alpha:1.000)
        styles.colors.predictiveNavBarButtonForeground = UIColor.white
        styles.colors.predictiveGradientTop = UIColor.white
        styles.colors.predictiveGradientMiddle = UIColor.white
        styles.colors.predictiveGradientBottom = UIColor.white
        styles.colors.predictiveNavBarButton = UIColor(red:0.184, green:0.220, blue:0.275, alpha:1.000)
        styles.colors.predictiveTextPrimary = UIColor(red:0.180, green:0.216, blue:0.271, alpha:1.000)
        styles.colors.predictiveTextSecondary = UIColor(red:0.302, green:0.302, blue:0.302, alpha:1.000)
        styles.colors.predictiveButtonPrimary = ASAPPButtonColors(backgroundColor: UIColor(red:0.000, green:0.443, blue:0.710, alpha:1.000))
        styles.colors.predictiveButtonSecondary = ASAPPButtonColors(backgroundColor: UIColor(red:0.000, green:0.443, blue:0.710, alpha:1.000))
        styles.colors.predictiveInput = ASAPPInputColors(background: UIColor.white,
                                                         text:  UIColor(red:0.180, green:0.216, blue:0.271, alpha:1.000),
                                                         placeholderText: UIColor(red:0.459, green:0.478, blue:0.525, alpha:1.000),
                                                         tint: UIColor(red:0.008, green:0.451, blue:0.714, alpha:1.000),
                                                         border: UIColor(red:0.631, green:0.659, blue:0.714, alpha:1.000),
                                                         primaryButton: UIColor(red:0.008, green:0.451, blue:0.714, alpha:1.000),
                                                         secondaryButton: UIColor(red:0.008, green:0.451, blue:0.714, alpha:1.000))
        
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
    
    internal class func sprintStyles() -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        return styles
    }
}
