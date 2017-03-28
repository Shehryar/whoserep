//
//  ASAPPStyles+Presets.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public extension ASAPPStyles {
    public class func stylesForCompany(_ company: String) -> ASAPPStyles {
        if company.localizedCaseInsensitiveContains("comcast") {
            return comcastStyles()
        }
        if company.localizedCaseInsensitiveContains("sprint") {
            return sprintStyles()
        }
        if company.localizedCaseInsensitiveContains("boost") {
            return boostStyles()
        }
        
        return ASAPPStyles()
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
        
    //    styles.fontNameLight = "BoostNeo-Light"
      //  styles.fontNameRegular = "BoostNeo-Regular"
        styles.fontNameBold = "BoostNeo-Bold"
       // styles.fontNameBlack = "BoostNeo-Black"
        
        // General
        styles.textButtonColor = UIColor(red:0.969, green:0.565, blue:0.118, alpha:1.000)
        styles.textButtonColorHighlighted = UIColor(red:0.969, green:0.565, blue:0.118, alpha:0.6)
        
        // Help Button
        styles.helpButtonBackgroundColor = UIColor(red:0.969, green:0.565, blue:0.118, alpha:1.000)
        styles.helpButtonForegroundColor = UIColor.white// UIColor(red: 0.01, green: 0.01, blue: 0.01, alpha: 1)
        
        
        // Nav Bar
        styles.navBarBackgroundColor = UIColor(red: (235 / 255.0),
                                               green: (130.0 / 255.0),
                                               blue: (0.0 / 255.0),
                                               alpha:1.000)
        styles.navBarButtonColor = UIColor.white
        styles.navBarButtonStyle = .text
        
        // Messages
        styles.replyMessageFillColor = UIColor(red:0.918, green:0.925, blue:0.937, alpha:1.000)
        styles.replyMessageStrokeColor = UIColor(red:0.918, green:0.925, blue:0.937, alpha:1.000)
        styles.replyMessageTextColor = UIColor(red:0.263, green:0.278, blue:0.318, alpha:1.000)
        styles.messageFillColor = UIColor(red:1.000, green:1.000, blue:1.000, alpha:1.000)
        styles.messageStrokeColor = UIColor(red:0.773, green:0.788, blue:0.820, alpha:1.000)
        styles.messageTextColor = UIColor(red:0.353, green:0.392, blue:0.490, alpha:1.000)
        
        // Quick Replies
        styles.quickReplyButtonBackroundColor = UIColor.white
        styles.quickRepliesButtonTextColor = UIColor(red:0.337, green:0.376, blue:0.478, alpha:1.000)
        
        // Predictive
        styles.predictiveViewGradientTopColor = UIColor(red:0.969, green:0.580, blue:0.184, alpha:1.000)
        styles.predictiveViewGradientMiddleColor = UIColor(red:0.937, green:0.510, blue:0.149, alpha:1.000)
        styles.predictiveViewGradientBottomColor = UIColor(red:0.922, green:0.443, blue:0.122, alpha:1.000)
        styles.predictiveViewDetailLabelColor = UIColor.white
        styles.predictiveViewButtonBgColor = UIColor(red:0.953, green:0.612, blue:0.267, alpha:1.000)
        styles.predictiveViewInputBgColor = UIColor(red:0.937, green:0.612, blue:0.361, alpha:0.9)
        
        return styles
    }
    
    internal class func sprintStyles() -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        // Fonts
        
        styles.fontNameLight = "SprintSans-Regular"
        styles.fontNameRegular = "SprintSans-Regular"
        styles.fontNameBold = "SprintSans-Bold"
        styles.fontNameBlack = "SprintSans-Black"
        
        // Colors
        
        styles.helpButtonBackgroundColor = UIColor(red:0.989, green:0.811, blue:0.003, alpha:1)
        styles.helpButtonForegroundColor = UIColor.black
        
        styles.navBarButtonBackgroundColor = UIColor(red:0.989, green:0.811, blue:0.003, alpha:1)
        styles.navBarButtonForegroundColor = UIColor(red:0.330, green:0.268, blue:0, alpha:1)
        
        styles.quickRepliesButtonTextColor = UIColor.black
        styles.foregroundColor1 = UIColor.black
        
        styles.predictiveViewGradientTopColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.8)
        styles.predictiveViewGradientMiddleColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:0.8)
        styles.predictiveViewGradientBottomColor = UIColor(red:0.3, green:0.3, blue:0.3, alpha:0.8)
        styles.predictiveViewDetailLabelColor = UIColor(red:0.345, green:0.356, blue:0.390, alpha:1)
        styles.predictiveViewButtonBgColor = UIColor(red:0.384, green:0.384, blue:0.384, alpha:1)
        styles.predictiveViewInputBgColor = UIColor(red:0.012, green:0.012, blue:0.012, alpha:1)
        
        return styles
    }
    
    internal class func darkStyles() -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        styles.navBarBackgroundColor = UIColor.black
        styles.navBarButtonColor = UIColor.white
        styles.navBarButtonBackgroundColor = UIColor(red:0.241, green:0.255, blue:0.289, alpha:1)
        styles.navBarButtonForegroundColor = UIColor.white
        styles.quickRepliesButtonTextColor = UIColor.white
        
        styles.backgroundColor1 = UIColor(red:0.015, green:0.051, blue:0.080, alpha:1)
        styles.backgroundColor2 = UIColor(red: 0.10, green: 0.11, blue: 0.12, alpha: 1)
        styles.foregroundColor1 = UIColor.white
        styles.foregroundColor2 = UIColor(red:0.346, green:0.392, blue:0.409, alpha:1)
        styles.separatorColor1 = UIColor(red:0.16,  green:0.18,  blue:0.19, alpha:1)
        styles.separatorColor2 =  UIColor(red:0.16,  green:0.18,  blue:0.19, alpha:1)
        
        
        styles.messageFillColor = UIColor(red: 0.12, green: 0.13, blue: 0.15, alpha: 1)
        styles.messageStrokeColor = nil
        styles.messageTextColor = UIColor.white
        
        styles.replyMessageFillColor = UIColor(red:0.17, green:0.18, blue:0.19, alpha:1)
        styles.replyMessageTextColor = UIColor.white
        styles.replyMessageStrokeColor = nil
        
        styles.inputBackgroundColor = UIColor(red: 0.10, green: 0.11, blue: 0.12, alpha: 1)
        styles.inputTintColor = UIColor(red:0.269,  green:0.726,  blue:0.287, alpha:1)
        styles.inputPlaceholderColor = styles.foregroundColor2
        styles.inputTextColor = styles.foregroundColor1
        styles.inputSendButtonColor = UIColor(red:0.266, green:0.808, blue:0.600, alpha:1)
        styles.inputImageButtonColor = UIColor(red:0.266, green:0.808, blue:0.600, alpha:1)
        
        styles.predictiveViewGradientTopColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.6)
        styles.predictiveViewGradientMiddleColor = UIColor(red:0.08, green:0.08, blue:0.08, alpha:0.6)
        styles.predictiveViewGradientBottomColor = UIColor(red:0.1, green:0.1, blue:0.1, alpha:0.6)
        styles.predictiveViewDetailLabelColor = UIColor(red:0.345, green:0.356, blue:0.390, alpha:1)
        styles.predictiveViewButtonBgColor = UIColor(red:0.17, green:0.18, blue:0.19, alpha:1)
        styles.predictiveViewInputBgColor = UIColor(red:0.02, green:0.023, blue:0.025, alpha:1)
        
        return styles
    }
}
