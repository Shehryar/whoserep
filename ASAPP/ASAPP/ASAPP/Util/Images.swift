//
//  Images.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class Images: NSObject {
    class func paperclipIcon(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("temp-icon-paperclip", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }
    
    class func xIcon(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("temp-icon-x", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }

    class func xLightIcon(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("temp-icon-x-light", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }
    
    class func asappButtonIcon(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("asapp-logo", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }
    
    // MARK:- Private Helper Methods
    
    private class func imageWithName(name: String, tintColor: UIColor?, fillColor: UIColor?, alpha: CGFloat = 1) -> UIImage? {
        let image = imageWithName(name)
        let modImage = modifiedImage(image, tintColor: tintColor, fillColor: fillColor, alpha: alpha)
        return modImage
    }
    
    private class func imageWithName(name: String) -> UIImage? {
        let image = UIImage(named: name, inBundle: ASAPPBundle, compatibleWithTraitCollection: nil)
        
        return image
    }
    
    private class func modifiedImage(image: UIImage?, tintColor: UIColor? = nil, fillColor: UIColor?  = nil, alpha: CGFloat = 1) -> UIImage? {
        var modifiedImage: UIImage?
        if let tintColor = tintColor {
            modifiedImage = image?.tint(tintColor, alpha: alpha)
        } else if let fillColor = fillColor {
            modifiedImage = image?.fillAlpha(fillColor, alpha: alpha)
        }
        return modifiedImage ?? image
    }
}
