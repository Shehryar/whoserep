//
//  EphemeralEventType.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum EphemeralEventType: Int {
    case none = 0
    case typingStatus = 1
    case eventStatus = 6
    
    static func from(_ value: Any?) -> EphemeralEventType? {
        guard let value = value as? Int else {
            return nil
        }
        return EphemeralEventType(rawValue: value)
    }
}
