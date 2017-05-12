//
//  ASAPPTextStyles.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class ASAPPTextStyles: NSObject {
    
    // MARK: Headers
    
    var predictiveHeader: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoRegular, size: 30, letterSpacing: 0.5, color: UIColor.asapp_cometBlue)
    
    var header1: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoBlack, size: 24, letterSpacing: 0.5, color: UIColor.asapp_cometBlue)
    
    var header2: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoBlack, size: 18, letterSpacing: 0.5, color: UIColor.asapp_cometBlue)
    
    var subheader: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoBlack, size: 10, letterSpacing: 1.5, color: UIColor.asapp_manateeGray)
    
    // MARK: Body
    
    var body: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoRegular, size: 15, letterSpacing: 0.5, color: UIColor.asapp_cometBlue)
    
    var bodyBold: ASAPPTextStyle  = ASAPPTextStyle(fontName: FontNames.latoBold, size: 15, letterSpacing: 0.5, color: UIColor.asapp_cometBlue)
    
    var detail1: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoRegular, size: 12, letterSpacing: 0.5, color: UIColor.asapp_manateeGray)
    
    var detail2: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoBold, size: 10, letterSpacing: 0.75, color: UIColor.asapp_manateeGray)
    
    var error: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoBold, size: 15, letterSpacing: 0.5, color: UIColor.asapp_burntSiennaRed)
    
    // MARK: Buttons
    
    var button: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoBlack, size: 14, letterSpacing: 1.5, color: UIColor.asapp_cometBlue)
    
    var link: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoBlack, size: 12, letterSpacing: 1.5, color: UIColor.asapp_ceruleanBlue)
}

extension ASAPPTextStyles {
    
    func style(for type: TextType) -> ASAPPTextStyle {
        switch type {
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
