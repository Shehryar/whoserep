//
//  ASAPPTextStyles.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class ASAPPTextStyles: NSObject {
    
    var navTitle: ASAPPTextStyle = ASAPPTextStyle(fontName: .latoBold, size: 15, letterSpacing: 0.5, color: .asapp_manateeGray)
    
    // MARK:- ComponentUI
    // MARK: Headers
    
    var predictiveHeader: ASAPPTextStyle = ASAPPTextStyle(fontName: .latoRegular, size: 30, letterSpacing: 0.5, color: .asapp_cometBlue)
    
    var header1: ASAPPTextStyle = ASAPPTextStyle(fontName: .latoBlack, size: 24, letterSpacing: 0.5, color: .asapp_cometBlue)
    
    var header2: ASAPPTextStyle = ASAPPTextStyle(fontName: .latoBlack, size: 18, letterSpacing: 0.5, color: .asapp_cometBlue)
    
    var subheader: ASAPPTextStyle = ASAPPTextStyle(fontName: .latoBlack, size: 10, letterSpacing: 1.5, color: .asapp_manateeGray)
    
    // MARK: Body
    
    var body: ASAPPTextStyle = ASAPPTextStyle(fontName: .latoRegular, size: 15, letterSpacing: 0.5, color: .asapp_cometBlue)
    
    var bodyBold: ASAPPTextStyle  = ASAPPTextStyle(fontName: .latoBold, size: 15, letterSpacing: 0.5, color: .asapp_cometBlue)
    
    var detail1: ASAPPTextStyle = ASAPPTextStyle(fontName: .latoRegular, size: 12, letterSpacing: 0.5, color: .asapp_manateeGray)
    
    var detail2: ASAPPTextStyle = ASAPPTextStyle(fontName: .latoBold, size: 10, letterSpacing: 0.75, color: .asapp_manateeGray)
    
    var error: ASAPPTextStyle = ASAPPTextStyle(fontName: .latoBold, size: 15, letterSpacing: 0.5, color: .asapp_burntSiennaRed)
    
    // MARK: Buttons
    
    var button: ASAPPTextStyle = ASAPPTextStyle(fontName: .latoBlack, size: 14, letterSpacing: 1.5, color: .asapp_cometBlue)
    
    var link: ASAPPTextStyle = ASAPPTextStyle(fontName: .latoBlack, size: 12, letterSpacing: 1.5, color: .asapp_ceruleanBlue)
    
    var navButton: ASAPPTextStyle = ASAPPTextStyle(fontName: .latoBold, size: 12, letterSpacing: 0, color: .asapp_manateeGray)
}

extension ASAPPTextStyles {
    
    func style(for type: TextType) -> ASAPPTextStyle {
        switch type {
        case .navTitle: return navTitle
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
        case .navButton: return navButton
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
