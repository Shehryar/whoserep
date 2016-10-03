//
//  ASAPPStyles.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/3/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

open class ASAPPStyles: NSObject {

    // MARK:- Fonts: General
    
    open var headlineFont: UIFont = Fonts.latoBoldFont(withSize: 24)
    
    open var bodyFont: UIFont = Fonts.latoRegularFont(withSize: 15)
    
    open var bodyBoldFont: UIFont = Fonts.latoBoldFont(withSize: 15)
    
    open var detailFont: UIFont = Fonts.latoBoldFont(withSize: 12)
    
    open var captionFont: UIFont = Fonts.latoBoldFont(withSize: 10)
    
    open var buttonFont: UIFont = Fonts.latoBlackFont(withSize: 12)
    
    open var asappButtonFont: UIFont = Fonts.latoBlackFont(withSize: 12)

    // MARK:- Colors: Messages
    
    open var replyMessageFillColor: UIColor = UIColor(red:0.941, green:0.945, blue:0.953, alpha:1)
    
    open var replyMessageStrokeColor: UIColor? = nil
    
    open var replyMessageTextColor: UIColor = UIColor(red:0.264, green:0.278, blue:0.316, alpha:1)
    
    open var messageStrokeColor: UIColor? = UIColor(red:0.749, green:0.757, blue:0.790, alpha:1)
    
    open var messageFillColor: UIColor = Colors.whiteColor()
    
    open var messageTextColor: UIColor = UIColor(red:0.476, green:0.498, blue:0.565, alpha:1)
    
    // MARK:- Colors: General
    
    internal var navBarBackgroundColor: UIColor = Colors.whiteColor()
    
    internal var navBarButtonColor: UIColor = Colors.steelLightColor()
    
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

    // MARK:- Colors: Input
    
    internal var inputBackgroundColor: UIColor = Colors.whiteColor()
    
    internal var inputBorderTopColor: UIColor = Colors.lighterGrayColor()
    
    internal var inputTintColor: UIColor = Colors.grayColor()
    
    internal var inputPlaceholderColor: UIColor = Colors.mediumTextColor()
    
    internal var inputTextColor: UIColor = Colors.darkTextColor()
    
    internal var inputSendButtonColor: UIColor = Colors.blueGrayColor()
    
    internal var inputImageButtonColor: UIColor = Colors.mediumTextColor()
    
    // MARK:- Preset Styles
    
    open class func comcastStyles() -> ASAPPStyles {
        let styles = ASAPPStyles()
        
        styles.headlineFont = Fonts.xfinitySansBoldFont(withSize: 24)
        styles.bodyFont = Fonts.xfinitySansRegFont(withSize: 15)
        styles.bodyBoldFont = Fonts.xfinitySansBoldFont(withSize: 15)
        styles.detailFont = Fonts.xfinitySansBoldFont(withSize: 12)
        styles.captionFont = Fonts.xfinitySansMedFont(withSize: 10)
        styles.buttonFont = Fonts.xfinitySansMedCondFont(withSize: 12)
        styles.asappButtonFont = Fonts.xfinitySansBoldCondFont(withSize: 13)
        
        return styles
    }
}

protocol ASAPPStyleable {
    
    var styles: ASAPPStyles { get }
    
    func applyStyles(_ styles: ASAPPStyles)
}
