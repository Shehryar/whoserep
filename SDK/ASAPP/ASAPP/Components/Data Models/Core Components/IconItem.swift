//
//  IconItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class IconItem: NSObject, Component {

    enum Icon: String {
        case placeholder = "placeholder" // Empty icon
        case creditCard = "credit_card"
        
        func getImage() -> UIImage? {
            switch self {
            case .creditCard: return Images.asappImage(.iconCreditCardMedium)
            case .placeholder: return nil
            }
        }
    }
    
    // MARK: Defaults
    
    static let defaultWidth: CGFloat = 24
    
    static let defaultHeight: CGFloat = 24
    
    // MARK: Properties
    
    let icon: Icon
    
    let tintColor: UIColor?
    
    let width: CGFloat
    
    let height: CGFloat
    
    // MARK: Component Properties
    
    let type = ComponentType.icon
    
    let id: String?
    
    let layout: ComponentLayout
    
    // MARK: Init
    
    init(icon: Icon,
         tintColor: UIColor?,
         width: CGFloat?,
         height: CGFloat?,
         id: String?,
         layout: ComponentLayout) {
        self.icon = icon
        self.tintColor = tintColor
        self.width = width ?? IconItem.defaultWidth
        self.height = height ?? IconItem.defaultHeight
        self.id = id
        self.layout = layout
        super.init()
    }
    
    // MARK: Component Parsing
    
    static func make(with content: Any?,
                     id: String?,
                     layout: ComponentLayout) -> Component? {
        guard let content = content as? [String : Any] else {
            return nil
        }
        guard let iconName = content["icon"] as? String,
            let icon = Icon(rawValue: iconName) else {
                DebugLog.w(caller: self, "No icon found in content: \(content)")
                return nil
        }
        
        let color = content.hexColor(for: "tint_color")
        let width = content.float(for: "width")
        let height = content.float(for: "height")
        
        return IconItem(icon: icon,
                        tintColor: color,
                        width: width,
                        height: height,
                        id: id,
                        layout: layout)
    }
}
