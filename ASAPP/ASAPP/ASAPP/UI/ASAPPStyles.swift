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
    
    public var headerFont: UIFont = Fonts.latoBoldFont(withSize: 24)
    
    public var subheadFont: UIFont = Fonts.latoBoldFont(withSize: 14)
    
    public var bodyFont: UIFont = Fonts.latoRegularFont(withSize: 16)
    
    public var detailFont: UIFont = Fonts.latoBoldFont(withSize: 12)
    
    // MARK:- Fonts: View-Specific
    
    public var messageFont: UIFont = Fonts.latoRegularFont(withSize: 16)
    
    public var inputFont: UIFont = Fonts.latoRegularFont(withSize: 16)
    
    public var inputSendButtonFont: UIFont = Fonts.latoBlackFont(withSize: 13)
    
    // MARK:- Colors: General
    
    public var backgroundColor1: UIColor = Colors.whiteColor()
    
    public var backgroundColor2: UIColor = Colors.lighterGrayColor()
    
    public var foregroundColor1: UIColor = Colors.darkTextColor()
    
    public var foregroundColor2: UIColor = Colors.mediumTextColor()
    
    public var separatorColor1: UIColor = Colors.lighterGrayColor()
    
    public var separatorColor2: UIColor = Colors.lightGrayColor()
    
    public var accentColor: UIColor = Colors.blueColor()
    
    // MARK:- Colors; Messages
    
    public var messageFillColor: UIColor = Colors.whiteColor()
    
    public var messageStrokeColor: UIColor? = Colors.lightGrayColor()
    
    public var messageTextColor: UIColor = Colors.darkTextColor()
    
    public var replyMessageFillColor: UIColor = Colors.blueColor()
    
    public var replyMessageStrokeColor: UIColor? = nil
    
    public var replyMessageTextColor: UIColor = Colors.whiteColor()

    // MARK:- Colors: Input
    
    public var inputBackgroundColor: UIColor = Colors.whiteColor()
    
    public var inputBorderTopColor: UIColor = Colors.lighterGrayColor()
    
    public var inputTintColor: UIColor = Colors.grayColor()
    
    public var inputPlaceholderColor: UIColor = Colors.mediumTextColor()
    
    public var inputTextColor: UIColor = Colors.darkTextColor()
    
    public var inputSendButtonColor: UIColor = Colors.blueColor()
    
    public var inputImageButtonColor: UIColor = Colors.mediumTextColor()
    
    
    // MARK:- Preset Styles
    
    public class func darkStyles() -> ASAPPStyles {
        let styles = ASAPPStyles()
        styles.messageFont = UIFont(name: "Avenir-Medium", size: 16) ?? UIFont.systemFontOfSize(16)
        styles.subheadFont = UIFont(name: "Avenir-Heavy", size: 14) ?? UIFont.boldSystemFontOfSize(14)
        styles.detailFont = UIFont(name: "Avenir-Black", size: 12) ?? UIFont.boldSystemFontOfSize(12)
        styles.inputFont = UIFont(name: "Avenir-Medium", size: 16) ?? UIFont.systemFontOfSize(16)
        styles.inputSendButtonFont = UIFont(name: "Avenir-Black", size: 14) ??  UIFont.boldSystemFontOfSize(13)
        
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