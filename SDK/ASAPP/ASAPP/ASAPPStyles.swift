//
//  ASAPPStyles.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/3/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

public class ASAPPStyles: NSObject {
    
    // MARK:- Fonts
    
    public var fontNameLight: String = "Lato-Light"
    
    public var fontNameRegular: String = "Lato-Regular"
    
    public var fontNameBold: String = "Lato-Bold"
    
    public var fontNameBlack: String = "Lato-Black"
    
    // MARK:- Navigation Bar
    
    public var navBarBackgroundColor: UIColor = Colors.whiteColor()
    
    public var navBarTitleColor: UIColor = Colors.steelDarkColor()
    
    public var navBarButtonColor: UIColor = UIColor(red:0.355, green:0.394, blue:0.494, alpha:1)
    
    public var navBarButtonForegroundColor: UIColor = UIColor(red:0.264, green:0.278, blue:0.316, alpha:1)
    
    public var navBarButtonBackgroundColor: UIColor = UIColor(red:0.866, green:0.878, blue:0.907, alpha:1)
    
    public var navBarButtonStyle: ASAPPNavBarButtonStyle = .bubble
    
    // MARK:- General Content
    
    public var primaryBackgroundColor: UIColor = Colors.whiteColor()
    
    public var secondaryBackgroundColor: UIColor = Colors.offWhiteColor()
    
    public var primaryTextColor: UIColor = Colors.steelDarkColor()
    
    public var secondaryTextColor: UIColor = Colors.steelDark50Color()
    
    public var primarySeparatorColor: UIColor = Colors.marbleLightColor()
    
    public var secondarySeparatorColor: UIColor = Colors.marbleDarkColor()
    
    public var controlTintColor: UIColor = UIColor(red:0.075, green:0.698, blue:0.925, alpha:1)
    
    public var controlSecondaryColor: UIColor = UIColor(red:0.898, green:0.906, blue:0.918, alpha:1)
    
    // MARK:- Buttons
    
    public var primaryTextButtonColors: ASAPPButtonColors = ASAPPButtonColors(textColor: UIColor(red:0.125, green:0.714, blue:0.931, alpha:1))
    
    public var secondaryTextButtonColors: ASAPPButtonColors = ASAPPButtonColors(textColor: UIColor(red:0.663, green:0.686, blue:0.733, alpha:1))
    
    public var primaryButtonColors: ASAPPButtonColors = ASAPPButtonColors(backgroundColor: UIColor(red:0.204, green:0.698, blue:0.925, alpha:1))

    public var secondaryButtonColors: ASAPPButtonColors = ASAPPButtonColors(backgroundNormal: UIColor(red:0.953, green:0.957, blue:0.965, alpha:1),
                                                                            backgroundHighlighted: UIColor(red:0.903, green:0.907, blue:0.915, alpha:1),
                                                                            backgroundDisabled: UIColor(red:0.6, green:0.6, blue:0.6, alpha:1),
                                                                            textNormal: UIColor(red:0.357, green:0.396, blue:0.494, alpha:1.0),
                                                                            textHighlighted: UIColor(red:0.357, green:0.396, blue:0.494, alpha:1),
                                                                            textDisabled: UIColor(red:0.357, green:0.396, blue:0.494, alpha:0.8),
                                                                            border: UIColor(red:0.886, green:0.890, blue:0.906, alpha:1))
    
    public var predictivePrimaryButtonColors: ASAPPButtonColors = ASAPPButtonColors(backgroundColor: UIColor(red:0.596, green:0.608, blue:0.647, alpha:1))
    
    public var predictiveSecondaryButtonColors: ASAPPButtonColors = ASAPPButtonColors(backgroundColor: UIColor(red:0.475, green:0.486, blue:0.549, alpha:1))
    
    // MARK:- Colors: Messages
    
    public var messageTextColor: UIColor = UIColor(red:0.476, green:0.498, blue:0.565, alpha:1)
    
    public var messageBackgroundColor: UIColor = Colors.whiteColor()
    
    public var messageBorderColor: UIColor? = UIColor(red:0.749, green:0.757, blue:0.790, alpha:1)
    
    public var replyMessageTextColor: UIColor = UIColor(red:0.264, green:0.278, blue:0.316, alpha:1)
    
    public var replyMessageBackgroundColor: UIColor = UIColor(red:0.941, green:0.945, blue:0.953, alpha:1)
    
    public var replyMessageBorderColor: UIColor? = nil
    
    // MARK:- Colors: Chat

    public var quickRepliesBackgroundColor: UIColor = UIColor(red:0.969, green:0.965, blue:0.965, alpha:1.000)
    
    public var quickReplyButtonColors: ASAPPButtonColors = ASAPPButtonColors(backgroundColor: Colors.offWhiteColor(),
                                                                             textColor: Colors.steelMedColor())
    
    public var chatInputColors: ASAPPInputColors = ASAPPInputColors(background: Colors.whiteColor(),
                                                                    text: Colors.darkTextColor(),
                                                                    placeholderText: Colors.mediumTextColor(),
                                                                    tint: Colors.grayColor(),
                                                                    border: Colors.lighterGrayColor(),
                                                                    primaryButton: Colors.blueGrayColor(),
                                                                    secondaryButton: Colors.mediumTextColor())
    
    // MARK:- Colors: Predictive
    
    public var predictiveNavBarButtonColor: UIColor = UIColor.white
    
