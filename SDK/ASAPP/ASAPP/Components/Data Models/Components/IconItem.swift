//
//  IconItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class IconItem: Component {

    // MARK:- JSON Keys
    
    enum JSONKey: String {
        case icon = "icon"
    }

    enum Icon: String {
        case placeholder = "placeholder" // Empty icon
        
        case alertError = "alertError"
        case alertWarning = "alertWarning"
        case arrowOutgoing = "arrowOutgoing"
        case checkmarkCircle = "checkmarkCircle"
        case checkmarkThick = "checkmarkThick"
        case checkmarkThin = "checkmarkThin"
        case loginKey = "loginKey"
        case power = "power"
        case trash = "trash"
        case user = "user"
        case userMinus = "userMinus"
        case xThick = "xThick"
        case xThin = "xThin"
        
        
        static let iconToASAPPIconMap: [Icon : ASAPPIcon] = [
            .alertError: .alertError,
            .alertWarning: .alertWarning,
            .arrowOutgoing: .arrowOutgoing,
            .checkmarkCircle: .checkmarkCircle,
            .checkmarkThick: .checkmarkThick,
            .checkmarkThin: .checkmarkThin,
            .loginKey: .loginKey,
            .power: .power,
            .trash: .trash,
            .user: .user,
            .userMinus: .userMinus,
            .xThick: .xThick,
            .xThin: .xThin
        ]
        
        func getImage() -> UIImage? {
            if let icon = Icon.iconToASAPPIconMap[self] {
                return UIImage.asappIcon(icon)
            }
            if self != .placeholder {
                DebugLog.w(caller: self, "Unable to locate asapp icon for: \(self)")
            }
            return nil
        }
        
        static func from(_ string: String?) -> Icon? {
            guard let string = string, let icon = Icon(rawValue: string) else {
                return nil
            }
            return icon
        }
    }
    
    // MARK:- Defaults
    
    static let defaultWidth: CGFloat = 16
    
    static let defaultHeight: CGFloat = 16
    
    // MARK:- Component Properties
    
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
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   isChecked: Bool?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        guard let icon = Icon.from(content?.string(for: JSONKey.icon.rawValue)) else {
            DebugLog.w(caller: IconItem.self, "No icon found in content: \(String(describing: content))")
            return nil
        }
        self.icon = icon
        
        
        super.init(id: id,
                   name: name,
                   value: value,
                   isChecked: isChecked,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
