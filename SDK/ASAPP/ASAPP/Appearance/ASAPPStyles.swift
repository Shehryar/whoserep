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
    /// Style of rounding button corners.
    public enum ASAPPButtonRoundingStyle {
        /// Fully rounded by setting the corner radius to half the height of the button.
        case pill
        
        /// Arbitrary, absolute corner radius.
        case radius(CGFloat)
    }
    
    /// Customizable text styles.
    public var textStyles = ASAPPTextStyles()
    
    /// Customizable colors.
    public var colors = ASAPPColors()
    
    /// Customizable navigation bar styles.
    public var navBarStyles = ASAPPNavBarStyles()
    
    /// The corner rounding style of primary Component buttons. Can be set to .radius(x) or .pill. Defaults to .radius(0).
    public var primaryButtonRoundingStyle: ASAPPButtonRoundingStyle = .radius(0)
}
