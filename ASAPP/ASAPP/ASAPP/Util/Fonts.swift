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
        loadFont("Lato-Regular", type: "ttf")
        loadFont("Lato-Bold", type: "ttf")
        loadFont("Lato-Black", type: "ttf")
        loadFont("Lato-Light", type: "ttf")
    }
    
    class func loadFont(name: String, type: String) {
        guard let path = framework.pathForResource(name, ofType: type) else {
            return
        }
        
        let data = NSData(contentsOfFile: path)
        var err: Unmanaged<CFError>?
        let provider = CGDataProviderCreateWithCFData(data)
        if let font = CGFontCreateWithDataProvider(provider) {
            CTFontManagerRegisterGraphicsFont(font, &err)
            if err != nil {
                ASAPPLoge(err)
            }
        }
    }
    
    // MARK:- Fonts
    
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
}
