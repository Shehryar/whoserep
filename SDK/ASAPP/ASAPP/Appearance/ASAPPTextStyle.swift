//
//  TextStyle.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class ASAPPTextStyle: NSObject {
    
    // MARK: Properties (final)
    
    let fontName: String
    
    let defaultSize: CGFloat
    
    let letterSpacing: CGFloat
    
    let color: UIColor
    
    // MARK: Properties (dynamic)
    
    var size: CGFloat {
        return TextSizeCategory.dynamicFontSize(defaultSize)
    }
    
    var font: UIFont {
        if let font = UIFont(name: fontName, size: size) {
            return font
        }
        
        DebugLog.w(caller: self, "Unable to create font with name: \(fontName)")
        
        return UIFont.systemFont(ofSize: size)
    }
    
    // MARK: Init
    
    init(fontName: String, size: CGFloat, letterSpacing: CGFloat, color: UIColor) {
        self.fontName = fontName
        self.defaultSize = size
        self.letterSpacing = letterSpacing
        self.color = color
        super.init()
    }
}
