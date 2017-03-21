//
//  ComponentJSONUtil.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/20/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- NSTextAlignment

extension NSTextAlignment {
    static func from(_ stringValue: String?, defaultValue: NSTextAlignment) -> NSTextAlignment {
        guard let stringValue = stringValue else {
            return defaultValue
        }
        
        switch stringValue.lowercased() {
        case "left": return .left
        case "center": return .center
        case "right": return .right
        case "justified": return .justified
        default: return defaultValue
        }
    }
}

// MARK:- Dictionary Extension

extension Dictionary where Key: StringLiteralConvertible, Value: Any {
    
    // MARK: Floats
    
    func float(for key: String) -> CGFloat? {
        guard let value = self[key as! Key] else {
            return nil
        }
        
        if let floatValue = value as? CGFloat {
            return floatValue
        }
        if let intValue = value as? Int {
            return CGFloat(intValue)
        }
        return nil
    }
    
    func float(for key: String, defaultValue: CGFloat) -> CGFloat {
        return float(for: key) ?? defaultValue
    }
    
    // MARK: Ints
    
    func int(for key: String) -> Int? {
        guard let value = self[key as! Key] else {
            return nil
        }
        if let intValue = value as? Int {
            return intValue
        }
        if let floatValue = value as? CGFloat {
            return Int(floatValue)
        }
        return nil
    }
    
    func int(for key: String, defaultValue: Int) -> Int? {
        return int(for: key) ?? defaultValue
    }
    
    // MARK: Hex Colors
    
    func hexColor(for key: String) -> UIColor? {
        guard let colorString = self[key as! Key] as? String else {
            return nil
        }
        return UIColor.colorFromHex(hex: colorString)
    }
    
    func hexColor(for key: String, defaultValue: UIColor) -> UIColor {
        return hexColor(for: key) ?? defaultValue
    }
    
    // MARK: Content Inset
    
    /// Returns Top, Right, Bottom, Left
    func insetValues(for name: String) -> (CGFloat?, CGFloat?, CGFloat?, CGFloat?) {
        var top: CGFloat?
        var right: CGFloat?
        var bottom: CGFloat?
        var left: CGFloat?
        
        // Single Float Values - Applies to all
        if let floatValue = self.float(for: name) {
            top = floatValue
            right = floatValue
            bottom = floatValue
            left = floatValue
        }
        
//        if let valuesArray = self[name as! Key] as? [Int] {
//            if valuesArray.count == 1 {
//                top = CGFloat(valuesArray[0])
//                right = CGFloat(valuesArray[0])
//                bottom = CGFloat(valuesArray[0])
//                left = CGFloat(valuesArray[0])
//            }
//            else if valuesArray.count == 2 {
//                top = CGFloat(valuesArray[0])
//                right = CGFloat(valuesArray[1])
//                bottom = CGFloat(valuesArray[0])
//                left = CGFloat(valuesArray[1])
//            }
//            else if valuesArray.count == 3 {
//                top = CGFloat(valuesArray[0])
//                right = CGFloat(valuesArray[1])
//                bottom = CGFloat(valuesArray[2])
//            }
//            else if valuesArray.count > 3 {
//                top = CGFloat(valuesArray[0])
//                right = CGFloat(valuesArray[1])
//                bottom = CGFloat(valuesArray[2])
//                left = CGFloat(valuesArray[3])
//            }
//        }
        
        // Name-Prefixed
        if let topValue = self.float(for: "\(name)Top") {
            top = topValue
        }
        if let rightValue = self.float(for: "\(name)Right") {
            right = rightValue
        }
        if let bottomValue = self.float(for: "\(name)Bottom") {
            bottom = bottomValue
        }
        if let leftValue = self.float(for: "\(name)Left") {
            left = leftValue
        }
        
        return (top, right, bottom, left)
    }
    
    func inset(for name: String, defaultValue: UIEdgeInsets) -> UIEdgeInsets {
        let (top, right, bottom, left) = insetValues(for: name)
        
        var contentInset = defaultValue
        if let top = top {
            contentInset.top = top
        }
        if let right = right {
            contentInset.right = right
        }
        if let bottom = bottom {
            contentInset.bottom = bottom
        }
        if let left = left {
            contentInset.left = left
        }
        return contentInset
    }
}
