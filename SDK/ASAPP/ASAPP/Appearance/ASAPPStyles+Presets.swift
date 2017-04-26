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
        ts.predictiveHeader = ASAPPTextStyle(fontName: regular, size: 30, letterSpacing: 0.9, color: UIColor.white)
        ts.header1 = ASAPPTextStyle(fontName: black, size: 24, letterSpacing: 0.5, color: textBlue)
        ts.header2 = ASAPPTextStyle(fontName: black, size: 18, letterSpacing: 0.5, color: textBlue)
        ts.subheader = ASAPPTextStyle(fontName: black, size: 12, letterSpacing: 1.5, color: textGray)
        ts.body = ASAPPTextStyle(fontName: regular, size: 15, letterSpacing: 0.5, color: textBlue)
        ts.bodyBold  = ASAPPTextStyle(fontName: bold, size: 15, letterSpacing: 0.5, color: textBlue)
        ts.disclaimer = ASAPPTextStyle(fontName: regular, size: 12, letterSpacing: 0.5, color: textGray)
        ts.error = ASAPPTextStyle(fontName: bold, size: 15, letterSpacing: 0.5, color: UIColor.asapp_burntSiennaRed)
        ts.readReceipt = ASAPPTextStyle(fontName: bold, size: 10, letterSpacing: 0.75, color: textGray)
        ts.button = ASAPPTextStyle(fontName: black, size: 14, letterSpacing: 1.5, color: textBlue)
        ts.link = ASAPPTextStyle(fontName: black, size: 12, letterSpacing: 1.5, color: linkBlue)
        
        
        // Colors
        
        styles.colors.navBarBackground = UIColor(red:0.184, green:0.220, blue:0.275, alpha:1.000)
        styles.colors.navBarTitle = UIColor.white
        styles.colors.navBarButton = UIColor.white
        
        styles.colors.messageText = textBlue
        styles.colors.messageBackground = UIColor.white
        styles.colors.messageBorder = UIColor(red:0.671, green:0.690, blue:0.737, alpha:1.000)
        
        styles.colors.replyMessageText = textBlue
        styles.colors.replyMessageBackground = UIColor(red:0.918, green:0.925, blue:0.937, alpha:1.000)
        styles.colors.replyMessageBorder = UIColor(red:0.918, green:0.925, blue:0.937, alpha:1.000)
        
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
        /*
        // Fonts
        
        styles.fontNameBold = "BoostNeo-Bold"
        
        // General
        styles.primaryTextButtonColors = ASAPPButtonColors(textColor: UIColor(red:0.075, green:0.698, blue:0.925, alpha:1))
        styles.primaryButtonColors = ASAPPButtonColors(backgroundColor: UIColor(red:0.075, green:0.698, blue:0.925, alpha:1))
        styles.controlTintColor = UIColor(red:0.075, green:0.698, blue:0.925, alpha:1.000)
        
        // Nav Bar
        styles.navBarBackgroundColor = UIColor(red:0.929, green:0.515, blue:0.038, alpha:1.000)
        styles.navBarButtonColor = UIColor.white
        styles.navBarButtonStyle = ASAPPNavBarButtonStyle.text
        
        // Messages
        styles.replyMessageBackgroundColor = UIColor(red:0.918, green:0.925, blue:0.937, alpha:1.000)
        styles.replyMessageBorderColor = UIColor(red:0.918, green:0.925, blue:0.937, alpha:1.000)
        styles.replyMessageTextColor = UIColor(red:0.263, green:0.278, blue:0.318, alpha:1.000)
        styles.messageBackgroundColor = UIColor(red:1.000, green:1.000, blue:1.000, alpha:1.000)
        styles.messageBorderColor = UIColor(red:0.773, green:0.788, blue:0.820, alpha:1.000)
        styles.messageTextColor = UIColor(red:0.353, green:0.392, blue:0.490, alpha:1.000)
        
        // Quick Replies
        styles.quickRepliesBackgroundColor = UIColor.white
        styles.quickReplyButtonColors = ASAPPButtonColors(backgroundColor: UIColor.white,
                                                          textColor: UIColor(red:0.337, green:0.376, blue:0.478, alpha:1))
        
        // Predictive
        styles.predictiveGradientTopColor = UIColor(red:0.969, green:0.580, blue:0.184, alpha:1.000)
        styles.predictiveGradientMiddleColor = UIColor(red:0.937, green:0.510, blue:0.149, alpha:1.000)
        styles.predictiveGradientBottomColor = UIColor(red:0.922, green:0.443, blue:0.122, alpha:1.000)
        styles.predictiveSecondaryTextColor = UIColor.white
        styles.predictivePrimaryButtonColors = ASAPPButtonColors(backgroundColor: UIColor(red:0.953, green:0.612, blue:0.267, alpha:1.000))
        styles.predictiveSecondaryButtonColors = ASAPPButtonColors(backgroundColor: UIColor(red:0.953, green:0.612, blue:0.267, alpha:1.000))
        
        styles.predictiveInputColors = ASAPPInputColors(background: UIColor(red:0.933, green:0.608, blue:0.361, alpha:1.000),
                                                        text: UIColor.white,
                                                        placeholderText: UIColor(red:0.996, green:0.988, blue:0.984, alpha:1.000),
                                                        tint: UIColor(red:0.996, green:0.988, blue:0.984, alpha:1.000),
                                                        border: nil,
                                                        primaryButton: UIColor.white,
                                                        secondaryButton: UIColor.white)
        
        // Help Button
        styles.helpButtonBackgroundColor = UIColor(red:0.969, green:0.565, blue:0.118, alpha:1)
        styles.helpButtonForegroundColor = UIColor.white
*/
        return styles
    }
    
    internal class func sprintStyles() -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        return styles
    }
}
