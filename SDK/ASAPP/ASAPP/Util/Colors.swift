//
//  Colors.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class Colors: NSObject {
    
    class func steelLightColor() -> UIColor {
        return UIColor(red: 121.0 / 255.0, green: 127.0 / 255.0, blue: 144.0 / 255.0, alpha: 1.0)
    }
    
    class func steelLight50Color() -> UIColor {
        return UIColor(red: 208.0 / 255.0, green: 210.0 / 255.0, blue: 217.0 / 255.0, alpha: 1.0)
    }
    
    class func steelMedColor() -> UIColor {
        return UIColor(red: 91.0 / 255.0, green: 101.0 / 255.0, blue: 126.0 / 255.0, alpha: 1.0)
    }
    
    class func steelMed50Color() -> UIColor {
        return UIColor(red: 173 / 255.0, green: 178 / 255.0, blue: 190 / 255.0, alpha: 1.0)
    }
    
    class func steelDarkColor() -> UIColor {
        return UIColor(red: 57.0 / 255.0, green: 61.0 / 255.0, blue: 71.0 / 255.0, alpha: 0.95)
    }
    
    class func steelDark50Color() -> UIColor {
        return UIColor(red: 157 / 255.0, green: 158 / 255.0, blue: 163 / 255.0, alpha: 0.95)
    }
    
    class func marbleLightColor() -> UIColor {
        return UIColor(red: 236.0 / 255.0, green: 231.0 / 255.0, blue: 231.0 / 255.0, alpha: 1.0)
    }
    
    class func marbleMedColor() -> UIColor {
        return UIColor(red: 243.0 / 255.0, green: 238.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0)
    }
    
    class func marbleDarkColor() -> UIColor {
        return UIColor(red: 201.0 / 255.0, green: 196.0 / 255.0, blue: 196.0 / 255.0, alpha: 1.0)
    }
    
    class func offWhiteColor() -> UIColor {
        return UIColor(red:0.972, green:0.969, blue:0.968, alpha:1)
    }
    
    class func whiteColor() -> UIColor {
        return UIColor.white
    }
    
    class func patternBackgroundColor() -> UIColor? {
        if let tileImage = Images.asappImage(.tileImageDash) {
            return UIColor(patternImage: tileImage)
        }
        return nil
    }
    
    
    class func redColor() -> UIColor { return UIColor(red:0.921,  green:0.401,  blue:0.336, alpha:1) }
    
    class func blueColor() -> UIColor { return UIColor(red:0.226,  green:0.605,  blue:0.852, alpha:1) }
    class func tealColor() -> UIColor { return UIColor(red:0.210,  green:0.674,  blue:0.643, alpha:1) }
    class func fadedRedColor() -> UIColor { return UIColor(red:0.927,  green:0.451,  blue:0.376, alpha:1) }
    
    class func bluishGray() -> UIColor { return UIColor(red:0.555,  green:0.595,  blue:0.692, alpha:1) }
    class func blueGrayColor() -> UIColor { return UIColor(red:0.476,  green:0.498,  blue:0.565, alpha:1) }
    
    // MARK: Grays
    class func darkTextColor() -> UIColor { return UIColor(red:0.283,  green:0.290,  blue:0.307, alpha:1) }
    class func mediumTextColor() -> UIColor { return UIColor(red:0.535,  green:0.557,  blue:0.586, alpha:1) }
    class func grayColor() -> UIColor { return UIColor(red:0.682,  green:0.682,  blue:0.682, alpha:1) }
    class func lightGrayColor() -> UIColor { return UIColor(red:0.862,  green:0.851,  blue:0.859, alpha:1) }
    class func lighterGrayColor() -> UIColor { return UIColor(red:0.937,  green:0.945,  blue:0.949, alpha:1) }
}
