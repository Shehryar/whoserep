//
//  UIImageExtensions.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

// MARK: - Tint Colors

internal extension UIImage {

    func tinted(_ color: UIColor, alpha: CGFloat = 1.0) -> UIImage {
        // Source (slightly modified): https://gist.github.com/fabb/007d30ba0759de9be8a3
        
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
    
    func withAlpha(_ alpha: CGFloat) -> UIImage {
        return modifiedImage { context, rect in
            context.setAlpha(alpha)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    private func modifiedImage(_ draw: (CGContext, CGRect) -> Void) -> UIImage {
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

// MARK: - Color Image

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
    
    func colored(with color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: rect)
        color.setFill()
        UIRectFillUsingBlendMode(rect, .color)
        draw(in: rect, blendMode: .destinationIn, alpha: 1)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - Blurred Image

internal extension UIImage {
    func blurred(radius: CGFloat = 4) -> UIImage? {
        let context = CIContext()
        guard let inputImage = CIImage(image: self),
              let clampFilter = CIFilter(name: "CIAffineClamp"),
              let blurFilter = CIFilter(name: "CIGaussianBlur") else {
            return nil
        }
        
        clampFilter.setDefaults()
        clampFilter.setValue(inputImage, forKey: kCIInputImageKey)
        
        blurFilter.setDefaults()
        blurFilter.setValue(clampFilter.outputImage, forKey: kCIInputImageKey)
        blurFilter.setValue(radius, forKey: kCIInputRadiusKey)
        
        guard let blurredImage = blurFilter.value(forKey: kCIOutputImageKey) as? CIImage,
              let cgImage = context.createCGImage(blurredImage, from: inputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
}

// MARK: - Resizing

internal extension UIImage {
    
    private static let maxBytes = 3 * 1024 * 1024
    
    func resizeImage(scale: CGFloat) -> UIImage {
        let newSize = size.applying(CGAffineTransform(scaleX: scale, y: scale))
        let hasAlpha = false
        UIGraphicsBeginImageContextWithOptions(newSize, !hasAlpha, 1.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        guard let scaledImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    func compressImage() -> Data? {
        guard let jpeg = jpegData(compressionQuality: 0.7) else { return nil }
        return jpeg
    }
    
    static func downsampleImage(image: UIImage) -> (Data, UIImage)? {
        
        var resizedImage = image.resizeImage(scale: 0.8)
        guard var compressedImageData = resizedImage.compressImage() else { return nil }
        
        while compressedImageData.count > UIImage.maxBytes {
            (compressedImageData, resizedImage) = downsampleImage(image: resizedImage)!
        }
        return (compressedImageData, resizedImage)
    }
}
