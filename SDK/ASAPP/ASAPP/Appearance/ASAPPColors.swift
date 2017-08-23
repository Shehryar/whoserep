//
//  ASAPPColors.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class ASAPPColors: NSObject {
    
    // MARK:- Navigation Bar
    
    public var navBarBackground: UIColor = UIColor.white
    
    public var navBarTitle: UIColor = UIColor(red: 57.0 / 255.0, green: 61.0 / 255.0, blue: 71.0 / 255.0, alpha: 0.95)
    
    public var navBarButton: UIColor = UIColor(red:0.355, green:0.394, blue:0.494, alpha:1)
    
    public var navBarButtonForeground: UIColor = UIColor(red:0.264, green:0.278, blue:0.316, alpha:1)
    
    public var navBarButtonBackground: UIColor = UIColor(red:0.866, green:0.878, blue:0.907, alpha:1)
    
    // MARK:- General Content
    
    public var backgroundPrimary: UIColor = UIColor.white
    
    public var backgroundSecondary: UIColor = UIColor(red:0.972, green:0.969, blue:0.968, alpha:1)
    
    public var textPrimary: UIColor = UIColor(red: 57.0 / 255.0, green: 61.0 / 255.0, blue: 71.0 / 255.0, alpha: 0.95)
    
    public var textSecondary: UIColor = UIColor(red: 157 / 255.0, green: 158 / 255.0, blue: 163 / 255.0, alpha: 0.95)
    
    public var separatorPrimary: UIColor = UIColor(red:0.766, green:0.774, blue:0.797, alpha:1.000)
    
    public var separatorSecondary: UIColor = UIColor(red:0.816, green:0.824, blue:0.847, alpha:0.5)
    
    public var controlTint: UIColor = UIColor(red:0.075, green:0.698, blue:0.925, alpha:1)
    
    public var controlSecondary: UIColor = UIColor(red:0.898, green:0.906, blue:0.918, alpha:1)
    
    public var controlSelectedBackground: UIColor = UIColor(red:0.953, green:0.957, blue:0.965, alpha:1.000)
    
    // MARK:- Buttons
    
    public var textButtonPrimary: ASAPPButtonColors = ASAPPButtonColors(textColor: UIColor(red:0.125, green:0.714, blue:0.931, alpha:1))
    
    public var textButtonSecondary: ASAPPButtonColors = ASAPPButtonColors(textColor: UIColor(red:0.663, green:0.686, blue:0.733, alpha:1))
    
    public var buttonPrimary: ASAPPButtonColors = ASAPPButtonColors(backgroundColor: UIColor(red:0.204, green:0.698, blue:0.925, alpha:1))
    
    public var buttonSecondary: ASAPPButtonColors = ASAPPButtonColors(backgroundNormal: UIColor(red:0.953, green:0.957, blue:0.965, alpha:1),
                                                                      backgroundHighlighted: UIColor(red:0.903, green:0.907, blue:0.915, alpha:1),
                                                                      backgroundDisabled: UIColor(red:0.6, green:0.6, blue:0.6, alpha:1),
                                                                      textNormal: UIColor(red:0.357, green:0.396, blue:0.494, alpha:1.0),
                                                                      textHighlighted: UIColor(red:0.357, green:0.396, blue:0.494, alpha:1),
                                                                      textDisabled: UIColor(red:0.357, green:0.396, blue:0.494, alpha:0.8),
                                                                      border: UIColor(red:0.886, green:0.890, blue:0.906, alpha:1))
    
    public var predictiveButtonPrimary: ASAPPButtonColors = ASAPPButtonColors(backgroundColor: UIColor(red:0.596, green:0.608, blue:0.647, alpha:1))
    
    public var predictiveButtonSecondary: ASAPPButtonColors = ASAPPButtonColors(backgroundColor: UIColor(red:0.475, green:0.486, blue:0.549, alpha:1))
    
    // MARK:- Colors: Messages
    
    public var messagesListBackground = UIColor.asapp_alabasterWhite
    
    public var messageText: UIColor = UIColor(red:0.476, green:0.498, blue:0.565, alpha:1)
    
    public var messageBackground: UIColor = UIColor.white
    
    public var messageBorder: UIColor? = UIColor(red:0.766, green:0.774, blue:0.797, alpha:1.000)
    
    public var replyMessageText: UIColor = UIColor(red:0.264, green:0.278, blue:0.316, alpha:1)
    
    public var replyMessageBackground: UIColor = UIColor(red:0.941, green:0.945, blue:0.953, alpha:1)
    
    public var replyMessageBorder: UIColor? = nil
    
    // MARK:- Colors: Chat
    
    public var quickRepliesBackground: UIColor = UIColor(red:0.969, green:0.965, blue:0.965, alpha:1.000)
    
    
    
    public var quickReplyButton: ASAPPButtonColors = ASAPPButtonColors(backgroundColor: UIColor(red:0.972, green:0.969, blue:0.968, alpha:1),
                                                                       textColor: UIColor(red: 91.0 / 255.0, green: 101.0 / 255.0, blue: 126.0 / 255.0, alpha: 1.0))
    
    public var quickReplyViewButton: ASAPPButtonColors = ASAPPButtonColors(backgroundColor: UIColor(red:0.953, green:0.957, blue:0.965, alpha:1),
                                                                           textColor: UIColor(red: 91.0 / 255.0, green: 101.0 / 255.0, blue: 126.0 / 255.0, alpha: 1.0))
    
    public var chatInput: ASAPPInputColors = ASAPPInputColors(background: UIColor.white,
                                                              text: UIColor(red:0.283,  green:0.290,  blue:0.307, alpha:1),
                                                              placeholderText: UIColor(red:0.535,  green:0.557,  blue:0.586, alpha:1),
                                                              tint: UIColor(red:0.682,  green:0.682,  blue:0.682, alpha:1),
                                                              border: UIColor(red:0.937,  green:0.945,  blue:0.949, alpha:1),
                                                              primaryButton: UIColor(red:0.476,  green:0.498,  blue:0.565, alpha:1),
                                                              secondaryButton: UIColor(red:0.535,  green:0.557,  blue:0.586, alpha:1))
    
    // MARK:- Colors: Predictive
    
    public var predictiveNavBarTitle: UIColor = UIColor.white
    
    public var predictiveNavBarButton: UIColor = UIColor.white
    
    public var predictiveNavBarButtonForeground: UIColor = UIColor.white
    
    public var predictiveNavBarButtonBackground: UIColor = UIColor(red:0.201, green:0.215, blue:0.249, alpha:1)
    
    public var predictiveGradientTop: UIColor = UIColor(red:0.302, green:0.310, blue:0.347, alpha:0.9)
    
    public var predictiveGradientMiddle: UIColor = UIColor(red:0.366, green:0.384, blue:0.426, alpha:0.8)
    
    public var predictiveGradientBottom: UIColor = UIColor(red:0.483, green:0.505, blue:0.568, alpha:0.8)
    
    public var predictiveTextPrimary: UIColor = UIColor.white
    
    public var predictiveTextSecondary: UIColor = UIColor(red: 173 / 255.0, green: 178 / 255.0, blue: 190 / 255.0, alpha: 1.0)
    
    public var predictiveInput: ASAPPInputColors = ASAPPInputColors(background: UIColor(red:0.232, green:0.247, blue:0.284, alpha:1),
                                                                    text: UIColor.white,
                                                                    placeholderText: UIColor(red:0.671, green:0.678, blue:0.694, alpha:1.000),
                                                                    tint: UIColor(red:0.671, green:0.678, blue:0.694, alpha:1.000),
                                                                    border: nil,
                                                                    primaryButton: UIColor.white,
                                                                    secondaryButton: UIColor.white)
    
    // MARK:- Help Button
    
    public var helpButtonText: UIColor = UIColor.white
    
    public var helpButtonBackground: UIColor = UIColor(red:0.374, green:0.392, blue:0.434, alpha:1)
}

extension ASAPPColors {
    
    func getButtonColors(for buttonType: ButtonType) -> ASAPPButtonColors {
        switch buttonType {
        case .primary: return ASAPP.styles.colors.buttonPrimary
        case .secondary: return ASAPP.styles.colors.buttonSecondary
        case .textPrimary: return ASAPP.styles.colors.textButtonPrimary
        case .textSecondary: return ASAPP.styles.colors.textButtonSecondary
        }
    }
}


