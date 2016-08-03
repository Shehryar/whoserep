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
    
    public var messageFont: UIFont = Fonts.latoRegularFont(withSize: 16)
    
    public var subheadFont: UIFont = Fonts.latoBoldFont(withSize: 12)
    
    public var inputFont: UIFont = Fonts.latoRegularFont(withSize: 16)
    
    public var inputSendButtonFont: UIFont = Fonts.latoBlackFont(withSize: 13)
    
    // MARK:- Colors - Messages
    
    public var chatBackgroundColor: UIColor = Colors.whiteColor()
    
    public var messageFillColor: UIColor = Colors.whiteColor()
    
    public var messageStrokeColor: UIColor? = Colors.lightGrayColor()
    
    public var messageTextColor: UIColor = Colors.darkTextColor()
    
    public var replyMessageFillColor: UIColor = Colors.blueColor()
    
    public var replyMessageStrokeColor: UIColor? = nil
    
    public var replyMessageTextColor: UIColor = Colors.whiteColor()

    // MARK:- Colors - Input
    
    public var inputBackgroundColor: UIColor = Colors.whiteColor()
    
    public var inputBorderTopColor: UIColor = Colors.lighterGrayColor()
    
    public var inputTintColor: UIColor = Colors.grayColor()
    
    public var inputPlaceholderColor: UIColor = Colors.mediumTextColor()
    
    public var inputTextColor: UIColor = Colors.darkTextColor()
    
    public var inputSendButtonColor: UIColor = Colors.blueColor()
    
    public var inputImageButtonColor: UIColor = Colors.mediumTextColor()
}

protocol ASAPPStyleable {
    
    var styles: ASAPPStyles { get set }
    
    func applyStyles(styles: ASAPPStyles)
}