    public var predictiveNavBarButtonForegroundColor: UIColor = UIColor.white
    
    public var predictiveNavBarButtonBackgroundColor: UIColor = UIColor(red:0.201, green:0.215, blue:0.249, alpha:1)
    
    public var predictiveGradientTopColor: UIColor = UIColor(red:0.302, green:0.310, blue:0.347, alpha:0.9)
    
    public var predictiveGradientMiddleColor: UIColor = UIColor(red:0.366, green:0.384, blue:0.426, alpha:0.8)
    
    public var predictiveGradientBottomColor: UIColor = UIColor(red:0.483, green:0.505, blue:0.568, alpha:0.8)
    
    public var predictivePrimaryTextColor: UIColor = UIColor.white
    
    public var predictiveSecondaryTextColor: UIColor = Colors.steelMed50Color()
    
    public var predictiveInputColors: ASAPPInputColors = ASAPPInputColors(background: UIColor(red:0.232, green:0.247, blue:0.284, alpha:1),
                                                                          text: UIColor.white,
                                                                          placeholderText: UIColor(red:0.671, green:0.678, blue:0.694, alpha:1.000),
                                                                          tint: UIColor(red:0.671, green:0.678, blue:0.694, alpha:1.000),
                                                                          border: nil,
                                                                          primaryButton: UIColor.white,
                                                                          secondaryButton: UIColor.white)
    
    // MARK:- Help Button
    
    public var helpButtonForegroundColor: UIColor = UIColor.white
    
    public var helpButtonBackgroundColor: UIColor = UIColor(red:0.374, green:0.392, blue:0.434, alpha:1)
}


@objc
public enum ASAPPNavBarButtonStyle: Int {
    case bubble = 0
    case text = 1
}

public class ASAPPButtonColors: NSObject {
    
    public var backgroundNormal: UIColor
    public var backgroundHighlighted: UIColor
    public var backgroundDisabled: UIColor
    
    public var textNormal: UIColor
    public var textHighlighted: UIColor
    public var textDisabled: UIColor
    
    public var border: UIColor?
    
    // MARK:- Init
    
    public init(backgroundNormal: UIColor,
                backgroundHighlighted: UIColor,
                backgroundDisabled: UIColor,
                textNormal: UIColor,
                textHighlighted: UIColor,
                textDisabled: UIColor,
                border: UIColor?) {
        self.backgroundNormal = backgroundNormal
        self.backgroundHighlighted = backgroundHighlighted
        self.backgroundDisabled = backgroundDisabled
        self.textNormal = textNormal
        self.textHighlighted = textHighlighted
        self.textDisabled = textDisabled
        self.border = border
        super.init()
    }
    
    public init(textColor: UIColor) {
        self.backgroundNormal = UIColor.clear
        self.backgroundHighlighted = UIColor.clear
        self.backgroundDisabled = UIColor.clear
        
        self.textNormal = textColor
        self.textHighlighted = textColor.withAlphaComponent(0.6)
        self.textDisabled =  UIColor(red:0.6, green:0.6, blue:0.6, alpha:1)
        
        super.init()
    }
    
    public init(backgroundColor: UIColor, textColor: UIColor) {
        self.backgroundNormal = backgroundColor
        self.backgroundHighlighted = backgroundColor.highlightColor() ?? backgroundColor
        self.backgroundDisabled = backgroundColor
        
        self.textNormal = textColor
        self.textHighlighted = textColor
        self.textDisabled = textColor.withAlphaComponent(0.8)
        
        super.init()
    }
    
    public init(backgroundColor: UIColor) {
        self.backgroundNormal = backgroundColor
        self.backgroundHighlighted = backgroundColor.highlightColor() ?? backgroundColor
        self.backgroundDisabled = UIColor(red:0.6, green:0.6, blue:0.6, alpha:1)
        
        self.textNormal = UIColor.white
        self.textHighlighted = UIColor.white
        self.textDisabled = UIColor.white.withAlphaComponent(0.8)
        
        super.init()
    }
}

extension UIButton {
    
    func applyColors(_ colors: ASAPPButtonColors) {
        setBackgroundImage(UIImage.imageWithColor(colors.backgroundNormal), for: .normal)
        setBackgroundImage(UIImage.imageWithColor(colors.backgroundHighlighted), for: .highlighted)
        setBackgroundImage(UIImage.imageWithColor(colors.backgroundDisabled), for: .disabled)
        
        setTitleColor(colors.textNormal, for: .normal)
        setTitleColor(colors.textHighlighted, for: .highlighted)
        setTitleColor(colors.textDisabled, for: .disabled)
        
        if let borderColor = colors.border {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 1
        } else {
            layer.borderColor = nil
            layer.borderWidth = 0
        }
    }
}

public class ASAPPInputColors: NSObject {
    
    public var background: UIColor

    public var text: UIColor

    public var placeholderText: UIColor
    
    public var tint: UIColor
    
    public var border: UIColor?
    
    public var primaryButton: UIColor
    
    public var secondaryButton: UIColor

    public init(background: UIColor,
                text: UIColor,
                placeholderText: UIColor,
                tint: UIColor,
                border: UIColor?,
                primaryButton: UIColor,
                secondaryButton: UIColor) {
        self.background = background
        self.text = text
        self.placeholderText = placeholderText
        self.tint = tint
        self.border = border
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        super.init()
    }
}
