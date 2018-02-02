//
//  ASAPPColors.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

internal extension UIColor {
    struct ASAPP {
        static let eggplant = UIColor(red: 0.33, green: 0.33, blue: 0.89, alpha: 1)
        static let alabasterWhite = UIColor(red: 0.988, green: 0.988, blue: 0.988, alpha: 1)
        static let manateeGray = UIColor(red: 0.573, green: 0.600, blue: 0.663, alpha: 1)
        static let ceruleanBlue = UIColor(red: 0.075, green: 0.698, blue: 0.925, alpha: 1)
        static let cometBlue = UIColor(red: 0.357, green: 0.396, blue: 0.494, alpha: 1)
        static let burntSiennaRed = UIColor(red: 0.937, green: 0.463, blue: 0.404, alpha: 1)
        
        static var patternBackground: UIColor? {
            if let tileImage = Images.getImage(.tileImageDash) {
                return UIColor(patternImage: tileImage)
            }
            return nil
        }
    }
}
