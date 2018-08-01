//
//  ASAPPTextStyles.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

/**
 Customizable text styles for various classes of text.
 */
@objc(ASAPPTextStyles)
@objcMembers
public class ASAPPTextStyles: NSObject {
    // MARK: General
    
    /// The style of navigation bar buttons.
    public var navButton = ASAPPTextStyle(font: Fonts.default.bold, size: 11, letterSpacing: 1, color: UIColor.ASAPP.manateeGray)
    
    /// The text style of buttons.
    public var button = ASAPPTextStyle(font: Fonts.default.regular, size: 15, letterSpacing: 0.2, color: UIColor.ASAPP.cometBlue)
    
    /// The style of action buttons.
    public var actionButton = ASAPPTextStyle(font: Fonts.default.regular, size: 15, letterSpacing: 0.5, color: .white)
    
    /// The style of links.
    public var link = ASAPPTextStyle(font: Fonts.default.bold, size: 12, letterSpacing: 1.5, color: UIColor.ASAPP.ceruleanBlue)
    
    // MARK: ComponentUI: Headers
    
    /// The style of top-level headers.
    public var header1 = ASAPPTextStyle(font: Fonts.default.regular, size: 24, letterSpacing: 0.5, color: UIColor.ASAPP.purpleHaze.withAlphaComponent(0.9))
    
    /// The style of second-level headers.
    public var header2 = ASAPPTextStyle(font: Fonts.default.bold, size: 20, letterSpacing: 0.5, color: UIColor.ASAPP.purpleHaze)
    
    /// The style of third-level headers.
    public var header3 = ASAPPTextStyle(font: Fonts.default.medium, size: 18, letterSpacing: 0.5, color: UIColor.ASAPP.purpleHaze)
    
    /// The style of subheaders.
    public var subheader = ASAPPTextStyle(font: Fonts.default.medium, size: 11, letterSpacing: 0.5, color: UIColor.ASAPP.purpleHaze)

    // MARK: ComponentUI: Body
    
    /// The style of body text.
    public var body = ASAPPTextStyle(font: Fonts.default.regular, size: 16, letterSpacing: 0.2, color: UIColor.ASAPP.purpleHaze.withAlphaComponent(0.85))
    
    /// The style of bold body text.
    public var bodyBold  = ASAPPTextStyle(font: Fonts.default.medium, size: 16, letterSpacing: 0.5, color: UIColor.ASAPP.purpleHaze)
    
    /// The style of secondary body text.
    public var body2 = ASAPPTextStyle(font: Fonts.default.regular, size: 15, letterSpacing: 0.2, color: UIColor.ASAPP.purpleHaze.withAlphaComponent(0.85))
    
    /// The style of bold secondary body text.
    public var bodyBold2  = ASAPPTextStyle(font: Fonts.default.medium, size: 16, letterSpacing: 0.2, color: UIColor.ASAPP.purpleHaze)
    
    /// The style of top-level detail text.
    public var detail1 = ASAPPTextStyle(font: Fonts.default.regular, size: 11, letterSpacing: 0.5, color: UIColor.ASAPP.purpleHaze.withAlphaComponent(0.5))
    
    /// The style of second-level detail text.
    public var detail2 = ASAPPTextStyle(font: Fonts.default.regular, size: 12, letterSpacing: 0.5, color: UIColor.ASAPP.purpleHaze.withAlphaComponent(0.9))
    
    /// The style of error text.
    public var error = ASAPPTextStyle(font: Fonts.default.regular, size: 12, letterSpacing: 0.5, color: UIColor.ASAPP.errorRed)
    
    // MARK: ComponentUI: Fonts
    
    /**
     Updates all text styles above with the given font family.
     
     - parameter fontFamily: The font family to apply to all text styles. Each text style will use an appropriate weight.
     */
    public func updateStyles(for fontFamily: ASAPPFontFamily) {
        navButton.updateFont(fontFamily.bold)
        button.updateFont(fontFamily.regular)
        actionButton.updateFont(fontFamily.regular)
        link.updateFont(fontFamily.bold)
        
        header1.updateFont(fontFamily.regular)
        header2.updateFont(fontFamily.bold)
        header3.updateFont(fontFamily.medium)
        subheader.updateFont(fontFamily.medium)
        body.updateFont(fontFamily.regular)
        bodyBold.updateFont(fontFamily.medium)
        body2.updateFont(fontFamily.regular)
        bodyBold2.updateFont(fontFamily.medium)
        detail1.updateFont(fontFamily.regular)
        detail2.updateFont(fontFamily.regular)
        error.updateFont(fontFamily.regular)
    }
    
    /**
     Updates all text styles above with the given color.
     
     - parameter color: The color to apply to all text styles. Each text style will use the color at an appropriate opacity.
     */
    public func updateColors(with color: UIColor) {
        header1.updateColor(color.withAlphaComponent(0.9))
        header2.updateColor(color)
        header3.updateColor(color)
        subheader.updateColor(color)
        body.updateColor(color.withAlphaComponent(0.85))
        bodyBold.updateColor(color)
        body2.updateColor(color.withAlphaComponent(0.85))
        bodyBold2.updateColor(color)
        detail1.updateColor(color.withAlphaComponent(0.5))
        detail2.updateColor(color.withAlphaComponent(0.9))
    }
}

extension ASAPPTextStyles {
    
    func style(for type: TextType) -> ASAPPTextStyle {
        switch type {
        case .navButton: return navButton
        case .header1: return header1
        case .header2: return header2
        case .header3: return header3
        case .subheader: return subheader
        case .body: return body
        case .bodyBold: return bodyBold
        case .body2: return body2
        case .bodyBold2: return bodyBold2
        case .detail1: return detail1
        case .detail2: return detail2
        case .error: return error
        case .button: return button
        case .link: return link
        }
    }
    
    func getStyle(forButtonType buttonType: ButtonType) -> ASAPPTextStyle {
        switch buttonType {
        case .primary, .secondary:
            return button
            
        case .textPrimary, .textSecondary:
            return link
        }
    }
}
