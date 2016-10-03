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
        
    class func loadAllFonts() {
        // Lato Fonts
        Fonts.loadFont("Lato-Regular", type: "ttf")
        Fonts.loadFont("Lato-Bold", type: "ttf")
        Fonts.loadFont("Lato-Black", type: "ttf")
        Fonts.loadFont("Lato-Light", type: "ttf")
        
        // XFINITY Sans Fonts
        Fonts.loadFont("XFINITYSans-ExLgt", type: "ttf")
        Fonts.loadFont("XFINITYSans-Lgt", type: "ttf")
        Fonts.loadFont("XFINITYSans-Thin", type: "ttf")
        Fonts.loadFont("XFINITYSans-Med", type: "ttf")
        Fonts.loadFont("XFINITYSans-MedCond", type: "ttf")
        Fonts.loadFont("XFINITYSans-Reg", type: "otf")
        Fonts.loadFont("XFINITYSans-Bold", type: "ttf")
        Fonts.loadFont("XFINITYSans-BoldCond", type: "ttf")
    }
    
    class func loadedFonts() -> [String] {
        var fontNames = [String]()
        for family in UIFont.familyNames {
            if family.localizedCaseInsensitiveContains("lato") || family.localizedCaseInsensitiveContains("XFINITY") {
                print("\n\(family):")
                for font in UIFont.fontNames(forFamilyName: family) {
                    print("  \(font)")
                    fontNames.append(font)
                }
            }
        }
        return fontNames
    }
    
    class func loadFont(_ name: String, type: String) {
        guard let path = ASAPPBundle.path(forResource: name, ofType: type) else {
            DebugLogError("FONT FAILURE: Unable to find path for resource \(name).\(type)")
            return
        }
        
        if let data = try? NSData(contentsOfFile: path, options: NSData.ReadingOptions(rawValue: UInt(0))),
            let provider = CGDataProvider(data: data) {
            let font = CGFont(provider)
            var err: Unmanaged<CFError>?
            CTFontManagerRegisterGraphicsFont(font, &err)
            if err != nil {
                DebugLogError("FONT FAILURE: received error while loading font \(name).\(type)\n\(err)")
            }
        } else {
            DebugLogError("FONT FAILURE: unable to load data for path \(path)")
        }
    }
    
    // MARK:- Lato Fonts
    
    class func latoLightFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "Lato-Light", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func latoRegularFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "Lato-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func latoBoldFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "Lato-Bold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    class func latoBlackFont(withSize fontSize: CGFloat = 16) -> UIFont {
        return UIFont(name: "Lato-Black", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    // MARK:- XFINITY Sans Fonts
    
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
