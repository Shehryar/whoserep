//
//  ASAPPTypography.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- TextStyle

struct TextStyle {
    
    let weight: FontWeight
    let letterSpacing: CGFloat
    var size: CGFloat {
        return TextSizeCategory.dynamicFontSize(defaultSize)
    }
    
    private let defaultSize: CGFloat
    
    // MARK: Init
    
    init(size: CGFloat, weight: FontWeight = .regular, letterSpacing: CGFloat = 0) {
        self.defaultSize = size
        self.weight = weight
        self.letterSpacing = letterSpacing
    }
}


// MARK:- Preset TextStyles

extension TextStyle {
    static let headline = TextStyle(size: 20, weight: .light, letterSpacing: 0)
    static let body = TextStyle(size: 16, weight: .regular, letterSpacing: 0)
}


// MARK:- ASAPPStyles (TextStyle)

extension ASAPPStyles {
    
    func font(for style: TextStyle) -> UIFont {
        return font(with: style.weight, size: style.size)
    }
    
    func font(with weight: FontWeight, size: CGFloat) -> UIFont {
        let font: UIFont
        switch weight {
        case .light:
            font = UIFont(name: fontNameLight, size: size) ?? UIFont.systemFont(ofSize: size)
            break
            
        case .regular:
            font = UIFont(name: fontNameRegular, size: size) ?? UIFont.systemFont(ofSize: size)
            break
            
        case .bold:
            font = UIFont(name: fontNameBold, size: size) ?? UIFont.boldSystemFont(ofSize: size)
            break
            
        case .black:
            font = UIFont(name: fontNameBlack, size: size) ?? UIFont.boldSystemFont(ofSize: size)
            break
        }
        
        return font
    }
}


// MARK:- UILabel Utilities

extension UILabel {
    
    func setAttributedText(_ text: String?, textStyle: TextStyle, color: UIColor, styles: ASAPPStyles) {
        if let text = text {
            attributedText = NSAttributedString(string: text, attributes: [
                NSFontAttributeName : styles.font(for: textStyle),
                NSForegroundColorAttributeName : color,
                NSKernAttributeName : textStyle.letterSpacing
                ])
        } else {
            attributedText = nil
        }
    }
    
    func updateFont(for textStyle: TextStyle, styles: ASAPPStyles) {
        font = styles.font(with: textStyle.weight, size: textStyle.size)
    }
}


// MARK:- FontWeight

enum FontWeight {
    case light
    case regular
    case bold
    case black
}


// MARK:- TextSizeCategory

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
