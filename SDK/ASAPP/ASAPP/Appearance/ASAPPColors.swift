//
//  ASAPPColors.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

/**
 Configurable colors for various parts of the SDK.
 */
@objc(ASAPPColors)
@objcMembers
public class ASAPPColors: NSObject {
    
    // MARK: - General
    
    /// The color of most primary text and UI elements such as icons and buttons.
    public var primary = UIColor.ASAPP.eggplant {
        didSet {
            updateColors(primary: primary, dark: dark)
        }
    }
    
    /// The color of most secondary text and UI elements.
    public var dark = UIColor.ASAPP.purpleHaze {
        didSet {
            updateColors(primary: primary, dark: dark)
        }
    }
    
    // MARK: - Chat: Navigation Bar
    
    /// The background color of the navigation bar.
    public var navBarBackground: UIColor?
    
    /// The color of the navigation bar title text.
    public var navBarTitle = UIColor.ASAPP.purpleHaze.withAlphaComponent(0.85)
    
    /// The color of navigation bar buttons in the chat view, as well as the color of the close/back button.
    public var navBarButton = UIColor.ASAPP.purpleHaze
    
    /// The color of navigaiton bar buttons while tapped.
    public var navBarButtonActive = UIColor.ASAPP.eggplant
    
    // MARK: - Chat: General Content
    
    /// The color of the background of most elements.
    public var backgroundPrimary = UIColor.white
    
    /// The color of the background of image views, tabs, and other secondary elements.
    public var backgroundSecondary = UIColor(red: 0.972, green: 0.969, blue: 0.968, alpha: 1)
    
    /// The color of most text.
    public var textPrimary = UIColor(red: 57.0 / 255.0, green: 61.0 / 255.0, blue: 71.0 / 255.0, alpha: 1)
    
    /// The color of secondary text, such as timestamp labels.
    public var textSecondary = UIColor.ASAPP.purpleHaze
    
    /// The color of most separators.
    public var separatorPrimary = UIColor(red: 0.86, green: 0.87, blue: 0.88, alpha: 1)
    
    /// The color of secondary separators, such as the borders of checkboxes and tabs.
    public var separatorSecondary = UIColor.ASAPP.purpleHaze.withAlphaComponent(0.15)
    
    /// The color of the active portion of controls, such as checkboxes, progress bars, radio buttons, sliders, and tabs.
    public var controlTint = UIColor(red: 0.075, green: 0.698, blue: 0.925, alpha: 1)
    
    /// The color of the secondary portion of some controls, such as the background of progress bars and the underline of text inputs.
    public var controlSecondary = UIColor(red: 0.898, green: 0.906, blue: 0.918, alpha: 1)
    
    /// The color of the background of selected checkboxes and radio buttons.
    public var controlSelectedBackground = UIColor(red: 0.953, green: 0.957, blue: 0.965, alpha: 1)
    
    /// The default color of the background of a selected button representing a positive choice (such as in a BinaryRatingView).
    public var positiveSelectedBackground = UIColor.ASAPP.successGreen
    
    /// The default color of the background of a selected button representing a negative choice (such as in a BinaryRatingView).
    public var negativeSelectedBackground = UIColor.ASAPP.errorRed
    
    // MARK: - Chat: Buttons
    
    /// The color of text buttons, usually an accent color.
    public var textButtonPrimary = ASAPPButtonColors(textColor: UIColor.ASAPP.eggplant)
    
    /// The color of secondary text buttons, usually a muted color.
    public var textButtonSecondary = ASAPPButtonColors(textColor: UIColor(red: 0.663, green: 0.686, blue: 0.733, alpha: 1))
    
    /// The colors of block-style buttons for primary actions, usually an accent color.
    public var buttonPrimary = ASAPPButtonColors(backgroundColor: UIColor.ASAPP.eggplant)
    
    /// The colors of block-style buttons for secondary actions like cancelling, usually a muted color.
    public var buttonSecondary = ASAPPButtonColors(backgroundColor: .clear, textColor: UIColor.ASAPP.eggplant, border: UIColor.ASAPP.eggplant)
    
    /// The color of the drop shadow for text in certain buttons.
    public var textShadow = UIColor(red: 0.12, green: 0.13, blue: 0.58, alpha: 1)
    
    // MARK: - Chat: Messages
    
    internal let messagesListGradientColors = [UIColor(red: 0.988, green: 0.988, blue: 0.988, alpha: 1), UIColor(red: 0.965, green: 0.965, blue: 0.973, alpha: 1)]
    
    internal let attachmentGradientColors = [UIColor(red: 0.988, green: 0.988, blue: 0.988, alpha: 1), UIColor(red: 0.965, green: 0.965, blue: 0.973, alpha: 1)]
    
