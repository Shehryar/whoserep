//
//  ASAPPNavBarStyles.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/7/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

/**
 Customizable navigation bar styles.
 */
@objc(ASAPPNavBarStyles)
@objcMembers
public class ASAPPNavBarStyles: NSObject {
    /// The style of navigation bar buttons. Defaults to `ASAPPNavBarButtonStyle.text`.
    public var buttonStyle: ASAPPNavBarButtonStyle = .text
    
    /// The images used in navigation bar buttons.
    public var buttonImages = ASAPPNavBarButtonImages()
    
    /// The edge insets for the navigation bar title. Defaults to 8 on the sides.
    public var titlePadding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
}
