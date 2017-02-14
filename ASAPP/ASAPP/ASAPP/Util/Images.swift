//
//  Images.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class Images: NSObject {

    class func paperclipIcon() -> UIImage? {
        return imageWithName("temp-icon-paperclip")
    }
    
    class func iconX() -> UIImage? {
        return imageWithName("icon-x")
    }

    class func iconSmallX() -> UIImage? {
        return imageWithName("icon-x-small")
    }
    
    class func iconLoader() -> UIImage? {
        return imageWithName("icon-loader")
    }
    
    class func iconExitLink() -> UIImage? {
        return imageWithName("icon-exit-link")
    }
    
    class func iconBack() -> UIImage? {
        return imageWithName("icon-back")
    }
    
    class func iconCheckmark() -> UIImage? {
        return imageWithName("icon-checkmark")
    }
    
    class func buttonAskBG() -> UIImage? {
        return imageWithName("button-bg-ask")
    }
    
    class func buttonRespondBG() -> UIImage? {
        return imageWithName("button-bg-respond")
    }
    class func buttonCloseBG() -> UIImage? {
        return imageWithName("button-bg-close")
    }

    class func tileImageDash() -> UIImage? {
        return imageWithName("bg-dash-tile")
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
    
    class func imageWithName(_ name: String) -> UIImage? {
        let image = UIImage(named: name, in: ASAPPBundle, compatibleWith: nil)
        return image
    }
}
