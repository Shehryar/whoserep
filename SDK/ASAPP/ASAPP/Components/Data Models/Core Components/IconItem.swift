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
        case placeholder = "placeholder"
        case creditCard = "credit_card"
        
        func getImage() -> UIImage? {
            switch self {
            case .creditCard: return Images.asappImage(.iconCreditCardMedium)
            case .placeholder: return nil
            }
        }
    }
    
    // MARK: Properties
    
    let icon: Icon
    
    let width: CGFloat
    
    let height: CGFloat
    
    // MARK: Component Properties
    
    let type = ComponentType.icon
    
    let id: String?
    
    let layout: ComponentLayout
    
    // MARK: Init
    
    init(icon: Icon,
         width: CGFloat,
         height: CGFloat,
         id: String?,
         layout: ComponentLayout) {
        self.icon = icon
        self.width = width
        self.height = height
        self.id = id
        self.layout = layout
        super.init()
    }
    
    // MARK: Component Parsing
    
    static func make(with content: Any?,
                     id: String?,
                     layout: ComponentLayout) -> Component? {
        return nil
    }
}
