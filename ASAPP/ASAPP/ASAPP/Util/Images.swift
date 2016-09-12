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
    
    class func iconX(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("icon-x", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }

    class func iconSmallX(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("icon-x-small", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }
    
    class func iconLoader(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("icon-loader", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }
    
    class func iconBack(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("icon-back", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }
    
    class func iconCheckmark(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("icon-checkmark", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }
    
    class func tileImageDash(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("bg-dash-tile", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }
    
    class func gifLoaderBar() -> UIImage? {
        var imageName: String
        if (UIScreen.mainScreen().scale > 1) {
            imageName = "gif-loader-bar@2x"
        } else {
            imageName = "gif-loader-bar"
        }
        
        if let imagePath = ASAPPBundle.pathForResource(imageName, ofType: "gif") {
            if let data = NSData(contentsOfFile: imagePath) {
                return UIImage.sd_animatedGIFWithData(data)
            }
        }
        
        return nil
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
