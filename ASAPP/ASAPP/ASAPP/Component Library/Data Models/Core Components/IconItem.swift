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
        case creditCard = "credit_card"
        
        func getImage() -> UIImage? {
            switch self {
            case .creditCard: return Images.asappImage(.iconCreditCardMedium)
            }
        }
    }
    
    // MARK: Properties
    
    let icon: Icon
    
    let width: CGFloat
    
    let height: CGFloat
    
    // MARK: Component Properties
    
    let type = ComponentType.icon
    
    let layout: ComponentLayout
    
    // MARK: Init
    
    init(icon: Icon,
         width: CGFloat,
         height: CGFloat,
         layout: ComponentLayout) {
        self.icon = icon
        self.width = width
        self.height = height
        self.layout = layout
        super.init()
    }
    
    // MARK: Component Parsing
    
    static func make(with content: [String : AnyObject]?,
                     layout: ComponentLayout) -> Component? {
        return nil
    }
}
