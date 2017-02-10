//
//  ASAPPStyles.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/3/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

public class ASAPPStyles: NSObject {
    
    public var strings: ASAPPStrings = ASAPPStrings()
    
    // MARK:- Fonts
    
    public var fontNameLight: String = "Lato-Light"
    public var fontNameRegular: String = "Lato-Regular"
    public var fontNameBold: String = "Lato-Bold"
    public var fontNameBlack: String = "Lato-Black"
    
    // MARK:- Colors: Messages
    
    public var replyMessageFillColor: UIColor = UIColor(red:0.941, green:0.945, blue:0.953, alpha:1)
    
    public var replyMessageStrokeColor: UIColor? = nil
    
    public var replyMessageTextColor: UIColor = UIColor(red:0.264, green:0.278, blue:0.316, alpha:1)
    
    public var messageStrokeColor: UIColor? = UIColor(red:0.749, green:0.757, blue:0.790, alpha:1)
    
    public var messageFillColor: UIColor = Colors.whiteColor()
    
    public var messageTextColor: UIColor = UIColor(red:0.476, green:0.498, blue:0.565, alpha:1)
    
    // MARK:- Colors: General
    
    public var navBarButtonColor: UIColor = UIColor(red:0.355, green:0.394, blue:0.494, alpha:1)
    
    public var navBarBackgroundColor: UIColor = Colors.whiteColor()
    
    public var navBarButtonForegroundColor: UIColor = UIColor(red:0.264, green:0.278, blue:0.316, alpha:1)
    
    public var navBarButtonBackgroundColor: UIColor = UIColor(red:0.866, green:0.878, blue:0.907, alpha:1)
    
    internal var backgroundColor1: UIColor = Colors.whiteColor()
    
    internal var backgroundColor2: UIColor = Colors.offWhiteColor()
    
    internal var foregroundColor1: UIColor = Colors.steelDarkColor()
    
    internal var foregroundColor2: UIColor = Colors.steelDark50Color()
    
    internal var buttonColor: UIColor = Colors.steelMedColor()
    
    internal var separatorColor1: UIColor = Colors.marbleLightColor()
    
    internal var separatorColor2: UIColor = Colors.marbleDarkColor()
    
    internal var accentColor: UIColor = Colors.steelLightColor()
    
    public var asappButtonForegroundColor: UIColor = UIColor.white
    
    public var asappButtonBackgroundColor: UIColor = UIColor(red:0.374, green:0.392, blue:0.434, alpha:1)
    
    internal var askViewGradientTopColor: UIColor = UIColor(red:0.302, green:0.310, blue:0.347, alpha:0.9)
    internal var askViewGradientMiddleColor: UIColor = UIColor(red:0.366, green:0.384, blue:0.426, alpha:0.8)
    internal var askViewGradientBottomColor: UIColor = UIColor(red:0.483, green:0.505, blue:0.568, alpha:0.8)
    internal var askViewDetailLabelColor: UIColor = Colors.steelMed50Color()
    internal var askViewButtonBgColor: UIColor = UIColor(red:0.492, green:0.513, blue:0.547, alpha:1)
    internal var askViewInputBgColor: UIColor = UIColor(red:0.232, green:0.247, blue:0.284, alpha:1)
    
    // MARK:- Colors: Input
    
    internal var inputBackgroundColor: UIColor = Colors.whiteColor()
    
    internal var inputBorderTopColor: UIColor = Colors.lighterGrayColor()
    
    internal var inputTintColor: UIColor = Colors.grayColor()
    
    internal var inputPlaceholderColor: UIColor = Colors.mediumTextColor()
    
    internal var inputTextColor: UIColor = Colors.darkTextColor()
    
    internal var inputSendButtonColor: UIColor = Colors.blueGrayColor()
    
    internal var inputImageButtonColor: UIColor = Colors.mediumTextColor()
}

// MARK:- Presets

extension ASAPPStyles {
    public class func stylesForCompany(_ company: String) -> ASAPPStyles? {
        if company.localizedCaseInsensitiveContains("comcast") {
            return comcastStyles()
        }
        if company.localizedCaseInsensitiveContains("sprint")
            || company.localizedCaseInsensitiveContains("text-rex") {
            return sprintStyles()
        }
        return nil
    }
    
    class func comcastStyles() -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        styles.fontNameLight = "XFINITYSans-Lgt"
        styles.fontNameRegular = "XFINITYSans-Reg"
        styles.fontNameBold = "XFINITYSans-Med"
        styles.fontNameBlack = "XFINITYSans-Bold"
        
        return styles
    }
    
    class func sprintStyles() -> ASAPPStyles {
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
    
    public class func darkStyles() -> ASAPPStyles {
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

protocol ASAPPStyleable {
    
    var styles: ASAPPStyles { get }
    
    func applyStyles(_ styles: ASAPPStyles)
}
