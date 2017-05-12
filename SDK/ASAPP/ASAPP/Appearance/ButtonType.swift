//
//  ButtonType.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/11/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum ButtonType: String {
    case primary = "primary"
    case secondary = "secondary"
    case textPrimary = "textPrimary"
    case textSecondary = "textSecondary"
    
    static func from(_ value: Any?) -> ButtonType? {
        guard let value = value as? String,
            let type = ButtonType(rawValue: value) else {
                return nil
        }
        return type
    }
}
