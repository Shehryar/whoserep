//
//  UIColorExtensions.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 12/3/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Contrast

// See https://www.w3.org/TR/WCAG20-TECHS/G18.html#G18-tests
extension UIColor {
    private func calcComp(_ x: Double) -> Double {
        return x <= 0.03928
            ? x / 12.92
            : pow((x + 0.055) / 1.055, 2.4)
    }
    
    private func getLuminance() -> Double {
        let ciColor = CIColor(color: self)
        return 0.2126 * calcComp(Double(ciColor.red))
            + 0.7152 * calcComp(Double(ciColor.green))
            + 0.0722 * calcComp(Double(ciColor.blue))
    }
    
    func contrastRatio(with other: UIColor) -> Double {
        let lum1 = self.getLuminance()
        let lum2 = other.getLuminance()
        let lighter = max(lum1, lum2)
        let darker = min(lum1, lum2)
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    func chooseHighestContrast(of candidates: [UIColor]) -> UIColor {
        var highestRatio: Double = 0
        var color: UIColor?
        
        for candidate in candidates {
            let ratio = self.contrastRatio(with: candidate)
            if ratio > highestRatio {
                highestRatio = ratio
                color = candidate
            }
        }
        
        return color ?? self
    }
    
    /*
     Returns the first color with an acceptable contrast ratio.
     If no colors are acceptable, then the color with the highest ratio
     is returned.
     */
    func chooseFirstAcceptableColor(of candidates: [UIColor], largeText: Bool = false) -> UIColor {
        let minimumContrastRatio = largeText ? 3.0 : 4.5
        var highestRatio: Double = 0
        var color: UIColor?
        
        for candidate in candidates {
            let ratio = self.contrastRatio(with: candidate)
            if ratio > minimumContrastRatio {
                return candidate
            } else if ratio > highestRatio {
                highestRatio = ratio
                color = candidate
            }
        }
        
        return color ?? self
    }
}
