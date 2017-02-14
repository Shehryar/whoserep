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
    
    class func iconExitLink(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("icon-exit-link", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }
    
    class func iconBack(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("icon-back", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }
    
    class func iconCheckmark(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("icon-checkmark", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }
    
    class func buttonAskBG(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("button-bg-ask", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }
    
    class func buttonRespondBG(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("button-bg-respond", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }
    class func buttonCloseBG(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("button-bg-close", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }

    class func tileImageDash(withTintColor tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        return imageWithName("bg-dash-tile", tintColor: tintColor, fillColor: fillColor, alpha: alpha)
    }
    
    class func gifLoaderBar() -> UIImage? {
        var imageName: String
        if (UIScreen.main.scale > 1) {
            imageName = "gif-loader-bar@2x"
        } else {
            imageName = "gif-loader-bar"
        }
        
        if let imagePath = ASAPPBundle.path(forResource: imageName, ofType: "gif") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: imagePath)) {
                return UIImage.sd_animatedGIF(with: data)
            }
        }
        
        return nil
    }
    
    class func imageEquipmentReturnMap() -> UIImage? {
        return imageWithName("map-equipment")
    }
    
    class func imageDeviceTrackingMap() -> UIImage? {
        return imageWithName("map-device")
    }
    
    class func imageTechLocationMap() -> UIImage? {
        return imageWithName("map-tech")
    }
    
    // MARK:- Private Helper Methods
    
    class func imageWithName(_ name: String, tintColor: UIColor? = nil, fillColor: UIColor? = nil, alpha: CGFloat = 1) -> UIImage? {
        let image = imageWithName(name)
        let modImage = modifiedImage(image, tintColor: tintColor, fillColor: fillColor, alpha: alpha)
        return modImage
    }
    
    fileprivate class func imageWithName(_ name: String) -> UIImage? {
        let image = UIImage(named: name, in: ASAPPBundle, compatibleWith: nil)
        
        return image
    }
    
    fileprivate class func modifiedImage(_ image: UIImage?, tintColor: UIColor? = nil, fillColor: UIColor?  = nil, alpha: CGFloat = 1) -> UIImage? {
        var modifiedImage: UIImage?
        if let tintColor = tintColor {
            modifiedImage = image?.tint(tintColor, alpha: alpha)
        } else if let fillColor = fillColor {
            modifiedImage = image?.fillAlpha(fillColor, alpha: alpha)
        }
        return modifiedImage ?? image
    }
}
