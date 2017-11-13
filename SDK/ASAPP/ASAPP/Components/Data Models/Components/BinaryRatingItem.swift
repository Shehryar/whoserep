//
//  BinaryRatingItem.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 11/9/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class BinaryRatingItem: Component {
    
    // MARK: - JSON Keys
    
    enum JSONKey: String {
        case positiveValue
        case negativeValue
        case positiveText
        case negativeText
        case positiveSelectedColor
        case negativeSelectedColor
        case positiveOnRight
        case circleSize
        case circleSpacing
    }
    
    // MARK: - Properties
    
    let positiveValue: String
    
    let negativeValue: String
    
    let positiveText: String?
    
    let negativeText: String?
    
    let positiveSelectedColor: UIColor
    
    let negativeSelectedColor: UIColor
    
    let isPositiveOnRight: Bool
    
    let circleSize: CGFloat
    
    let circleSpacing: CGFloat
    
    override var viewClass: UIView.Type {
        return BinaryRatingView.self
    }
    
    required init?(id: String? = nil,
                   name: String? = nil,
                   value: Any? = nil,
                   isChecked: Bool? = nil,
                   isRequired: Bool? = nil,
                   style: ComponentStyle,
                   styles: [String: Any]? = nil,
                   content: [String: Any]? = nil) {
        guard let content = content else {
            return nil
        }
        
        guard let positiveValue = content.string(for: JSONKey.positiveValue.rawValue),
              let negativeValue = content.string(for: JSONKey.negativeValue.rawValue) else {
            return nil
        }
        
        self.positiveValue = positiveValue
        self.negativeValue = negativeValue
        
        self.positiveText = content.string(for: JSONKey.positiveText.rawValue)
        self.negativeText = content.string(for: JSONKey.negativeText.rawValue)
        
        self.positiveSelectedColor = content.hexColor(for: JSONKey.positiveSelectedColor.rawValue, defaultValue: ASAPP.styles.colors.positiveSelectedBackground)
        self.negativeSelectedColor = content.hexColor(for: JSONKey.negativeSelectedColor.rawValue, defaultValue: ASAPP.styles.colors.negativeSelectedBackground)
        
        self.isPositiveOnRight = content.bool(for: JSONKey.positiveOnRight.rawValue) ?? false
        
        self.circleSize = content.float(for: JSONKey.circleSize.rawValue, defaultValue: 50)
        
        self.circleSpacing = content.float(for: JSONKey.circleSpacing.rawValue, defaultValue: 20)
        
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
