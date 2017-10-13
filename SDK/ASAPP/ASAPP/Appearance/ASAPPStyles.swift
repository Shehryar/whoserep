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
    
    /// The width of the stroke of separators such as timestamp headers and chat bubble borders.
    public var separatorStrokeWidth: CGFloat = 1.0
    
    /// How the SDK's view controller is displayed by an `ASAPPButton`.
    public var segue: ASAPPSegue = .present
    
    /// Customizable navigation bar styles.
    public var navBarStyles = ASAPPNavBarStyles()
}

extension ASAPPStyles {
    internal func closeButtonSide(for segue: ASAPPSegue) -> NavBarButtonSide {
        return segue == .present ? .right : .left
    }
}