    internal let messageButtonBackground = UIColor(red: 0.976, green: 0.976, blue: 0.98, alpha: 1)
    
    /// The color of chat message text.
    public var messageText = UIColor.white
    
    /// The color of the background of chat messages sent by the user.
    public var messageBackground = UIColor.ASAPP.eggplant
    
    /// The color of the border of chat messages sent by the user.
    public var messageBorder: UIColor?
    
    /// The color of chat message reply text.
    public var replyMessageText = UIColor.ASAPP.purpleHaze
    
    /// The color of the background of chat message replies.
    public var replyMessageBackground = UIColor.ASAPP.purpleHaze.withAlphaComponent(0.15)
    
    /// The color of the border of chat message replies.
    public var replyMessageBorder = UIColor.ASAPP.purpleHaze.withAlphaComponent(0.15)
    
    // MARK: - Chat: Quick Replies
    
    /// The colors of quick reply buttons.
    public var quickReplyButton = ASAPPButtonColors(
        backgroundNormal: UIColor.white.withAlphaComponent(0.2),
        backgroundHighlighted: UIColor.ASAPP.eggplant,
        backgroundDisabled: UIColor.white.withAlphaComponent(0.2),
        textNormal: UIColor.ASAPP.eggplant,
        textHighlighted: .white,
        textDisabled: UIColor.ASAPP.eggplant,
        border: UIColor.ASAPP.eggplant)
    
    /// The colors of action buttons.
    public var actionButton = ASAPPButtonColors(
        backgroundColor: UIColor.ASAPP.eggplant,
        textColor: .white,
        border: UIColor.ASAPP.eggplant)
    
    // MARK: - Chat: Input
    
    /// The colors of the chat input text area.
    public var chatInput = ASAPPInputColors(
        background: UIColor.white.withAlphaComponent(0.7),
        text: UIColor.ASAPP.purpleHaze.withAlphaComponent(0.9),
        placeholderText: UIColor.ASAPP.purpleHaze.withAlphaComponent(0.5),
        tint: UIColor.ASAPP.eggplant,
        border: UIColor.ASAPP.purpleHaze.withAlphaComponent(0.15),
        primaryButton: UIColor.ASAPP.eggplant,
        secondaryButton: UIColor.ASAPP.eggplant)
    
    // MARK: - ASAPPButton
    
    /// The color of text in an `ASAPPButton`.
    public var helpButtonText = UIColor.white
    
    /// The color of the background of an `ASAPPButton`.
    public var helpButtonBackground = UIColor(red: 0.374, green: 0.392, blue: 0.434, alpha: 1)
}

extension ASAPPColors {
    func updateColors(primary: UIColor, dark: UIColor) {
        ASAPP.styles.textStyles.updateColors(with: dark)
        
        navBarButtonActive = primary
        messageBackground = primary
        navBarTitle = dark.withAlphaComponent(0.85)
        navBarButton = dark.withAlphaComponent(0.9)
        textSecondary = dark
        separatorSecondary = dark.withAlphaComponent(0.15)
        replyMessageText = dark
        replyMessageBackground = dark.withAlphaComponent(0.15)
        replyMessageBorder = dark.withAlphaComponent(0.15)
        
        textButtonPrimary = ASAPPButtonColors(textColor: primary)
        buttonPrimary = ASAPPButtonColors(backgroundColor: primary)
        buttonSecondary = ASAPPButtonColors(backgroundColor: .clear, textColor: primary, border: primary)
        quickReplyButton = ASAPPButtonColors(
            backgroundNormal: UIColor.white.withAlphaComponent(0.2),
            backgroundHighlighted: primary,
            backgroundDisabled: UIColor.white.withAlphaComponent(0.2),
            textNormal: primary,
            textHighlighted: .white,
            textDisabled: primary,
            border: primary)
        actionButton = ASAPPButtonColors(
            backgroundColor: primary,
            textColor: .white,
            border: primary)
        chatInput = ASAPPInputColors(
            background: UIColor.white.withAlphaComponent(0.7),
            text: dark.withAlphaComponent(0.9),
            placeholderText: dark.withAlphaComponent(0.5),
            tint: primary,
            border: dark.withAlphaComponent(0.15),
            primaryButton: primary,
            secondaryButton: primary)
    }
    
    func getButtonColors(for buttonType: ButtonType) -> ASAPPButtonColors {
        switch buttonType {
        case .primary: return ASAPP.styles.colors.buttonPrimary
        case .secondary: return ASAPP.styles.colors.buttonSecondary
        case .textPrimary: return ASAPP.styles.colors.textButtonPrimary
        case .textSecondary: return ASAPP.styles.colors.textButtonSecondary
        }
    }
}
