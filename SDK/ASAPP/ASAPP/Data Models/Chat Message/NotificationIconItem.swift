//
//  NotificationIconItem.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 2/12/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

enum NotificationIcon: String {
    case alertError
    case alertErrorOutline
    case bell
    case clock
    
    static func getImage(_ icon: NotificationIcon) -> UIImage? {
        let apiNameToFilename: [NotificationIcon: String] = [
            .alertError: "alertFilled",
            .alertErrorOutline: "alertOutline",
            .bell: "bellFilled",
            .clock: "clockFilled"
        ]
        
        guard let name = apiNameToFilename[icon] else {
            return nil
        }
        
        return UIImage(named: name, in: ASAPP.bundle, compatibleWith: nil)
    }
}

class NotificationIconItem {
    enum JSONKey: String {
        case name
    }
    
    enum Icon {
        case named(NotificationIcon)
        
        func getImage() -> UIImage? {
            switch self {
            case let .named(icon):
                return NotificationIcon.getImage(icon)
            }
        }
        
        static func from(_ string: String?) -> Icon? {
            guard let string = string,
                let icon = NotificationIcon(rawValue: string) else {
                    return nil
            }
            return Icon.named(icon)
        }
    }
    
    let icon: Icon
    
    var size: CGSize {
        return CGSize(width: 16, height: 16)
    }
    
    // MARK: Init
    
    required init?(with dict: [String: Any]) {
        guard let icon = Icon.from(dict.string(for: JSONKey.name.rawValue)) else {
            if !dict.keys.isEmpty {
                DebugLog.w(caller: NotificationIconItem.self, "No icon name found in dictionary: \(String(describing: dict))")
            }
            return nil
        }
        
        self.icon = icon
    }
}
