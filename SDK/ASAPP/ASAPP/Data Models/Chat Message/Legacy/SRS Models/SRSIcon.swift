//
//  SRSIcon.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SRSIcon: SRSItem {
    
    enum IconType: String {
        case creditCard
        
        static func parse(_ value: Any?) -> IconType? {
            guard let value = value as? String else {
                return nil
            }
            return IconType(rawValue: value)
        }
    }
    
    let iconType: IconType
    
    override init?(json: Any?, metadata: EventMetadata) {
        guard let json = json as? [String : Any] else {
            return nil
        }
        guard let iconType = IconType.parse(json["icon"]) else {
            DebugLog.d(caller: SRSIcon.self, "Unknown Icon: \(json)")
            return nil
        }
        self.iconType = iconType
        super.init(json: json, metadata: metadata)
    }
}
