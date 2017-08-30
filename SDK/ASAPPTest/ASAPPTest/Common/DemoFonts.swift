//
//  DemoFonts.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/24/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class DemoFonts: NSObject {
    
    class func avenirBook(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "Avenir-Book", size: size)
    }
    
    class func avenirRoman(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "Avenir-Roman", size: size)
    }
    
    class func avenirMedium(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "Avenir-Medium", size: size)
    }
    
    class func avenirHeavy(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "Avenir-Heavy", size: size)
    }
    
    class func avenirBlack(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "Avenir-Black", size: size)
    }
}

// MARK:- Lato

extension DemoFonts {
    
    class func latoLightFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "Lato-Light", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func latoRegularFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "Lato-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func latoBoldFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "Lato-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
    }
    
    class func latoBlackFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "Lato-Black", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
    }
}

// MARK:- XFINITY Sans Fonts

extension DemoFonts {
    
    class func xfinitySansRegFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "XFINITYSans-Reg", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func xfinitySansMedFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "XFINITYSans-Med", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func xfinitySansBoldFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "XFINITYSans-Bold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func xfinitySansMedCondFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "XFINITYSans-MedCond", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func xfinitySansBoldCondFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "XFINITYSans-BoldCond", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func xfinitySansLgtFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "XFINITYSans-Lgt", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func xfinitySansExLgtFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "XFINITYSans-ExLgt", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func xfinitySansThinFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "XFINITYSans-Thin", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
}

// MARK:- SprintSans Fonts

extension DemoFonts {
    
    class func sprintSansRegularFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "SprintSans-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func sprintSansRegularItalicFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "SprintSans-RegularItalic", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func sprintSansMediumFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "SprintSans-Medium", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func sprintSansBoldFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "SprintSans-Bold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func sprintSansBlackFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "SprintSans-Black", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
}
