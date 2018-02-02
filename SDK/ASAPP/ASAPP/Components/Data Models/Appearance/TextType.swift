//
//  TextType.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum TextType: String {
    case navTitle
    case navButton
    case header1
    case header2
    case subheader
    case body
    case bodyBold
    case bodyItalic
    case bodyBoldItalic
    case detail1
    case detail2
    case error
    case button
    case link
    
    static func from(_ value: Any?) -> TextType? {
        guard let value = value as? String else {
            return nil
        }
        return TextType(rawValue: value)
    }
}

// MARK: - Dictionary Extension

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    
    // MARK: TextType
    
    func textType(for key: String) -> TextType? {
        guard let value = self[key as! Key] as? String else {
            return nil
        }
        return TextType.from(value)
        
    }
}
