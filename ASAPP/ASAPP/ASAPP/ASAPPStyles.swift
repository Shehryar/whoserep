//
//  ASAPPStyles.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/3/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

public class ASAPPStyles: NSObject {
            
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
    
    // MARK:- Colors: ASAPP Button
    
    public var asappButtonForegroundColor: UIColor = UIColor.white
    
    public var asappButtonBackgroundColor: UIColor = UIColor(red:0.374, green:0.392, blue:0.434, alpha:1)
    
    // MARK:- Colors: Predictive
    
    internal var askViewGradientTopColor: UIColor = UIColor(red:0.302, green:0.310, blue:0.347, alpha:0.9)
    
    internal var askViewGradientMiddleColor: UIColor = UIColor(red:0.366, green:0.384, blue:0.426, alpha:0.8)
    
    internal var askViewGradientBottomColor: UIColor = UIColor(red:0.483, green:0.505, blue:0.568, alpha:0.8)
    
    internal var askViewDetailLabelColor: UIColor = Colors.steelMed50Color()
    
    internal var askViewButtonBgColor: UIColor = UIColor(red:0.492, green:0.513, blue:0.547, alpha:1)
    
    internal var askViewInputBgColor: UIColor = UIColor(red:0.232, green:0.247, blue:0.284, alpha:1)
    
    // MARK:- Colors: Chat Input
    
    internal var inputBackgroundColor: UIColor = Colors.whiteColor()
    
    internal var inputBorderTopColor: UIColor = Colors.lighterGrayColor()
    
    internal var inputTintColor: UIColor = Colors.grayColor()
    
    internal var inputPlaceholderColor: UIColor = Colors.mediumTextColor()
    
    internal var inputTextColor: UIColor = Colors.darkTextColor()
    
    internal var inputSendButtonColor: UIColor = Colors.blueGrayColor()
    
    internal var inputImageButtonColor: UIColor = Colors.mediumTextColor()
    
    
    
    // MARK:- Init
    
    override init() {
        Fonts.loadFontsIfNecessary()
        
        super.init()
    }
}
