//
//  TextStyle.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- FontWeight

enum FontWeight: String {
    case light = "light"
    case regular = "regular"
    case bold = "bold"
    case black = "black"
    
    static func from(_ string: String?, defaultValue: FontWeight = regular) -> FontWeight {
        guard let string = string,
            let style = FontWeight(rawValue: string) else {
                return defaultValue
        }
        return style
    }
}

// MARK:- TextStyle

struct TextStyle {
    
    let weight: FontWeight
    let letterSpacing: CGFloat
    var size: CGFloat {
        return TextSizeCategory.dynamicFontSize(defaultSize)
    }
    
    private let defaultSize: CGFloat
    
    // MARK: Init
    
    init(size: CGFloat, weight: FontWeight, letterSpacing: CGFloat = 0) {
        self.defaultSize = size
        self.weight = weight
        self.letterSpacing = letterSpacing
    }
}

// MARK:- Preset TextStyles

extension TextStyle {

    // Predictive
    
    static let predictiveGreeting = TextStyle(size: 24, weight: .regular, letterSpacing: 0.7)
    static let predictiveMessage = TextStyle(size: 14, weight: .bold, letterSpacing: 1.2)
    static let predictiveDetailLabel = TextStyle(size: 12, weight: .bold, letterSpacing: 1)
    static let predictiveButton = TextStyle(size: 15, weight: .regular)
    
    // Chat Input View
    
    static let chatInputViewText = TextStyle(size: 15, weight: .regular)
    static let chatInputViewButton = TextStyle(size: 12, weight: .black)
    
    // Chat Empty View
    
    static let emptyChatTitle = TextStyle(size: 24, weight: .bold)
    static let emptyChatMessage = TextStyle(size: 15, weight: .regular)
    
    // Chat Messages View
    
    static let chatStatusUpdate = TextStyle(size: 12, weight: .bold)
    static let chatTimestamp = TextStyle(size: 10, weight: .bold, letterSpacing: 0.8)
    static let chatMessageText = TextStyle(size: 15, weight: .regular)

    // SRS Views
    
    static let srsLabel = TextStyle(size: 12, weight: .bold, letterSpacing: 1)
    static let srsInfoLabelV = TextStyle(size: 12, weight: .bold, letterSpacing: 1.2)
    static let srsInfoValueV = TextStyle(size: 24, weight: .bold, letterSpacing: 1.2)
    static let srsInfoLabelH = TextStyle(size: 13, weight: .bold, letterSpacing: 1.2)
    static let srsInfoValueH = TextStyle(size: 15, weight: .bold, letterSpacing: 1.2)
    static let srsButton = TextStyle(size: 12, weight: .black, letterSpacing: 1.5)
    
    // Other
    
    static let navBarButton = TextStyle(size: 11, weight: .black)
    static let asappButton = TextStyle(size: 12, weight: .black, letterSpacing: 1.3)
    static let connectionStatusBanner = TextStyle(size: 12, weight: .bold)
    static let tooltip = TextStyle(size: 14, weight: .bold)
    
    // Modal
    
    static let modalTitle = TextStyle(size: 18, weight: .bold, letterSpacing: 1.2)
    static let modalBody = TextStyle(size: 15, weight: .regular)
    static let modalDetail = TextStyle(size: 13, weight: .bold)
    static let modalPrimaryButton = TextStyle(size: 12, weight: .black, letterSpacing: 1)
    static let modalSecondayButton = TextStyle(size: 12, weight: .regular, letterSpacing: 1)
    
    
    
    
    // Component
    
    static let textButton = TextStyle(size: 12, weight: .black, letterSpacing: 1)
    static let blockButton = TextStyle(size: 12, weight: .black, letterSpacing: 1)
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

// MARK:- UILabel (TextStyle)

extension UILabel {
    
    func setAttributedText(_ text: String?, textStyle: TextStyle, color: UIColor) {
        updateFont(for: textStyle)
        
        if let text = text {
            attributedText = NSAttributedString(string: text, attributes: [
                NSFontAttributeName : ASAPP.styles.font(for: textStyle),
                NSForegroundColorAttributeName : color,
                NSKernAttributeName : textStyle.letterSpacing
                ])
        } else {
            attributedText = nil
        }
    }
    
    func updateFont(for textStyle: TextStyle) {
        font = ASAPP.styles.font(with: textStyle.weight, size: textStyle.size)
    }
}

// MARK:- Button (TextStyle)

extension Button {
    
    func updateFont(for textStyle: TextStyle, styles: ASAPPStyles) {
        font = styles.font(with: textStyle.weight, size: textStyle.size)
    }
}

// MARK:- UIButton (TextStyle)

extension UIButton {
    
    func setAttributedText(_ text: String?, textStyle: TextStyle, color: UIColor, state: UIControlState) {
        updateFont(for: textStyle)
        
        if let text = text {
            setAttributedTitle(NSAttributedString(string: text, attributes: [
                    NSFontAttributeName : ASAPP.styles.font(for: textStyle),
                    NSForegroundColorAttributeName : color,
                    NSKernAttributeName : textStyle.letterSpacing
                ]), for: state)
        } else {
            setAttributedTitle(nil, for: state)
        }
    }
    
    func updateFont(for textStyle: TextStyle) {
        titleLabel?.font = ASAPP.styles.font(with: textStyle.weight, size: textStyle.size)
    }
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
