//
//  TextStyle.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- TextStyle

struct TextStyle {
    
    let fontName: String
    
    let defaultSize: CGFloat
    
    let letterSpacing: CGFloat
    
    let color: UIColor
    
    var size: CGFloat {
        return TextSizeCategory.dynamicFontSize(defaultSize)
    }
    
    var font: UIFont {
        if let font = UIFont(name: fontName, size: size) {
            return font
        }
        
        DebugLog.w(caller: self, "Unable to create font with name: \(fontName)")
        
        return UIFont.systemFont(ofSize: size)
    }
    
    // MARK: Init
    
    init(fontName: String, size: CGFloat, letterSpacing: CGFloat, color: UIColor) {
        self.fontName = fontName
        self.defaultSize = size
        self.letterSpacing = letterSpacing
        self.color = color
    }
    
    init(fontName: String, size: CGFloat, letterSpacing: CGFloat) {
        self.fontName = fontName
        self.defaultSize = size
        self.letterSpacing = letterSpacing
        self.color = UIColor.black
    }
}

public class ASAPPTextStyles {
    
    
    
    
    
    var predictiveHeader = TextStyle(fontName: FontNames.latoBold,
                                     size: 30,
                                     letterSpacing: 0.5,
                                     color: UIColor(red:0.357, green:0.392, blue:0.498, alpha:1))
    
    let header1 = TextStyle(fontName: FontNames.latoBlack,
                            size: 24,
                            letterSpacing: 0.5,
                            color: UIColor(red:0.357, green:0.392, blue:0.498, alpha:1))
    
    let header2 = TextStyle(fontName: FontNames.latoBlack,
                            size: 18,
                            letterSpacing: 0.5,
                            color: UIColor(red:0.357, green:0.392, blue:0.498, alpha:1))
    
    let subheader = TextStyle(fontName: FontNames.latoBlack,
                              size: 12,
                              letterSpacing: 1.5,
                              color: UIColor(red:0.596, green:0.624, blue:0.686, alpha:1.000))
    
    let body = TextStyle(fontName: FontNames.latoRegular,
                         size: 15,
                         letterSpacing: 0.5,
                         color: UIColor(red:0.357, green:0.392, blue:0.498, alpha:1))
    
    let bodyBold  = TextStyle(fontName: FontNames.latoBold,
                              size: 15,
                              letterSpacing: 0.5,
                              color: UIColor(red:0.357, green:0.392, blue:0.498, alpha:1))
    
    let disclaimer = TextStyle(fontName: FontNames.latoRegular,
                               size: 12,
                               letterSpacing: 0.5,
                               color: UIColor(red:0.596, green:0.624, blue:0.686, alpha:1.000))
    
    let error = TextStyle(fontName: FontNames.latoBold,
                          size: 15,
                          letterSpacing: 0.5,
                          color: UIColor(red:0.945, green:0.463, blue:0.392, alpha:1.000))
    
    let readReceipt = TextStyle(fontName: FontNames.latoBold,
                                size: 10,
                                letterSpacing: 0.75,
                                color: UIColor(red:0.596, green:0.624, blue:0.686, alpha:1.000))
    
    let button = TextStyle(fontName: FontNames.latoBlack,
                           size: 14,
                           letterSpacing: 1.5,
                           color: UIColor(red:0.357, green:0.392, blue:0.498, alpha:1))
    
    let link = TextStyle(fontName: FontNames.latoBlack,
                         size: 12,
                         letterSpacing: 1.5,
                         color: UIColor.black)
}

internal class FontNames {
    static let latoLight = "Lato-Light"
    static let latoRegular = "Lato-Regular"
    static let latoBold = "Lato-Bold"
    static let latoBlack = "Lato-Black"
}


// MARK:- Preset TextStyles

extension TextStyle {
    
    
    
    // Predictive
    
    static let predictiveGreeting = TextStyle(size: 28, weight: .bold, letterSpacing: 0.7) // was regular
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
    
    static let navBarButtonBubble = TextStyle(size: 11, weight: .black)
    static let navBarButtonText = TextStyle(size: 14, weight: .black)
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
    static let blockButton = TextStyle(size: 14, weight: .black, letterSpacing: 1)
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
