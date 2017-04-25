//
//  TextSizeCategory.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum TextSizeCategory: Int {
    case xSmall
    case small
    case medium
    case large /* Default */
    case xLarge
    case xxLarge
    case xxxLarge
    
    static let defaultSizeCategory = large
    
    static func current() -> TextSizeCategory {
        return from(contentSizeCategory: UIApplication.shared.preferredContentSizeCategory)
    }
    
    // Conversion from UIContentSizeCategory
    
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
    
    // Dynamic Font Sizes
    
    private static let minimumFontSize: CGFloat = 10
    
    static func dynamicFontSize(_ size: CGFloat, sizeCategory: TextSizeCategory? = nil) -> CGFloat {
        let sizeCategory = sizeCategory ?? current()
        
        return sizeCategory.dynamicFontSize(size)
    }
    
    func dynamicFontSize(_ size: CGFloat) -> CGFloat {
        let categoryDifference = rawValue - TextSizeCategory.defaultSizeCategory.rawValue
        
        let scaledSize: CGFloat
        if categoryDifference == 0 {
            // No scaling necessary
            scaledSize = size
        } else if categoryDifference > 0 {
            // Scale up
            scaledSize = size + 2.0 * CGFloat(abs(categoryDifference))
        } else {
            // Scale down
            scaledSize = size - 1.0 * CGFloat(abs(categoryDifference))
        }
        return max(TextSizeCategory.minimumFontSize, scaledSize)
    }
}
