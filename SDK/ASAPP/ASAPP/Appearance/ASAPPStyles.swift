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
    
    ///  The orientation(s) in which ASAPP is allowed to appear.
    ///  Defaults to `.portraitLocked`.
    ///  Notes:
    ///  1. Landscape orientation is not supported on iPhone.
    ///  2. With iOS 11+ when the client app is launched in Landscape mode, then ASAPP is presented
    ///  in Landscape and a transition is made to portrait.
    ///  The keyboard input will detach from the keyboard.
    ///  To avoid this known issue, please rotate to the desired orientation before presenting ASAPP.
    public var allowedOrientations: ASAPPAllowedOrientations = .portraitLocked
}

/// Allowed orientations to display ASAPP, defaults to `.portraitLocked`.
@objc public enum ASAPPAllowedOrientations: Int {
    /// Only portrait.
    case portraitLocked
 
    /// Landscape left/right and portrait.
    case iPadLandscapeAllowed
}

internal extension ASAPPAllowedOrientations {
    
    var orientationMask: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone { return .portrait }
        switch self {
        case .portraitLocked:
            return .portrait
        case .iPadLandscapeAllowed:
            return .all
        }
    }
    
    var preferredPresentationOrientation: UIInterfaceOrientation {
        if UIDevice.current.userInterfaceIdiom == .phone { return .portrait }
        switch self {
        case .portraitLocked:
            return .portrait
        case .iPadLandscapeAllowed:
            return UIApplication.shared.statusBarOrientation
        }
    }
}
