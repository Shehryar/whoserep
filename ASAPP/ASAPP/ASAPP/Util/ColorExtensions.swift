//
//  ColorExtensions.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/10/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

// MARK:- Hue, Saturation, Brightness

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
        
        var h: CGFloat = 0,
            s: CGFloat = 0,
            b: CGFloat = 0,
            a: CGFloat = 0
        guard color.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            return nil
        }
        
        self.init(hue: h, saturation: s, brightness: b, alpha: a)
    }
}

// MARK:- Brightness

extension UIColor {
    func isWhite() -> Bool {
        return isEqual(UIColor.whiteColor()) || isEqual(UIColor(red: 1, green: 1, blue: 1, alpha: 1))
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
    func colorWithRelativeBrightness(brightnessAdjustment: CGFloat) -> UIColor? {
        if let hsba = HSBa(withColor: self) {
            let adjustedBrightness = max(0, min(1, hsba.brightness + brightnessAdjustment))
            return UIColor(hue: hsba.hue,
                           saturation: hsba.saturation,
                           brightness: hsba.brightness,
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
