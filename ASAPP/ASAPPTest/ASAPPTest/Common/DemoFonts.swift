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
