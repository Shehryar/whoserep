//
//  VerticalAlignment.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum VerticalAlignment: String {
    case top = "top"
    case middle = "middle"
    case bottom = "bottom"
    case fill = "fill"
    
    static func from(_ string: String?) -> VerticalAlignment? {
        guard let string = string,
            let alignment = VerticalAlignment(rawValue: string) else {
                return nil
        }
        return alignment
    }
    
    static func from(_ string: String?, defaultValue: VerticalAlignment) -> VerticalAlignment {
        return from(string) ?? defaultValue
    }
}

// MARK:- Dictionary Extension

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    
    func verticalAlignment(for key: String) -> VerticalAlignment? {
        return VerticalAlignment.from(self[key as! Key] as? String)
    }
}
