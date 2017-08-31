//
//  HorizontalAlignment.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum HorizontalAlignment: String {
    case left
    case center
    case right
    case fill
    
    static func from(_ string: String?) -> HorizontalAlignment? {
        guard let string = string,
            let alignment = HorizontalAlignment(rawValue: string) else {
                return nil
        }
        return alignment
    }
    
    static func from(_ string: String?, defaultValue: HorizontalAlignment) -> HorizontalAlignment {
        return from(string) ?? defaultValue
    }
}

// MARK:- Dictionary Extension

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    
    func horizontalAlignment(for key: String) -> HorizontalAlignment? {
        return HorizontalAlignment.from(self[key as! Key] as? String)
    }
}
