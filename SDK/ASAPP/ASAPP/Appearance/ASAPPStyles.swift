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
@objcMembers
public class ASAPPStyles: NSObject {
    
    /// Customizable text styles.
    public var textStyles = ASAPPTextStyles()
    
    /// Customizable colors.
    public var colors = ASAPPColors()
    
    /// Customizable shape properties.
    public var shapeStyles = ASAPPShapeStyles()
    
    /// How the SDK's view controller is displayed by an `ASAPPButton`.
    public var segue: ASAPPSegue = .present
    
    /// Customizable navigation bar styles.
    public var navBarStyles = ASAPPNavBarStyles()
    
    /// How the welcome page's options are laid out.
    public var welcomeLayout: ASAPPWelcomeLayout = .buttonMenu
}

extension ASAPPStyles {
    internal func closeButtonSide(for segue: ASAPPSegue) -> NavBarButtonSide {
        return segue == .present ? .right : .left
    }
}
