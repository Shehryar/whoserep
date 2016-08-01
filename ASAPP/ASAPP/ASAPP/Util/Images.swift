//
//  Images.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class Images: NSObject {
    class func cameraIconDark(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("temp-icon-paperclip", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }
    
    class func testImage(withAlpha alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("test-image.jpg")
    }
    
    // MARK:- Private Helper Methods
    
    private class func imageWithName(name: String, tintColor: UIColor?, fillColor: UIColor?, alpha: CGFloat = 1) -> UIImage? {
        return modifiedImage(imageWithName(name), tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }
    
    private class func imageWithName(name: String) -> UIImage? {
        return UIImage(named: name, inBundle: ASAPPBundle, compatibleWithTraitCollection: nil)
    }
    
    private class func modifiedImage(image: UIImage?, tintColor: UIColor? = nil, fillColor: UIColor?  = nil, alpha: CGFloat = 1) -> UIImage? {
        var modifiedImage: UIImage?
        if let tintColor = tintColor {
            modifiedImage = image?.tint(tintColor, alpha: alpha)
        } else if let fillColor = fillColor {
            modifiedImage = image?.fillAlpha(fillColor, alpha: alpha)
        }
        return modifiedImage
    }
}
