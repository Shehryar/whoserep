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
        
        styles.fontNameLight = "XFINITYSans-Lgt"
        styles.fontNameRegular = "XFINITYSans-Reg"
        styles.fontNameBold = "XFINITYSans-Med"
        styles.fontNameBlack = "XFINITYSans-Bold"
        
        return styles
    }
    
    internal class func boostStyles() -> ASAPPStyles {
        let styles = ASAPPStyles()
        
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

        return styles
    }
    
    internal class func sprintStyles() -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        return styles
    }
}
