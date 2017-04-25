//
//  ASAPPTextStyles.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class ASAPPTextStyles {
    
    // MARK: Headers
    
    var predictiveHeader: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoBold, size: 30, letterSpacing: 0.5, color: UIColor.cometBlue)
    
    var header1: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoBlack, size: 24, letterSpacing: 0.5, color: UIColor.cometBlue)
    
    var header2: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoBlack, size: 18, letterSpacing: 0.5, color: UIColor.cometBlue)
    
    var subheader: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoBlack, size: 12, letterSpacing: 1.5, color: UIColor.manateeGray)
    
    // MARK: Body
    
    var body: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoRegular, size: 15, letterSpacing: 0.5, color: UIColor.cometBlue)
    
    var bodyBold: ASAPPTextStyle  = ASAPPTextStyle(fontName: FontNames.latoBold, size: 15, letterSpacing: 0.5, color: UIColor.cometBlue)
    
    var disclaimer: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoRegular, size: 12, letterSpacing: 0.5, color: UIColor.manateeGray)
    
    var error: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoBold, size: 15, letterSpacing: 0.5, color: UIColor.burntSiennaRed)
    
    var readReceipt: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoBold, size: 10, letterSpacing: 0.75, color: UIColor.manateeGray)
    
    // MARK: Buttons
    
    var button: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoBlack, size: 14, letterSpacing: 1.5, color: UIColor.cometBlue)
    
    var link: ASAPPTextStyle = ASAPPTextStyle(fontName: FontNames.latoBlack, size: 12, letterSpacing: 1.5, color: UIColor.ceruleanBlue)
}
