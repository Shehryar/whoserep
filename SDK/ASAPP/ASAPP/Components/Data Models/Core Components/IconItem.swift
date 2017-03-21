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
        case tintColor = "tint_color"
        case width = "width"
        case height = "height"
    }

    enum Icon: String {
        case placeholder = "placeholder" // Empty icon
        
        // Maintain alphabetical order
        case arrowLeft = "arrow_left"
        case arrowRight = "arrow_right"
        case back = "back"
        case checkmark = "checkmark"
        case circleCheckmark = "circle_checkmark"
        case creditCard = "credit_card"
        case creditCardMedium = "credit_card_medium"
        case errorAlert = "error_alert"
        case errorAlertFilled = "error_alert_filled"
        case exitLink = "exit_link"
        case hideKeyboard = "hide_keyboard"
        case paperclip = "paperclip"
        case smallX = "x_small"
        case star = "star"
        case starFilled = "star_filled"
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
    
    let tintColor: UIColor?
    
    let width: CGFloat
    
    let height: CGFloat
    
    // MARK: Component Properties
    
    let type = ComponentType.icon
    
    let id: String?
    
    let style: ComponentStyle
    
    // MARK: Init
    
    init(icon: Icon,
         tintColor: UIColor?,
         width: CGFloat?,
         height: CGFloat?,
         id: String?,
         style: ComponentStyle) {
        self.icon = icon
        self.tintColor = tintColor
        self.width = width ?? IconItem.defaultWidth
        self.height = height ?? IconItem.defaultHeight
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
        
        let color = content.hexColor(for: JSONKey.tintColor.rawValue)
        let width = content.float(for: JSONKey.width.rawValue)
        let height = content.float(for: JSONKey.height.rawValue)
        
        return IconItem(icon: icon,
                        tintColor: color,
                        width: width,
                        height: height,
                        id: id,
                        style: style)
    }
}
