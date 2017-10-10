//
//  ASAPPTextStyles.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

@objcMembers
public class ASAPPTextStyles: NSObject {
    
    public var navTitle: ASAPPTextStyle = ASAPPTextStyle(font: Fonts.default.medium, size: 15, letterSpacing: 0.5, color: .asapp_manateeGray)
    
    public var navButton: ASAPPTextStyle = ASAPPTextStyle(font: Fonts.default.medium, size: 12, letterSpacing: 0, color: .asapp_manateeGray)
    
    // MARK:- ComponentUI
    // MARK: Headers
    
    public var predictiveHeader: ASAPPTextStyle = ASAPPTextStyle(font: Fonts.default.regular, size: 30, letterSpacing: 0.5, color: .asapp_cometBlue)
    
    public var header1: ASAPPTextStyle = ASAPPTextStyle(font: Fonts.default.bold, size: 24, letterSpacing: 0.5, color: .asapp_cometBlue)
    
    public var header2: ASAPPTextStyle = ASAPPTextStyle(font: Fonts.default.bold, size: 18, letterSpacing: 0.5, color: .asapp_cometBlue)
    
    public var subheader: ASAPPTextStyle = ASAPPTextStyle(font: Fonts.default.bold, size: 10, letterSpacing: 1.5, color: .asapp_manateeGray)
    
    // MARK: Body
    
    public var body: ASAPPTextStyle = ASAPPTextStyle(font: Fonts.default.regular, size: 15, letterSpacing: 0.5, color: .asapp_cometBlue)
    
    public var bodyBold: ASAPPTextStyle  = ASAPPTextStyle(font: Fonts.default.medium, size: 15, letterSpacing: 0.5, color: .asapp_cometBlue)
    
    public var detail1: ASAPPTextStyle = ASAPPTextStyle(font: Fonts.default.regular, size: 12, letterSpacing: 0.5, color: .asapp_manateeGray)
    
    public var detail2: ASAPPTextStyle = ASAPPTextStyle(font: Fonts.default.medium, size: 10, letterSpacing: 0.75, color: .asapp_manateeGray)
    
    public var error: ASAPPTextStyle = ASAPPTextStyle(font: Fonts.default.medium, size: 15, letterSpacing: 0.5, color: .asapp_burntSiennaRed)
    
    // MARK: Buttons
    
    public var button: ASAPPTextStyle = ASAPPTextStyle(font: Fonts.default.bold, size: 14, letterSpacing: 1.5, color: .asapp_cometBlue)
    
    public var link: ASAPPTextStyle = ASAPPTextStyle(font: Fonts.default.bold, size: 12, letterSpacing: 1.5, color: .asapp_ceruleanBlue)
    
    // MARK: Fonts
    
    public func updateStyles(for fontFamily: ASAPPFontFamily) {
        navTitle.updateFont(fontFamily.medium)
        navButton.updateFont(fontFamily.medium)
        predictiveHeader.updateFont(fontFamily.regular)
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
        case .predictiveHeader: return predictiveHeader
        case .header1: return header1
        case .header2: return header2
        case .subheader: return subheader
        case .body: return body
        case .bodyBold: return bodyBold
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
