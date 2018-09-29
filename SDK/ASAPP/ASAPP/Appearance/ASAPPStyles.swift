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
    
    /// Customizable navigation bar styles.
    public var navBarStyles = ASAPPNavBarStyles()
    
    /// The rounding style of primary Component buttons. .pill is equivalent to a radius of half the height of the button. Defaults to .radius(0).
    public var primaryButtonRoundingStyle = ASAPPPrimaryButtonRoundingStyle.radius(0)
}
