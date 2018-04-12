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
    
    /// Whether primary Component buttons have rounded corners.
    public var primaryButtonsRounded = false
}

extension ASAPPStyles {
    internal func closeButtonSide(for segue: ASAPPSegue) -> NavBarButtonSide {
        return segue == .present ? .right : .left
    }
}
