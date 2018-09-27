//
//  CALayerExtensions.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 11/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

extension CALayer {
    func color(at point: CGPoint) -> UIColor? {
        var pixel: [CUnsignedChar] = [0, 0, 0, 0]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        
        context.translateBy(x: -point.x, y: -point.y)
        
        render(in: context)
        
        let red = CGFloat(pixel[0]) / 255
        let green = CGFloat(pixel[1]) / 255
        let blue = CGFloat(pixel[2]) / 255
        let alpha = CGFloat(pixel[3]) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func getSublayer(named name: String) -> CALayer? {
        guard let sublayers = sublayers else {
            return nil
        }
        
        for layer in sublayers {
            if layer.name == name {
                return layer
            }
        }
        
        return nil
    }
}
