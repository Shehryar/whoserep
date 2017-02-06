//
//  ASAPPType.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum ASAPPTextStyle {
    case headline
    case body
    case detail
    case caption
    case button
    case navButton
    
    func size() -> Double {
        switch self {
        case .headline: return 20
        case .body: return 16
        case .detail: return 12
        case .caption: return 10
        case .button: return 12
        case .navButton: return 11
        }
    }
    
    func dynamicSize() -> Double {
        return DynamicType.size(size())
    }
}

struct DynamicType {
    private static let minimumSize: Double = 11
    
    static func size(_ size: Double, sizeCategory: TextSizeCategory? = nil) -> Double {
        let category = sizeCategory ?? TextSizeCategory.current()
        let categoryDifference = category.rawValue - TextSizeCategory.defaultSizeCategory.rawValue
        
        let scaledSize: Double
        if categoryDifference == 0 {
            // No scaling necessary
            scaledSize = size
        } else if categoryDifference > 0 {
            // Scale up
            scaledSize = size + 2.0 * Double(abs(categoryDifference))
        } else {
            // Scale down
            scaledSize = size - 1.0 * Double(abs(categoryDifference))
        }
        return max(minimumSize, scaledSize)
    }
}

enum TextSizeCategory: Int {
    case xSmall
    case small
    case medium
    case large /* Default */
    case xLarge
    case xxLarge
    case xxxLarge
    
    static let defaultSizeCategory = large
    
    static func from(contentSizeCategory: UIContentSizeCategory) -> TextSizeCategory {
        switch contentSizeCategory {
        case UIContentSizeCategory.extraSmall:
            return xSmall
            
        case UIContentSizeCategory.small:
            return small
            
        case UIContentSizeCategory.medium,
             UIContentSizeCategory.accessibilityMedium:
            return medium
            
        case UIContentSizeCategory.large,
             UIContentSizeCategory.accessibilityLarge:
            return large
            
        case UIContentSizeCategory.extraLarge,
             UIContentSizeCategory.accessibilityExtraLarge:
            return .xLarge
            
        case UIContentSizeCategory.extraExtraLarge,
             UIContentSizeCategory.accessibilityExtraExtraLarge:
            return xxLarge
            
        case UIContentSizeCategory.extraExtraExtraLarge,
             UIContentSizeCategory.accessibilityExtraExtraExtraLarge:
            return xxxLarge
            
        default: return defaultSizeCategory
        }
    }
    
    static func current() -> TextSizeCategory {
        return from(contentSizeCategory: UIApplication.shared.preferredContentSizeCategory)
    }
}
