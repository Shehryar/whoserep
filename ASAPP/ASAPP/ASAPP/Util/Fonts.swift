//
//  Fonts.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class Fonts: NSObject {
    
    // MARK:- Loading Fonts
    
    override class func initialize() {
        // Lato Fonts
        loadFont("Lato-Regular", type: "ttf")
        loadFont("Lato-Bold", type: "ttf")
        loadFont("Lato-Black", type: "ttf")
        loadFont("Lato-Light", type: "ttf")
        
        // XFINITY Sans Fonts
        loadFont("XFINITYSans-ExLgt", type: "ttf")
        loadFont("XFINITYSans-Lgt", type: "ttf")
        loadFont("XFINITYSans-Thin", type: "ttf")
        loadFont("XFINITYSans-Med", type: "ttf")
        loadFont("XFINITYSans-MedCond", type: "ttf")
        loadFont("XFINITYSans-Reg", type: "otf")
        loadFont("XFINITYSans-Bold", type: "ttf")
        loadFont("XFINITYSans-BoldCond", type: "ttf")
        
//        for family in UIFont.familyNames() {
//            if family.localizedCaseInsensitiveContainsString("lato") || family.localizedCaseInsensitiveContainsString("XFINITY") {
//                print("\n\(family):")
//                for font in UIFont.fontNamesForFamilyName(family) {
//                    print("  \(font)")
//                }
//            }
//        }
    }
    
    class func loadFont(name: String, type: String) {
        guard let path = ASAPPBundle.pathForResource(name, ofType: type) else {
            return
        }
        
        let data = NSData(contentsOfFile: path)
        var err: Unmanaged<CFError>?
        let provider = CGDataProviderCreateWithCFData(data)
        if let font = CGFontCreateWithDataProvider(provider) {
            CTFontManagerRegisterGraphicsFont(font, &err)
            if err != nil {
                DebugLogError(String(err))
            }
        }
    }
    
    // MARK:- Lato Fonts
    
    class func latoLightFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "Lato-Light", size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
    }
    
    class func latoRegularFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "Lato-Regular", size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
    }
    
    class func latoBoldFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "Lato-Bold", size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
    }
    
    class func latoBlackFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "Lato-Black", size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
    }
    
    // MARK:- XFINITY Sans Fonts
    
    class func xfinitySansRegFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "XFINITYSans-Reg", size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
    }
    
    class func xfinitySansMedFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "XFINITYSans-Med", size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
    }
    
    class func xfinitySansBoldFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "XFINITYSans-Bold", size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
    }
    
    class func xfinitySansMedCondFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "XFINITYSans-MedCond", size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
    }
    
    class func xfinitySansBoldCondFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "XFINITYSans-BoldCond", size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
    }
    
    class func xfinitySansLgtFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "XFINITYSans-Lgt", size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
    }
    
    class func xfinitySansExLgtFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "XFINITYSans-ExLgt", size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
    }
    
    class func xfinitySansThinFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "XFINITYSans-Thin", size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
    }
}
