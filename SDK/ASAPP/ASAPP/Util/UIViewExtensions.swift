//
//  UIViewExtensions.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 3/27/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

extension UIView {
    static var minimumTargetLength: CGFloat {
        return 44
    }
    
    @discardableResult
    func setLinearGradient(degrees: Float = 0, colors: UIColor...) -> CALayer {
        let gradient = createLinearGradient(degrees: degrees, colors: colors)
        layer.insertSublayer(gradient, at: 0)
        return gradient
    }
    
    @discardableResult
    func setLinearGradient(degrees: Float = 0, colors: [UIColor]) -> CALayer {
        let gradient = createLinearGradient(degrees: degrees, colors: colors)
        layer.insertSublayer(gradient, at: 0)
        return gradient
    }
    
    func createLinearGradient(degrees: Float = 0, colors: UIColor...) -> CALayer {
        return createLinearGradient(degrees: degrees, colors: colors)
    }
    
    func createLinearGradient(degrees: Float = 0, colors: [UIColor]) -> CALayer {
        let gradient = CAGradientLayer()
        let lengthOfLongestSide = max(bounds.width, bounds.height)
        gradient.frame = CGRect(x: 0, y: 0, width: lengthOfLongestSide, height: lengthOfLongestSide)
        gradient.colors = colors.map { $0.cgColor }
        
        let α = degrees / 360
        
        func convert(_ alpha: Float, _ offset: Float) -> CGFloat {
            return CGFloat(powf(sinf(2 * .pi * (alpha + offset) / 2), 2))
        }
        
        let startX = convert(α, 0.75)
        let startY = convert(α, 0)
        let endX = convert(α, 0.25)
        let endY = convert(α, 0.5)
        
        gradient.startPoint = CGPoint(x: startX, y: startY)
        gradient.endPoint = CGPoint(x: endX, y: endY)
        
        return gradient
    }
}
