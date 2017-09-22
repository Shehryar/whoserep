//
//  ASAPPStyles.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/3/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

@objcMembers
public class ASAPPStyles: NSObject {
    
    public var textStyles = ASAPPTextStyles()
    
    public var colors = ASAPPColors()
    
    public var separatorStrokeWidth: CGFloat = 1.0
    
    public var segue: ASAPPSegue = .present
    
    public var navBarStyles = ASAPPNavBarStyles()
}

extension ASAPPStyles {
    internal func closeButtonSide(for segue: ASAPPSegue) -> NavBarButtonSide {
        return segue == .present ? .right : .left
    }
}
