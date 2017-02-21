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
        if company.localizedCaseInsensitiveContains("sprint")
            || company.localizedCaseInsensitiveContains("text-rex") {
            return sprintStyles()
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
    
    internal class func sprintStyles() -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        // Fonts
        
        styles.fontNameLight = "SprintSans-Regular"
        styles.fontNameRegular = "SprintSans-Regular"
        styles.fontNameBold = "SprintSans-Bold"
        styles.fontNameBlack = "SprintSans-Black"
        
        // Colors
        
        styles.asappButtonBackgroundColor = UIColor(red:0.989, green:0.811, blue:0.003, alpha:1)
        styles.asappButtonForegroundColor = UIColor.black
        
        styles.navBarButtonBackgroundColor = UIColor(red:0.989, green:0.811, blue:0.003, alpha:1)
        styles.navBarButtonForegroundColor = UIColor(red:0.330, green:0.268, blue:0, alpha:1)
        
        styles.buttonColor = UIColor.black
        styles.foregroundColor1 = UIColor.black
        
        styles.askViewGradientTopColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.8)
        styles.askViewGradientMiddleColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:0.8)
        styles.askViewGradientBottomColor = UIColor(red:0.3, green:0.3, blue:0.3, alpha:0.8)
        styles.askViewDetailLabelColor = UIColor(red:0.345, green:0.356, blue:0.390, alpha:1)
        styles.askViewButtonBgColor = UIColor(red:0.384, green:0.384, blue:0.384, alpha:1)
        styles.askViewInputBgColor = UIColor(red:0.012, green:0.012, blue:0.012, alpha:1)
        
        return styles
    }
    
    internal class func darkStyles() -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        styles.navBarBackgroundColor = UIColor.black
        styles.navBarButtonColor = UIColor.white
        styles.navBarButtonBackgroundColor = UIColor(red:0.241, green:0.255, blue:0.289, alpha:1)
        styles.navBarButtonForegroundColor = UIColor.white
        styles.buttonColor = UIColor.white
        
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
        
        styles.askViewGradientTopColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.6)
        styles.askViewGradientMiddleColor = UIColor(red:0.08, green:0.08, blue:0.08, alpha:0.6)
        styles.askViewGradientBottomColor = UIColor(red:0.1, green:0.1, blue:0.1, alpha:0.6)
        styles.askViewDetailLabelColor = UIColor(red:0.345, green:0.356, blue:0.390, alpha:1)
        styles.askViewButtonBgColor = UIColor(red:0.17, green:0.18, blue:0.19, alpha:1)
        styles.askViewInputBgColor = UIColor(red:0.02, green:0.023, blue:0.025, alpha:1)
        
        return styles
    }
}
