//
//  ColorExtensions.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/10/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

// MARK: - Hue, Saturation, Brightness

struct HSBa {
    var hue: CGFloat = 0
    var saturation: CGFloat = 0
    var brightness: CGFloat = 0
    var alpha: CGFloat = 1
    
    init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.alpha = alpha
    }
    
    init?(withColor color: UIColor?) {
        guard let color = color else {
            return nil
        }
        
        var hue: CGFloat = 0,
        saturation: CGFloat = 0,
        brightness: CGFloat = 0,
        alpha: CGFloat = 0
        guard color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return nil
        }
        
        self.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}

// MARK: - Brightness

internal extension UIColor {
    func isWhite() -> Bool {
        return isEqual(UIColor.white) || isEqual(UIColor(red: 1, green: 1, blue: 1, alpha: 1))
    }
    
    func isBright() -> Bool {
        if isWhite() {
            return true
        }
        
        guard let hsba = HSBa(withColor: self) else {
            return false
        }
        
        let brightnessCutoff: CGFloat = 0.4,
        saturationCutoff: CGFloat = 0.4
        
        let generalBrightnessCurve: CGFloat = (1 - brightnessCutoff) / (saturationCutoff * saturationCutoff)
        let colorEdgeOfDarkness = brightnessCutoff + generalBrightnessCurve * (hsba.saturation * hsba.saturation)
        
        return hsba.brightness > colorEdgeOfDarkness
    }
    
    func isDark() -> Bool {
        return !isBright()
    }
    
    /// Adjustment should be 0<=>1
    func colorWithRelativeBrightness(_ brightnessAdjustment: CGFloat) -> UIColor? {
        if let hsba = HSBa(withColor: self) {
            let adjustedBrightness = max(0, min(1, hsba.brightness + brightnessAdjustment))
            return UIColor(hue: hsba.hue,
                           saturation: hsba.saturation,
                           brightness: adjustedBrightness,
                           alpha: hsba.alpha)
        }
        
        var white: CGFloat = 0,
        alpha: CGFloat = 0
        if getWhite(&white, alpha: &alpha) {
            let adjustedWhite = max(0, min(1, white + brightnessAdjustment))
            return UIColor(white: adjustedWhite, alpha: alpha)
        }
        
        return nil
    }
}

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

// MARK: - Highlight Colors

internal extension UIColor {
    func highlightColor() -> UIColor? {
        if isBright() {
            return colorWithRelativeBrightness(-0.14)
        } else {
            return colorWithRelativeBrightness(0.14)
        }
    }
}

// MARK: - Hex Colors

internal extension UIColor {
    
    convenience init?(hexString: String?) {
        guard let hexString = hexString else { return nil }
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    class func colorFromHex(hex: String?) -> UIColor? {
        guard let hex = hex else { return nil }
        
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count != 6 {
            return nil
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb: Int = (Int)(red * 255)   << 16
                     | (Int)(green * 255) << 8
                     | (Int)(blue * 255)  << 0
        return String(format: "%06x", rgb)
    }
}
