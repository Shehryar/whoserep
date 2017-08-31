//
//  ASAPPColors.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

internal extension UIColor {
    
    // MARK: Whites
    
    static let asapp_alabasterWhite = UIColor(red: 0.988, green: 0.988, blue: 0.988, alpha: 1)
    
    // MARK: Grays
    
    static let asapp_manateeGray = UIColor(red: 0.573, green: 0.600, blue: 0.663, alpha: 1)
    
    // MARK: Blues
    
    static let asapp_ceruleanBlue = UIColor(red: 0.075, green: 0.698, blue: 0.925, alpha: 1)
    
    static let asapp_cometBlue = UIColor(red: 0.357, green: 0.396, blue: 0.494, alpha: 1)
    
    // MARK: Reds
    
    static let asapp_burntSiennaRed = UIColor(red: 0.937, green: 0.463, blue: 0.404, alpha: 1)
    
    // MARK: Patterns
    
    class var asapp_patternBackground: UIColor? {
        if let tileImage = Images.asappImage(.tileImageDash) {
            return UIColor(patternImage: tileImage)
        }
        return nil
    }
}
