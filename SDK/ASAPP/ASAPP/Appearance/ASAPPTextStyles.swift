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
    
    /// The style of the navigation bar title.
    public var navTitle = ASAPPTextStyle(font: Fonts.default.bold, size: 18, letterSpacing: 2, color: UIColor.ASAPP.manateeGray)
    
    /// The style of navigation bar buttons.
    public var navButton = ASAPPTextStyle(font: Fonts.default.bold, size: 11, letterSpacing: 1, color: UIColor.ASAPP.manateeGray)
    
    // MARK: ComponentUI: Headers
    
    /// The style of top-level headers.
    public var header1 = ASAPPTextStyle(font: Fonts.default.bold, size: 24, letterSpacing: 0.5, color: UIColor.ASAPP.cometBlue)
    
    /// The style of second-level headers.
    public var header2 = ASAPPTextStyle(font: Fonts.default.bold, size: 18, letterSpacing: 0.5, color: UIColor.ASAPP.cometBlue)
    
    /// The style of subheaders.
    public var subheader = ASAPPTextStyle(font: Fonts.default.bold, size: 11, letterSpacing: 1.5, color: UIColor.ASAPP.manateeGray)

    // MARK: ComponentUI: Body
    
    /// The style of body text.
    public var body = ASAPPTextStyle(font: Fonts.default.regular, size: 15, letterSpacing: 0.5, color: UIColor.ASAPP.cometBlue)
    
    /// The style of bold body text.
    public var bodyBold  = ASAPPTextStyle(font: Fonts.default.medium, size: 15, letterSpacing: 0.5, color: UIColor.ASAPP.cometBlue)
    
    /// The style of italic body text.
    public var bodyItalic = ASAPPTextStyle(font: Fonts.default.regularItalic ?? Fonts.default.regular, size: 15, letterSpacing: 0.5, color: UIColor.ASAPP.cometBlue)
    
    /// The style of bold italic body text.
    public var bodyBoldItalic = ASAPPTextStyle(font: Fonts.default.mediumItalic ?? Fonts.default.medium, size: 15, letterSpacing: 0.5, color: UIColor.ASAPP.cometBlue)
    
    /// The style of top-level detail text.
    public var detail1 = ASAPPTextStyle(font: Fonts.default.regular, size: 12, letterSpacing: 0.5, color: UIColor.ASAPP.manateeGray)
    
    /// The style of second-level detail text.
    public var detail2 = ASAPPTextStyle(font: Fonts.default.medium, size: 10, letterSpacing: 0.75, color: UIColor.ASAPP.manateeGray)
    
    /// The style of error text.
    public var error = ASAPPTextStyle(font: Fonts.default.medium, size: 15, letterSpacing: 0.5, color: UIColor.ASAPP.burntSiennaRed)

    // MARK: ComponentUI: Buttons
    
    /// The text style of buttons.
    public var button = ASAPPTextStyle(font: Fonts.default.bold, size: 14, letterSpacing: 1.5, color: UIColor.ASAPP.cometBlue)
    
    /// The style of action buttons.
    public var actionButton = ASAPPTextStyle(font: Fonts.default.medium, size: 12, letterSpacing: 0.5, color: UIColor.ASAPP.cometBlue, uppercase: true)
    
    /// The style of links.
    public var link = ASAPPTextStyle(font: Fonts.default.bold, size: 12, letterSpacing: 1.5, color: UIColor.ASAPP.ceruleanBlue)
    
    // MARK: ComponentUI: Fonts
    
    /**
     Updates all text styles above with the given font family.
     
     - parameter fontFamily: The font family to apply to all text styles. Each text style will use an appropriate weight.
     */
    public func updateStyles(for fontFamily: ASAPPFontFamily) {
        navTitle.updateFont(fontFamily.medium)
        navButton.updateFont(fontFamily.medium)
        bodyItalic.updateFont(fontFamily.regularItalic ?? fontFamily.regular)
        bodyBoldItalic.updateFont(fontFamily.mediumItalic ?? fontFamily.medium)
        header1.updateFont(fontFamily.bold)
        header2.updateFont(fontFamily.bold)
        subheader.updateFont(fontFamily.bold)
        body.updateFont(fontFamily.regular)
        bodyBold.updateFont(fontFamily.medium)
        detail1.updateFont(fontFamily.regular)
        detail2.updateFont(fontFamily.medium)
        error.updateFont(fontFamily.medium)
        button.updateFont(fontFamily.bold)
        link.updateFont(fontFamily.bold)
    }
}

extension ASAPPTextStyles {
    
    func style(for type: TextType) -> ASAPPTextStyle {
        switch type {
        case .navTitle: return navTitle
        case .navButton: return navButton
        case .header1: return header1
        case .header2: return header2
        case .subheader: return subheader
        case .body: return body
        case .bodyBold: return bodyBold
        case .bodyItalic: return bodyItalic
        case .bodyBoldItalic: return bodyBoldItalic
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
