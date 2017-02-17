//
//  UIImageExtensions.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

// MARK:- Tint Colors

internal extension UIImage {

    func tinted(_ color: UIColor, alpha: CGFloat = 1.0) -> UIImage {
        // Source: (source (slightly modified): https://gist.github.com/fabb/007d30ba0759de9be8a3)
        
        return modifiedImage { context, rect in
            // draw tint color
            context.setBlendMode(.normal)
            color.setFill()
            context.fill(rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.setAlpha(alpha)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    private func modifiedImage(_ draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

// MARK:- Color Image

internal extension UIImage {
    
    class func imageWithColor(_ color: UIColor) -> UIImage? {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
