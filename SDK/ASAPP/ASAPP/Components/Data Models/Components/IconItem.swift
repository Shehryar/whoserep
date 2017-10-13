//
//  IconItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum ComponentIcon: String {
    case alertError
    case alertWarning
    case arrowOutgoing
    case checkmarkCircle
    case checkmarkThick
    case checkmarkThin
    case clock
    case loginKey
    case power
    case trash
    case user
    case userMinus
    case xThick
    case xThin
    
    static func getImage(_ icon: ComponentIcon) -> UIImage? {
        return UIImage(named: icon.rawValue, in: ASAPP.bundle, compatibleWith: nil)
    }
}

class IconItem: Component {

    // MARK:- JSON Keys
    
    enum JSONKey: String {
        case icon
    }

    enum Icon {
        case placeholder // Empty icon
        case named(ComponentIcon)
        
        func getImage() -> UIImage? {
            switch self {
            case let .named(icon):
                return ComponentIcon.getImage(icon)
            case .placeholder:
                return nil
            }
        }
        
        static func from(_ string: String?) -> Icon? {
            guard let string = string,
                  let icon = ComponentIcon(rawValue: string) else {
                return nil
            }
            return Icon.named(icon)
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
    
    required init?(id: String? = nil,
                   name: String? = nil,
                   value: Any? = nil,
                   isChecked: Bool? = nil,
                   style: ComponentStyle,
                   styles: [String : Any]? = nil,
                   content: [String : Any]? = nil) {
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
