//
//  EphemeralEventType.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum EphemeralEventType: Int {
    case unknown = -1
    case none = 0
    case typingStatus = 1
    case `continue` = 8
    case notificationBanner = 9
    case contextNeedsRefresh = 10
    case partnerEvent = 14
    
    static func from(_ value: Any?) -> EphemeralEventType {
        guard let value = value as? Int else {
            return .unknown
        }
        return EphemeralEventType(rawValue: value) ?? .unknown
    }
}
