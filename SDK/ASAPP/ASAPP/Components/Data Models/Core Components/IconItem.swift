//
//  IconItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class IconItem: NSObject, Component {

    enum JSONKey: String {
        case icon = "icon"
    }

    enum Icon: String {
        case placeholder = "placeholder" // Empty icon
        
        // Maintain alphabetical order
        case arrowLeft = "arrowLeft"
        case arrowRight = "arrowRight"
        case back = "back"
        case checkmark = "checkmark"
        case circleCheckmark = "circleCheckmark"
        case creditCard = "creditCard"
        case creditCardMedium = "creditCardMedium"
        case errorAlert = "errorAlert"
        case errorAlertFilled = "errorAlertFilled"
        case exitLink = "exitLink"
        case hideKeyboard = "hideKeyboard"
        case paperclip = "paperclip"
        case smallX = "xSmall"
        case star = "star"
        case starFilled = "starFilled"
        case user = "user"
        case x = "x"
        
        func getImage() -> UIImage? {
            switch self {
            case .placeholder: return nil
                
            case .arrowLeft: return Images.asappImage(.iconArrowLeft)
            case .arrowRight: return Images.asappImage(.iconArrowRight)
            case .back: return Images.asappImage(.iconBack)
            case .checkmark: return Images.asappImage(.iconCheckmark)
            case .circleCheckmark: return Images.asappImage(.iconCircleCheckmark)
            case .creditCard: return Images.asappImage(.iconCreditCard)
            case .creditCardMedium: return Images.asappImage(.iconCreditCardMedium)
            case .errorAlert: return Images.asappImage(.iconErrorAlert)
            case .errorAlertFilled: return Images.asappImage(.iconErrorAlertFilled)
            case .exitLink: return Images.asappImage(.iconExitLink)
            case .hideKeyboard: return Images.asappImage(.iconHideKeyboard)
            case .paperclip: return Images.asappImage(.iconPaperclip)
            case .smallX: return Images.asappImage(.iconSmallX)
            case .star: return Images.asappImage(.iconStar)
            case .starFilled: return Images.asappImage(.iconStarFilled)
            case .user: return Images.asappImage(.iconUser)
            case .x: return Images.asappImage(.iconX)
            }
        }
    }
    
    // MARK: Defaults
    
    static let defaultWidth: CGFloat = 16
    
    static let defaultHeight: CGFloat = 16
    
    // MARK: Properties
    
    let icon: Icon
    
    // MARK: Component Properties
        
    let id: String?
    
    let style: ComponentStyle
    
    // MARK: Init
    
    init(icon: Icon,
         id: String?,
         style: ComponentStyle) {
        self.icon = icon
        self.id = id
        self.style = style
        super.init()
    }
    
    // MARK: Component Parsing
    
    static func make(with content: Any?,
                     id: String?,
                     style: ComponentStyle) -> Component? {
        guard let content = content as? [String : Any] else {
            return nil
        }
        guard let iconName = content[JSONKey.icon.rawValue] as? String,
            let icon = Icon(rawValue: iconName) else {
                DebugLog.w(caller: self, "No icon found in content: \(content)")
                return nil
        }

        return IconItem(icon: icon,
                        id: id,
                        style: style)
    }
}
