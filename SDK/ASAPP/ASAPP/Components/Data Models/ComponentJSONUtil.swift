//
//  ComponentJSONUtil.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/20/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- Dictionary Extension

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    
    // MARK: Boolean
    
    func bool(for key: String) -> Bool? {
        return self[key as! Key] as? Bool
    }
    
    // MARK: Strings
    
    func string(for key: String) -> String? {
        guard let value = self[key as! Key] else {
            return nil
        }
    
        // Parse numbers into strings?
        
        if let stringValue = value as? String {
            return stringValue
        }
        
        return nil
    }
    
    func strings(for key: String) -> [String]? {
        return self[key as! Key] as? [String]
    }
    
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
        
        
        // String Value
        if let stringValue = (self[name as! Key] as? String)?.trimmingCharacters(in: .whitespaces) {
            let valueStrings = stringValue.components(separatedBy: " ")
            var valuesArray = [Int]()
            for valueString in valueStrings {
                if let intValue = Int(valueString) {
                    valuesArray.append(intValue)
                } else {
                    valuesArray.append(0)
                }
            }
            
            if valuesArray.count == 1 {
                top = CGFloat(valuesArray[0])
                right = CGFloat(valuesArray[0])
                bottom = CGFloat(valuesArray[0])
                left = CGFloat(valuesArray[0])
            }
            else if valuesArray.count == 2 {
                top = CGFloat(valuesArray[0])
                right = CGFloat(valuesArray[1])
                bottom = CGFloat(valuesArray[0])
                left = CGFloat(valuesArray[1])
            }
            else if valuesArray.count == 3 {
                top = CGFloat(valuesArray[0])
                right = CGFloat(valuesArray[1])
                bottom = CGFloat(valuesArray[2])
            }
            else if valuesArray.count > 3 {
                top = CGFloat(valuesArray[0])
                right = CGFloat(valuesArray[1])
                bottom = CGFloat(valuesArray[2])
                left = CGFloat(valuesArray[3])
            } 
        }
        // Single Float Values - Applies to all
        else if let floatValue = self.float(for: name) {
            top = floatValue
            right = floatValue
            bottom = floatValue
            left = floatValue
        }
        
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
    
    // MARK: Horizontal Alignment
    
    func horizontalAlignment(for key: String) -> HorizontalAlignment? {
        return HorizontalAlignment.from(self[key as! Key] as? String)
    }
    
    func verticalAlignment(for key: String) -> VerticalAlignment? {
        return VerticalAlignment.from(self[key as! Key] as? String)
    }
    
    func textAlignment(for key: String) -> NSTextAlignment? {
        return NSTextAlignment.from(self[key as! Key] as? String)
    }
    
    func fontWeight(for key: String) -> FontWeight? {
        return FontWeight.from(self[key as! Key] as? String)
    }
}

// MARK: Enums

enum CapitalizationType: String {
    case characters = "characters"
    case none = "none" // Default
    case sentences = "sentences"
    case words = "words"
    
    func type() -> UITextAutocapitalizationType {
        switch self {
        case .characters: return .allCharacters
        case .none: return .none
        case .sentences: return .sentences
        case .words: return .words
        }
    }
    
    static func from(_ string: Any?) -> CapitalizationType? {
        guard let string = string as? String,
            let type = CapitalizationType(rawValue: string) else {
                return nil
        }
        return type
    }
}


