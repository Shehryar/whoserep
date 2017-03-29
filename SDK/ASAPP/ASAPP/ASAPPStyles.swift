//
//  ASAPPStyles.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/3/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

@objc
public enum ASAPPNavBarButtonStyle: Int {
    case bubble = 0
    case text = 1
}

public class ASAPPStyles: NSObject {
    
    // MARK:- Fonts
    
    public var fontNameLight: String = "Lato-Light"
    
    public var fontNameRegular: String = "Lato-Regular"
    
    public var fontNameBold: String = "Lato-Bold"
    
    public var fontNameBlack: String = "Lato-Black"
    
    // MARK:- Navigation Bar
    
    public var navBarBackgroundColor: UIColor = Colors.whiteColor()
    
    public var navBarButtonColor: UIColor = UIColor(red:0.355, green:0.394, blue:0.494, alpha:1)
    
    public var navBarButtonForegroundColor: UIColor = UIColor(red:0.264, green:0.278, blue:0.316, alpha:1)
    
    public var navBarButtonBackgroundColor: UIColor = UIColor(red:0.866, green:0.878, blue:0.907, alpha:1)
    
    public var navBarButtonStyle: ASAPPNavBarButtonStyle = .bubble
    
    // MARK:- Buttons
    
    public var textButtonColor: UIColor = UIColor(red:0.125, green:0.714, blue:0.931, alpha:1)
    
    public var textButtonColorHighlighted: UIColor = UIColor(red:0.125, green:0.714, blue:0.931, alpha:0.5)
    
    public var textButtonColorDisabled: UIColor = UIColor(red:0.6, green:0.6, blue:0.6, alpha:1)
    
    public var primaryButtonBgColor: UIColor = UIColor(red:0.204, green:0.698, blue:0.925, alpha:1.000)
    
    public var primaryButtonBgColorHighlighted: UIColor = UIColor(red:0.105, green:0.644, blue:0.851, alpha:1)
    
    public var primaryButtonBgColorDisabled: UIColor = UIColor(red:0.6, green:0.6, blue:0.6, alpha:1)
    
    public var primaryButtonTextColor: UIColor = UIColor.white
    
    public var secondaryButtonBgColor: UIColor = UIColor(red:0.953, green:0.957, blue:0.965, alpha:1.000)
    
    public var secondaryButtonBgColorHighlighted: UIColor = UIColor(red:0.903, green:0.907, blue:0.915, alpha:1.000)
    
    public var secondaryButtonBgColorDisabled: UIColor = UIColor(red:0.6, green:0.6, blue:0.6, alpha:1)
    
    public var secondaryButtonBorderColor: UIColor = UIColor(red:0.886, green:0.890, blue:0.906, alpha:1.000)
    
    public var secondaryButtonTextColor: UIColor = UIColor(red:0.357, green:0.396, blue:0.494, alpha:1.000)
    
    // MARK:- General Content
    
    internal var backgroundColor1: UIColor = Colors.whiteColor()
    
    internal var backgroundColor2: UIColor = Colors.offWhiteColor()
    
    internal var foregroundColor1: UIColor = Colors.steelDarkColor()
    
    internal var foregroundColor2: UIColor = Colors.steelDark50Color()
    
    public var controlTintColor: UIColor = UIColor(red:0.075, green:0.698, blue:0.925, alpha:1.000)
    
    public var controlSecondaryColor: UIColor = UIColor(red:0.898, green:0.906, blue:0.918, alpha:1.000)
    
    internal var separatorColor1: UIColor = Colors.marbleLightColor()
    
    internal var separatorColor2: UIColor = Colors.marbleDarkColor()
    
    
    // MARK:- Colors: Messages
    
    public var replyMessageFillColor: UIColor = UIColor(red:0.941, green:0.945, blue:0.953, alpha:1)
    
    public var replyMessageStrokeColor: UIColor? = nil
    
    public var replyMessageTextColor: UIColor = UIColor(red:0.264, green:0.278, blue:0.316, alpha:1)
    
    public var messageStrokeColor: UIColor? = UIColor(red:0.749, green:0.757, blue:0.790, alpha:1)
    
    public var messageFillColor: UIColor = Colors.whiteColor()
    
    public var messageTextColor: UIColor = UIColor(red:0.476, green:0.498, blue:0.565, alpha:1)
    
    // MARK:- Colors: Predictive
    
    public var predictiveNavBarButtonColor: UIColor = UIColor.white
    
    public var predictiveNavBarButtonForegroundColor: UIColor = UIColor.white
    
    public var predictiveNavBarButtonBackgroundColor: UIColor = UIColor(red:0.201, green:0.215, blue:0.249, alpha:1)
    
    internal var predictiveViewGradientTopColor: UIColor = UIColor(red:0.302, green:0.310, blue:0.347, alpha:0.9)
    
    internal var predictiveViewGradientMiddleColor: UIColor = UIColor(red:0.366, green:0.384, blue:0.426, alpha:0.8)
    
    internal var predictiveViewGradientBottomColor: UIColor = UIColor(red:0.483, green:0.505, blue:0.568, alpha:0.8)
    
    internal var predictiveViewDetailLabelColor: UIColor = Colors.steelMed50Color()
    
    internal var predictiveViewButtonBgColor: UIColor = UIColor(red:0.492, green:0.513, blue:0.547, alpha:1)
    
    internal var predictiveViewInputBgColor: UIColor = UIColor(red:0.232, green:0.247, blue:0.284, alpha:1)
    
    // MARK:- Colors: Chat Input
    
    internal var inputBackgroundColor: UIColor = Colors.whiteColor()
    
    internal var inputBorderTopColor: UIColor = Colors.lighterGrayColor()
    
    internal var inputTintColor: UIColor = Colors.grayColor()
    
    internal var inputPlaceholderColor: UIColor = Colors.mediumTextColor()
    
    internal var inputTextColor: UIColor = Colors.darkTextColor()
    
    internal var inputSendButtonColor: UIColor = Colors.blueGrayColor()
    
    internal var inputImageButtonColor: UIColor = Colors.mediumTextColor()
    
    
    internal var quickReplyButtonBackroundColor: UIColor = Colors.offWhiteColor()
    
    internal var quickRepliesButtonTextColor: UIColor = Colors.steelMedColor()
    
    
    
    
    // MARK:- Help Button
    
    public var helpButtonForegroundColor: UIColor = UIColor.white
    
    public var helpButtonBackgroundColor: UIColor = UIColor(red:0.374, green:0.392, blue:0.434, alpha:1)
    
    
    // MARK:- Init
    
    override init() {
        Fonts.loadFontsIfNecessary()
        
        super.init()
    }
}
