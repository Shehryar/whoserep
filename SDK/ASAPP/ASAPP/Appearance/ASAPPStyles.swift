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
    
    public var separatorStrokeWidth: CGFloat = 1.0
    
    public var navBarTitlePadding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
}
