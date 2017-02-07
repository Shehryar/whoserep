//
//  ASAPPTypography.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit


/**
 UIFont Utilities
 */

extension UIFont {
    
    class func fontForTextStyle(_ textStyle: TextStyle, styles: ASAPPStyles) -> UIFont {
        let (size, weight) = textStyle.styling()
        let dynamicFontSize = TextSizeCategory.dynamicFontSize(size)
        
        return fontForWeight(weight, size: dynamicFontSize, styles: styles)
    }
    
    class func fontForWeight(_ weight: FontWeight, size: CGFloat, styles: ASAPPStyles) -> UIFont {
        let font: UIFont
        switch weight {
        case .light:
            font = UIFont(name: styles.fontNameLight, size: size) ?? UIFont.systemFont(ofSize: size)
            break
            
        case .regular:
            font = UIFont(name: styles.fontNameRegular, size: size) ?? UIFont.systemFont(ofSize: size)
            break
            
        case .bold:
            font = UIFont(name: styles.fontNameBold, size: size) ?? UIFont.boldSystemFont(ofSize: size)
            break
            
        case .black:
            font = UIFont(name: styles.fontNameBlack, size: size) ?? UIFont.boldSystemFont(ofSize: size)
            break
        }
        
        return font
    }
}

/**
 UILabel Utilities
 */

extension UILabel {
    
    func applyTextStyle(_ textStyle: TextStyle, styles: ASAPPStyles) {
        font = UIFont.fontForTextStyle(textStyle, styles: styles)
        
    }
    
    
    
}


/**
 ASAPPTextStyle
 */

enum TextStyle {
    case headline
    case body
    case detail
    case caption
    case button
    case navButton
    
    func styling() -> (/* point size */ CGFloat, FontWeight) {
        switch self {
        case .headline: 	return (20, .light)
        case .body:     	return (16, .regular)
        case .detail:       return (12, .black)
        case .caption:      return (10, .bold)
        case .button:       return (12, .black)
        case .navButton:    return (11, .black)
        }
    }
}

/**
 FontWeight
 */

enum FontWeight {
    case light
    case regular
    case bold
    case black
}

/**
 TextSizeCategory
 */

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
    
    private static let minimumFontSize: CGFloat = 11
    
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
