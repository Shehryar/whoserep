//
//  ASAPPStyles.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/3/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

/**
 Holds customizable styles and other visual SDK settings.
 */
@objc(ASAPPStyles)
@objcMembers
public class ASAPPStyles: NSObject {
    
    /// Customizable text styles.
    public var textStyles = ASAPPTextStyles()
    
    /// Customizable colors.
    public var colors = ASAPPColors()
    
    /// How the SDK's view controller is displayed by an `ASAPPButton`.
    public var segue: ASAPPSegue = .push
    
    /// Customizable navigation bar styles.
    public var navBarStyles = ASAPPNavBarStyles()
    
    /// How the welcome page's options are laid out.
    public var welcomeLayout: ASAPPWelcomeLayout = .buttonMenu
    
    /// The width of the stroke of separators such as timestamp headers and chat bubble borders.
    public var separatorStrokeWidth: CGFloat = 1.0
    
    /// Whether primary Component buttons have rounded corners.
    public var primaryButtonsRounded = false
    
    /// The send button image. If nil, `ASAPPStrings.predictiveSendButton` or `ASAPPStrings.chatInputSend` is displayed instead.
    lazy public var sendButtonImage: ASAPPCustomImage? = {
        return ASAPPCustomImage(image: Images.getImage(.iconSend)!, size: CGSize(width: 26, height: 26))
    }()
}

extension ASAPPStyles {
    internal func closeButtonSide(for segue: ASAPPSegue) -> NavBarButtonSide {
        return segue == .present ? .right : .left
    }
}
