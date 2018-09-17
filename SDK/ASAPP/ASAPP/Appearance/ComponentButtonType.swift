//
//  ComponentButtonType.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/11/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

enum ComponentButtonType: String {
    case primary
    case secondary
    case textPrimary
    
    static func from(_ value: Any?) -> ComponentButtonType? {
        guard let value = value as? String,
            let type = ComponentButtonType(rawValue: value) else {
                return nil
        }
        return type
    }
}
