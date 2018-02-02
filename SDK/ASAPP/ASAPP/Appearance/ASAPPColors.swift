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
@objcMembers
public class ASAPPColors: NSObject {
    
    // MARK: - Chat: Navigation Bar
    
    /// The background color of the navigation bar.
    public var navBarBackground = UIColor.white
    
    /// The color of the navigation bar title text.
    public var navBarTitle = UIColor(red: 57.0 / 255.0, green: 61.0 / 255.0, blue: 71.0 / 255.0, alpha: 0.95)
    
    /// The color of text in navigation bar buttons in the chat view with `ASAPPNavBarButtonStyle.text`, as well as the color of the close/back button.
    public var navBarButton = UIColor(red: 0.355, green: 0.394, blue: 0.494, alpha: 1)
    
    /// The color of text in navigation bar buttons with `ASAPPNavBarButtonStyle.bubble`.
    public var navBarButtonForeground = UIColor(red: 0.264, green: 0.278, blue: 0.316, alpha: 1)
    
    /// The color of the background in navigation bar buttons with `ASAPPNavBarButtonStyle.bubble`.
    public var navBarButtonBackground = UIColor(red: 0.866, green: 0.878, blue: 0.907, alpha: 1)
    
    // MARK: - Chat: General Content
    
    /// The color of the background of most elements.
    public var backgroundPrimary = UIColor.white
    
    /// The color of the background of image views, tabs, and other secondary elements.
    public var backgroundSecondary = UIColor(red: 0.972, green: 0.969, blue: 0.968, alpha: 1)
    
    /// The color of most text.
    public var textPrimary = UIColor(red: 57.0 / 255.0, green: 61.0 / 255.0, blue: 71.0 / 255.0, alpha: 1)
    
    /// The color of secondary text, such as timestamp labels.
    public var textSecondary = UIColor(red: 0.42, green: 0.43, blue: 0.45, alpha: 1)
    
    /// The color of most separators.
    public var separatorPrimary = UIColor(red: 0.59, green: 0.60, blue: 0.62, alpha: 1)
    
    /// The color of secondary separators, such as the borders of quick reply buttons, checkboxes, and tabs.
    public var separatorSecondary = UIColor(red: 0.816, green: 0.824, blue: 0.847, alpha: 0.5)
    
    /// The color of the active portion of controls, such as checkboxes, progress bars, radio buttons, sliders, and tabs.
    public var controlTint = UIColor(red: 0.075, green: 0.698, blue: 0.925, alpha: 1)
    
    /// The color of the secondary portion of some controls, such as the background of progress bars and the underline of text inputs.
    public var controlSecondary = UIColor(red: 0.898, green: 0.906, blue: 0.918, alpha: 1)
    
    /// The color of the background of selected checkboxes and radio buttons.
    public var controlSelectedBackground = UIColor(red: 0.953, green: 0.957, blue: 0.965, alpha: 1)
    
    /// The default color of the background of a selected button representing a positive choice (such as in a BinaryRatingView).
    public var positiveSelectedBackground = UIColor(red: 0.11, green: 0.65, blue: 0.43, alpha: 1)
    
    /// The default color of the background of a selected button representing a negative choice (such as in a BinaryRatingView).
    public var negativeSelectedBackground = UIColor(red: 0.82, green: 0.11, blue: 0.26, alpha: 1)
    
    // MARK: - Chat: Buttons
    
    /// The color of text buttons, usually an accent color.
    public var textButtonPrimary = ASAPPButtonColors(textColor: UIColor(red: 0.125, green: 0.714, blue: 0.931, alpha: 1))
    
    /// The color of secondary text buttons, usually a muted color.
    public var textButtonSecondary = ASAPPButtonColors(textColor: UIColor(red: 0.663, green: 0.686, blue: 0.733, alpha: 1))
    
    /// The colors of block-style buttons for primary actions, usually an accent color.
    public var buttonPrimary = ASAPPButtonColors(backgroundColor: UIColor(red: 0.204, green: 0.698, blue: 0.925, alpha: 1))
    
    /// The colors of block-style buttons for secondary actions like cancelling, usually a muted color.
    public var buttonSecondary = ASAPPButtonColors(
        backgroundNormal: UIColor(red: 0.953, green: 0.957, blue: 0.965, alpha: 1),
        backgroundHighlighted: UIColor(red: 0.903, green: 0.907, blue: 0.915, alpha: 1),
        backgroundDisabled: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1),
        textNormal: UIColor(red: 0.357, green: 0.396, blue: 0.494, alpha: 1.0),
        textHighlighted: UIColor(red: 0.357, green: 0.396, blue: 0.494, alpha: 1),
        textDisabled: UIColor(red: 0.357, green: 0.396, blue: 0.494, alpha: 0.8),
        border: UIColor(red: 0.886, green: 0.890, blue: 0.906, alpha: 1))
    
    // MARK: - Chat: Messages
    
    /// The color of the background of the chat messages view.
    public var messagesListBackground = UIColor.ASAPP.alabasterWhite
    
    /// The color of chat message text.
    public var messageText = UIColor(red: 0.476, green: 0.498, blue: 0.565, alpha: 1)
    
    /// The color of the background of chat messages sent by the user.
    public var messageBackground = UIColor.white
    
    /// The color of the border of chat messages sent by the user.
    public var messageBorder: UIColor? = UIColor(red: 0.86, green: 0.87, blue: 0.88, alpha: 1)
    
    /// The color of chat message reply text.
    public var replyMessageText = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    
    /// The color of the background of chat message replies.
    public var replyMessageBackground = UIColor.ASAPP.eggplant
    
    /// The color of the border of chat message replies.
    public var replyMessageBorder: UIColor?
    
    // MARK: - Chat: Quick Replies
    
    /// The color of the background of the quick replies list.
    public var quickRepliesBackground = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
    
    /// The colors of quick reply buttons.
    public var quickReplyButton = ASAPPButtonColors(
        backgroundColor: .white,
        textColor: UIColor(red: 0.18, green: 0.21, blue: 0.24, alpha: 1))
    
    /// The colors of action buttons.
    public var actionButton = ASAPPButtonColors(
        backgroundColor: .white,
        textColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1),
        border: UIColor(red: 0, green: 0.45, blue: 0.73, alpha: 1))
    
    // MARK: - Chat: Input
    
    /// The colors of the chat input text area.
    public var chatInput = ASAPPInputColors(
        background: UIColor.white,
        text: UIColor(red: 0.283, green: 0.290, blue: 0.307, alpha: 1),
        placeholderText: UIColor(red: 0.535, green: 0.557, blue: 0.586, alpha: 1),
        tint: UIColor(red: 0.682, green: 0.682, blue: 0.682, alpha: 1),
        border: UIColor(red: 0.937, green: 0.945, blue: 0.949, alpha: 1),
        primaryButton: UIColor(red: 0.476, green: 0.498, blue: 0.565, alpha: 1),
        secondaryButton: UIColor(red: 0.535, green: 0.557, blue: 0.586, alpha: 1))
    
    // MARK: - ASAPPButton
    
    /// The color of text in an `ASAPPButton`.
    public var helpButtonText = UIColor.white
    
    /// The color of the background of an `ASAPPButton`.
    public var helpButtonBackground = UIColor(red: 0.374, green: 0.392, blue: 0.434, alpha: 1)
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
