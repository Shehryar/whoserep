//
//  ASAPPStyles.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/3/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

public class ASAPPStyles: NSObject {
    
    public var textStyles = ASAPPTextStyles()
    
    public var colors = ASAPPColors()
    
    public var separatorStrokeWidth: CGFloat = 1.0
    
    public var navBarButtonStyle: ASAPPNavBarButtonStyle = .bubble
    
    public var navBarButtonImages = ASAPPNavBarButtonImages()
    
    public var navBarTitlePadding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    
    public var segue: ASAPPSegue = .present
}

extension ASAPPStyles {
    internal func closeButtonSide(for segue: ASAPPSegue) -> NavBarButtonSide {
        return segue == .present ? .right : .left
    }
}
