//
//  ASAPPStyles.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/3/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

public class ASAPPStyles: NSObject {
    
    public var textStyles: ASAPPTextStyles = ASAPPTextStyles()
    
    public var colors: ASAPPColors = ASAPPColors()
    
    public var navBarButtonStyle: ASAPPNavBarButtonStyle = .bubble
    
    public var separatorStrokeWidth: CGFloat = UIScreen.main.scale > 1 ? 0.5 : 1.0
}
