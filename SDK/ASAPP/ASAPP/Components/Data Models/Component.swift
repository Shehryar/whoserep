//
//  Component.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- Component

protocol Component {
    var type: ComponentType { get }
    var id: String? { get }
    var layout: ComponentLayout { get }
    
    static func make(with content: Any?, // Typically expects [String : Any]
                     id: String?,
                     layout: ComponentLayout) -> Component?
}


// MARK:- JSON Utilites

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
}
