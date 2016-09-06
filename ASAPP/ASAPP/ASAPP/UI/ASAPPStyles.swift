//
//  ASAPPStyles.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/3/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

public class ASAPPStyles: NSObject {

    // MARK:- Fonts: General
    
    public var headlineFont: UIFont = Fonts.latoBoldFont(withSize: 24)
    
    public var bodyFont: UIFont = Fonts.latoRegularFont(withSize: 15)
    
    public var bodyBoldFont: UIFont = Fonts.latoBoldFont(withSize: 15)
    
    public var detailFont: UIFont = Fonts.latoBoldFont(withSize: 12)
    
    public var captionFont: UIFont = Fonts.latoBoldFont(withSize: 10)
    
    public var buttonFont: UIFont = Fonts.latoBlackFont(withSize: 12)

    // MARK:- Colors: Messages
    
    public var replyMessageFillColor: UIColor = Colors.steelLightColor()
    
    public var replyMessageStrokeColor: UIColor? = nil
    
    public var replyMessageTextColor: UIColor = Colors.whiteColor()
    
    public var messageStrokeColor: UIColor? = Colors.steelLightColor().colorWithAlphaComponent(0.5)
    
    public var messageFillColor: UIColor = Colors.whiteColor()
    
    public var messageTextColor: UIColor = Colors.steelLightColor()
    
    // MARK:- Colors: General
    
    internal var backgroundColor1: UIColor = Colors.whiteColor()
    
    internal var backgroundColor2: UIColor = Colors.offWhiteColor()
    
    internal var foregroundColor1: UIColor = Colors.steelLightColor()
    
    internal var foregroundColor2: UIColor = Colors.steelMedColor()
    
    internal var separatorColor1: UIColor = Colors.marbleLightColor()
    
    internal var separatorColor2: UIColor = Colors.marbleDarkColor()
    
    internal var accentColor: UIColor = Colors.steelLightColor()

    // MARK:- Colors: Input
    
    internal var inputBackgroundColor: UIColor = Colors.whiteColor()
    
    internal var inputBorderTopColor: UIColor = Colors.lighterGrayColor()
    
    internal var inputTintColor: UIColor = Colors.grayColor()
    
    internal var inputPlaceholderColor: UIColor = Colors.mediumTextColor()
    
    internal var inputTextColor: UIColor = Colors.darkTextColor()
    
    internal var inputSendButtonColor: UIColor = Colors.blueGrayColor()
    
    internal var inputImageButtonColor: UIColor = Colors.mediumTextColor()
    
    // MARK:- Preset Styles
    
    public class func darkStyles() -> ASAPPStyles {
        let styles = ASAPPStyles()
        styles.bodyFont = UIFont(name: "Avenir-Medium", size: 16) ?? UIFont.systemFontOfSize(16)
        styles.detailFont = UIFont(name: "Avenir-Heavy", size: 12) ?? UIFont.boldSystemFontOfSize(12)
        styles.captionFont = UIFont(name: "Avenir-Heavy", size: 10) ?? UIFont.boldSystemFontOfSize(10)
        styles.buttonFont = UIFont(name: "Avenir-Heavy", size: 14) ?? UIFont.boldSystemFontOfSize(14)
            
        styles.backgroundColor1 = UIColor(red:0.094,  green:0.094,  blue:0.094, alpha:1)
        styles.backgroundColor2 = UIColor(red:0.157,  green:0.157,  blue:0.157, alpha:1)
        styles.foregroundColor1 = UIColor.whiteColor()
        styles.foregroundColor2 = UIColor(red:0.627,  green:0.627,  blue:0.627, alpha:1)
        styles.separatorColor1 = UIColor(red:0.157,  green:0.157,  blue:0.157, alpha:1)
        styles.separatorColor2 =  UIColor(red:0.094,  green:0.094,  blue:0.094, alpha:1)
        
        styles.messageFillColor = styles.backgroundColor2
        styles.messageStrokeColor = nil
        styles.messageTextColor = styles.foregroundColor2
        
        styles.replyMessageFillColor = UIColor(red:0.269,  green:0.726,  blue:0.287, alpha:1)
        styles.replyMessageTextColor = UIColor.whiteColor()
        styles.replyMessageStrokeColor = nil
        
        styles.inputBackgroundColor = styles.backgroundColor2
        styles.inputBorderTopColor = styles.separatorColor2
        styles.inputTintColor = UIColor(red:0.269,  green:0.726,  blue:0.287, alpha:1)
        styles.inputPlaceholderColor = styles.foregroundColor2
        styles.inputTextColor = styles.foregroundColor1
        styles.inputSendButtonColor = UIColor(red:0.269,  green:0.726,  blue:0.287, alpha:1)
        styles.inputImageButtonColor = UIColor(red:0.269,  green:0.726,  blue:0.287, alpha:1)
        
        return styles
    }
}

protocol ASAPPStyleable {
    
    var styles: ASAPPStyles { get }
    
    func applyStyles(styles: ASAPPStyles)
}