//
//  IconItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum ComponentIcon: String {
    case hourglass
    case mailEmpty
    case mailPaper
    case moneyCardCancel
    case moneyCardConfirm
    case moneyCardRecurring
    case moneyWallet
    case navCheck
    case navClose
    case navExitFill
    case networkAlert
    case networkSignal
    case notificationAlert
    case ratingStar
    case ratingThumbsUpFill
    case ratingThumbsDownFill
    case securityLock
    case soundOffFill
    case soundOnFill
    case techLaptop
    case techRouterOn
    case timeCalendar
    case timeClock
    case timeClockArrow
    case userCancel
    case userConfirm
    case userConnecting
    case userSync
    case userUser
    case userUserStanding
    
    enum Alias: String {
        case alertError
        case alertWarning
        case checkmarkThick
        case checkmarkThin
        case clock
        case userMinus
        case user
        case xthick
        case xthin
    }
    
    static func getImage(_ icon: ComponentIcon) -> UIImage? {
        return UIImage(named: icon.rawValue.camelToSnakeCased(), in: ASAPP.bundle, compatibleWith: nil)
    }
    
    private static func resolveAlias(_ alias: Alias) -> ComponentIcon {
        switch alias {
        case .alertError: return .notificationAlert
        case .alertWarning: return .notificationAlert
        case .checkmarkThick: return .navCheck
        case .checkmarkThin: return .navCheck
        case .clock: return .timeClock
        case .user: return .userUser
        case .userMinus: return .userCancel
        case .xthick: return .navClose
        case .xthin: return .navClose
        }
    }
    
    static func getImage(fka alias: Alias) -> UIImage? {
        return getImage(resolveAlias(alias))
    }
}

class IconItem: Component {

    // MARK: - JSON Keys
    
    enum JSONKey: String {
        case icon
    }

    enum Icon {
        case placeholder // Empty icon
        case named(ComponentIcon)
        case fka(ComponentIcon.Alias)
        
        func getImage() -> UIImage? {
            switch self {
            case let .named(icon):
                return ComponentIcon.getImage(icon)
            case let .fka(alias):
                return ComponentIcon.getImage(fka: alias)
            case .placeholder:
                return nil
            }
        }
        
        static func from(_ string: String?) -> Icon? {
            guard let string = string else {
                return nil
            }
            
            if let alias = ComponentIcon.Alias(rawValue: string) {
                return Icon.fka(alias)
            }
            
            if let icon = ComponentIcon(rawValue: string.snakeToCamelCased()) {
                return Icon.named(icon)
            }
            
            return nil
        }
    }
    
    // MARK: - Defaults
    
    static let defaultWidth: CGFloat = 16
    
    static let defaultHeight: CGFloat = 16
    
    // MARK: - Component Properties
    
    override var viewClass: UIView.Type {
        return IconView.self
    }
    
    let icon: Icon
    
    var size: CGSize {
        if style.width > 0 && style.height > 0 {
            return CGSize(width: style.width, height: style.height)
        }
        return CGSize(width: IconItem.defaultWidth, height: IconItem.defaultHeight)
    }
    
    // MARK: Init
    
    required init?(id: String? = nil,
                   name: String? = nil,
                   value: Any? = nil,
                   isChecked: Bool? = nil,
                   isRequired: Bool? = nil,
                   style: ComponentStyle,
                   styles: [String: Any]? = nil,
                   content: [String: Any]? = nil) {
        guard let icon = Icon.from(content?.string(for: JSONKey.icon.rawValue)) else {
            DebugLog.w(caller: IconItem.self, "No icon found in content: \(String(describing: content))")
            return nil
        }
        self.icon = icon
        
        super.init(id: id,
                   name: name,
                   value: value,
                   isChecked: isChecked,
                   isRequired: isRequired,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
