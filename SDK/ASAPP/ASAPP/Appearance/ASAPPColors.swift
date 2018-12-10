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
    
    /// :nodoc:
    public var iconTint = UIColor.ASAPP.eggplant
    
    // MARK: - Chat: Navigation Bar
    
    /// The background color of the navigation bar.
    public var navBarBackground: UIColor?
    
    /// The color of the navigation bar title text.
    public var navBarTitle = UIColor.ASAPP.purpleHaze.withAlphaComponent(0.85)
    
    /// The color of navigation bar buttons in the chat view, as well as the color of the close/back button.
    public var navBarButton = UIColor.ASAPP.purpleHaze.withAlphaComponent(0.9)
    
    /// The color of navigation bar buttons while tapped.
    public var navBarButtonActive = UIColor.ASAPP.eggplant
    
    // MARK: - Chat: General Content
    
    /// The color of the background of most elements.
    public var backgroundPrimary = UIColor.white
    
    /// The color of the background of image views, tabs, and other secondary elements.
    public var backgroundSecondary = UIColor(red: 0.972, green: 0.969, blue: 0.968, alpha: 1)
    
    /// Deprecated. The color of most text in inputs.
    @available(*, deprecated, message: "This color now depends on `ASAPP.styles.colors.dark` and will be removed in a future version.")
    public var textPrimary = UIColor.ASAPP.purpleHaze
    
    /// Deprecated. The color of secondary text, such as timestamp labels.
    @available(*, deprecated, message: "This color now depends on `ASAPP.styles.colors.dark` and will be removed in a future version.")
    public var textSecondary = UIColor.ASAPP.purpleHaze
    
    /// The color of most separators.
    public var separatorPrimary = UIColor(red: 0.86, green: 0.87, blue: 0.88, alpha: 1)
    
    /// The color of secondary separators, such as the borders of checkboxes and tabs.
    public var separatorSecondary = UIColor.ASAPP.purpleHaze.withAlphaComponent(0.15)
    
    /// The color of the active portion of controls, such as checkboxes, progress bars, radio buttons, sliders, and tabs.
    public var controlTint = UIColor.ASAPP.eggplant
    
    /// The color of the secondary portion of some controls, such as the background of progress bars and the underline of text inputs.
    public var controlSecondary = UIColor.ASAPP.purpleHaze.withAlphaComponent(0.15)
    
    /// The color of the background of checkboxes and radio buttons.
    public var controlBackground = UIColor.ASAPP.purpleHaze.withAlphaComponent(0.07)
    
    /// The default color of the background of a selected button representing a positive choice (such as in a BinaryRatingView).
    public var positiveSelectedBackground = UIColor.ASAPP.successGreen
    
    /// The default color of the background of a selected button representing a negative choice (such as in a BinaryRatingView).
    public var negativeSelectedBackground = UIColor.ASAPP.errorRed
    
    /// The color of the connection status view's background while disconnected.
    public var warning = UIColor.ASAPP.errorRed
    
    // MARK: - Chat: Buttons
    
    /// The color of text buttons, usually an accent color.
    public var textButtonPrimary = ASAPPButtonColors(textColor: UIColor.ASAPP.eggplant)
    
    /// The colors of block-style buttons for primary actions, usually an accent color.
    public var buttonPrimary = ASAPPButtonColors(backgroundColor: UIColor.ASAPP.eggplant)
    
    /// The colors of block-style buttons for secondary actions like cancelling, usually a muted color.
    public var buttonSecondary = ASAPPButtonColors(backgroundColor: .clear, textColor: UIColor.ASAPP.eggplant, border: UIColor.ASAPP.eggplant)
    
    /// The color of the drop shadow for text in certain buttons.
    public var textShadow = UIColor(red: 0.12, green: 0.13, blue: 0.58, alpha: 1)
    
    // MARK: - Chat: Messages
    
    /// The list of colors for the messages list's background gradient.
    public var messagesListGradientColors = [UIColor.ASAPP.snow, UIColor.ASAPP.ash]
    
    internal let attachmentGradientColors = [UIColor.ASAPP.snow, UIColor.ASAPP.ash]
    
    internal let messageButtonBackground = UIColor.white
    
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
}

extension ASAPPColors {
    func updateColors(primary: UIColor, dark: UIColor) {
        iconTint = primary
        navBarButtonActive = primary
        messageBackground = primary
        navBarTitle = dark.withAlphaComponent(0.85)
        navBarButton = dark.withAlphaComponent(0.9)
        separatorSecondary = dark.withAlphaComponent(0.15)
        controlTint = primary
        controlSecondary = dark.withAlphaComponent(0.15)
        controlBackground = dark.withAlphaComponent(0.07)
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
    
    func getButtonColors(for buttonType: ComponentButtonType) -> ASAPPButtonColors {
        switch buttonType {
        case .primary: return ASAPP.styles.colors.buttonPrimary
        case .secondary: return ASAPP.styles.colors.buttonSecondary
        case .textPrimary: return ASAPP.styles.colors.textButtonPrimary
        }
    }
}
