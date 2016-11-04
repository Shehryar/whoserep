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

    // MARK:- Fonts: General
    
    public var headlineFont: UIFont = Fonts.latoBoldFont(withSize: 24)
    
    public var bodyFont: UIFont = Fonts.latoRegularFont(withSize: 15)
    
    public var bodyBoldFont: UIFont = Fonts.latoBoldFont(withSize: 15)
    
    public var detailFont: UIFont = Fonts.latoBoldFont(withSize: 12)
    
    public var captionFont: UIFont = Fonts.latoBoldFont(withSize: 10)
    
    public var buttonFont: UIFont = Fonts.latoBlackFont(withSize: 12)
    
    public var asappButtonFont: UIFont = Fonts.latoBlackFont(withSize: 12)

    public var navBarButtonFont: UIFont = Fonts.latoBlackFont(withSize: 11)
    
    // MARK:- Colors: Messages
    
    public var replyMessageFillColor: UIColor = UIColor(red:0.941, green:0.945, blue:0.953, alpha:1)
    
    public var replyMessageStrokeColor: UIColor? = nil
    
    public var replyMessageTextColor: UIColor = UIColor(red:0.264, green:0.278, blue:0.316, alpha:1)
    
    public var messageStrokeColor: UIColor? = UIColor(red:0.749, green:0.757, blue:0.790, alpha:1)
    
    public var messageFillColor: UIColor = Colors.whiteColor()
    
    public var messageTextColor: UIColor = UIColor(red:0.476, green:0.498, blue:0.565, alpha:1)
    
    // MARK:- Colors: General
    
    internal var navBarButtonColor: UIColor = UIColor(red:0.355, green:0.394, blue:0.494, alpha:1)
    
    internal var navBarBackgroundColor: UIColor = Colors.whiteColor()
    
    internal var navBarButtonForegroundColor: UIColor = UIColor(red:0.264, green:0.278, blue:0.316, alpha:1)
    
    internal var navBarButtonBackgroundColor: UIColor = UIColor(red:0.866, green:0.878, blue:0.907, alpha:1)
    
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
        
        styles.headlineFont = Fonts.xfinitySansBoldFont(withSize: 24)
        styles.bodyFont = Fonts.xfinitySansRegFont(withSize: 15)
        styles.bodyBoldFont = Fonts.xfinitySansBoldFont(withSize: 15)
        styles.detailFont = Fonts.xfinitySansBoldFont(withSize: 12)
        styles.captionFont = Fonts.xfinitySansMedFont(withSize: 10)
        styles.buttonFont = Fonts.xfinitySansBoldCondFont(withSize: 12)
        styles.asappButtonFont = Fonts.xfinitySansBoldCondFont(withSize: 13)
        styles.navBarButtonFont = Fonts.xfinitySansBoldCondFont(withSize: 11)
        
        return styles
    }
    
    class func sprintStyles() -> ASAPPStyles {
        let styles = ASAPPStyles()

        styles.asappButtonBackgroundColor = UIColor(red:0.989, green:0.811, blue:0.003, alpha:1)
        styles.asappButtonForegroundColor = UIColor.black
        styles.asappButtonFont = Fonts.sprintSansBoldFont(withSize: 12)
        
        styles.headlineFont = Fonts.sprintSansBoldFont(withSize: 24)
        styles.bodyFont = Fonts.sprintSansRegularFont(withSize: 15)
        styles.bodyBoldFont = Fonts.sprintSansBoldFont(withSize: 15)
        styles.detailFont = Fonts.sprintSansBoldFont(withSize: 12)
        styles.captionFont = Fonts.sprintSansMediumFont(withSize: 10)
        styles.buttonFont = Fonts.sprintSansBoldFont(withSize: 12)
        
        styles.navBarButtonFont = Fonts.sprintSansBlackFont(withSize: 11)
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
        styles.backgroundColor2 = UIColor(red: 0.07, green: 0.09, blue: 0.1, alpha: 1)
        styles.foregroundColor1 = UIColor.white
        styles.foregroundColor2 = UIColor(red:0.346, green:0.392, blue:0.409, alpha:1)
        styles.separatorColor1 = UIColor(red:0.15, green:0.18, blue:0.19, alpha:1)
        
        /*
        styles.backgroundColor1 = UIColor(red:0.094,  green:0.094,  blue:0.094, alpha:1)
        styles.backgroundColor2 = UIColor(red:0.127,  green:0.127,  blue:0.127, alpha:1)
        styles.foregroundColor1 = UIColor.white
        styles.foregroundColor2 = UIColor(red:0.627,  green:0.627,  blue:0.627, alpha:1)
        styles.separatorColor1 = UIColor(red:0.197,  green:0.197,  blue:0.197, alpha:1)
        */
        
        styles.separatorColor2 =  UIColor(red:0.08,  green:0.08,  blue:0.08, alpha:1)
        
        styles.messageFillColor = UIColor(red:0.13,  green:0.15,  blue:0.16, alpha:1)
        styles.messageStrokeColor = nil
        styles.messageTextColor = UIColor.white
        
        styles.replyMessageFillColor = UIColor(red:0.241, green:0.255, blue:0.26, alpha:1)
        styles.replyMessageTextColor = UIColor.white
        styles.replyMessageStrokeColor = nil
        
        styles.inputBackgroundColor = UIColor(red:0.09,  green:0.1,  blue:0.11, alpha:1)
        styles.inputTintColor = UIColor(red:0.269,  green:0.726,  blue:0.287, alpha:1)
        styles.inputPlaceholderColor = styles.foregroundColor2
        styles.inputTextColor = styles.foregroundColor1
        styles.inputSendButtonColor = UIColor.white
        styles.inputImageButtonColor = UIColor.white
        
        styles.askViewGradientTopColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.6)
        styles.askViewGradientMiddleColor = UIColor(red:0.08, green:0.08, blue:0.08, alpha:0.6)
        styles.askViewGradientBottomColor = UIColor(red:0.1, green:0.1, blue:0.1, alpha:0.6)
        styles.askViewDetailLabelColor = UIColor(red:0.345, green:0.356, blue:0.390, alpha:1)
        styles.askViewButtonBgColor = UIColor(red:0.23, green:0.26, blue:0.28, alpha:1)
        styles.askViewInputBgColor = UIColor(red:0.02, green:0.023, blue:0.025, alpha:1)
        
        return styles
    }
}

protocol ASAPPStyleable {
    
    var styles: ASAPPStyles { get }
    
    func applyStyles(_ styles: ASAPPStyles)
}
