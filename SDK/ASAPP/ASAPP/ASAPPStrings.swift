//
//  ASAPPStrings.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

func ASAPPLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, tableName: nil, bundle: ASAPP.bundle, comment: "")
}

/**
 Customizable strings for various parts of the UI.
 */
@objc(ASAPPStrings)
@objcMembers
public class ASAPPStrings: NSObject {
    // MARK: General
    
    /// The text of an `ASAPPButton`.
    public var asappButton = ASAPPLocalizedString("HELP")
    
    /// The accessibility label for the close/back button.
    public var accessibilityClose = ASAPPLocalizedString("Close Help")
    
    /// The accessibility label for the send button.
    public var accessibilitySend = ASAPPLocalizedString("Send")

    // MARK: Connection Status Banner
    
    /// The text displayed in the chat view when a connection has been established.
    public var connectionBannerConnected = ASAPPLocalizedString("Connection Established")
    
    /// The text displayed in the chat view when a connection is being established.
    public var connectionBannerConnecting = ASAPPLocalizedString("Connecting...")
    
    /// The text displayed in the chat view when there is no connection available.
    public var connectionBannerDisconnected = ASAPPLocalizedString("Not connected. Retry connection?")
    
    // MARK: Chat Messages View
    
    /// The title for the chat view. Overridden by `ASAPPViews.chatTitle`. Defaults to `nil`.
    public var chatTitle: String?
    
    /// The text for the navigation bar button that appears in the chat view when chatting with an agent. When tapped, it ends the chat. Overridden by `ASAPPNavBarButtonImages.end`.
    public var chatEndChatNavBarButton = ASAPPLocalizedString("END CHAT")
    
    /// The placeholder text for the input field of the chat view.
    public var chatInputPlaceholder = ASAPPLocalizedString("Type your own question here")
    
    /// The text for the restart button in the quick replies view.
    public var quickRepliesRestartButton = ASAPPLocalizedString("New Question")
    
    // MARK: Generic
    
    /// The text displayed when the screen contents are hidden.
    public var secureScreenCoverText = ASAPPLocalizedString("View content hidden for security purposes.\n\nTap to dismiss.")
    
    /// The title displayed when a request fails to send.
    public var requestErrorGenericFailureTitle = ASAPPLocalizedString("Oops!")
    
    /// The text displayed when a request fails to send.
    public var requestErrorGenericFailure = ASAPPLocalizedString("We were unable to complete your request. Please try again later.")
    
    /// The text for the dismiss button of a generic error alert.
    public var alertDismissButton = ASAPPLocalizedString("Ok")
    
    /// The text displayed when a view could not load.
    public var failureToLoadScreen = ASAPPLocalizedString("Oops! We were unable to find what you're looking for. Please try again later.")
    
    /// The text for the retry button displayed when a view could not load.
    public var failureToLoadScreenReloadButton = ASAPPLocalizedString("Try Again")
    
    /// The text for the close button displayed when a view could not load.
    public var failureToLoadScreenCloseButton = ASAPPLocalizedString("Close")
    
    /// The text displayed next to a required form field that was left empty.
    public var requiredFieldEmptyMessage = ASAPPLocalizedString("Required field")
    
    // MARK: Restart confirmation action sheet
    
    /// The text for the quick reply button displayed at the end of a chat session.
    public var restartActionButton = ASAPPLocalizedString("Ask a new question")
    
    /// The title for the alert displayed when ending chat.
    public var restartConfirmationTitle = ASAPPLocalizedString("Ask a new question")
    
    /// The text for the alert displayed when ending chat.
    public var restartConfirmationBody = ASAPPLocalizedString("Are you sure you want to end the current conversation and return to the beginning?")
    
    /// The text for the confirmation button of the end chat alert.
    public var restartConfirmationRestartButton = ASAPPLocalizedString("I want to start over")
    
    /// The text for the cancel button of the end chat alert.
    public var restartConfirmationHideButton = ASAPPLocalizedString("Cancel")
    
    // MARK: Modal View: Feedback
    
    /// The title for the feedback form.
    public var feedbackViewTitle = ASAPPLocalizedString("How did we do?")
    
    /// The text prompting the user to indicate whether their issues was resolved.
    public var feedbackIssueResolutionPrompt = ASAPPLocalizedString("Was your issue resolved?")
    
    /// The text indicating that the issue was resolved.
    public var feedbackIssueResolutionYes = ASAPPLocalizedString("YES")
    
    /// The text indicating that the issue was not resolved.
    public var feedbackIssueResolutionNo = ASAPPLocalizedString("NO")
    
    /// The text prompting the user to leave feedback, shown as a placeholder in the text area.
    public var feedbackPrompt = ASAPPLocalizedString("Leave Feedback (optional)")
    
    /// The text displayed when a rating was no chosen.
    public var feedbackMissingRatingError = ASAPPLocalizedString("Please select a rating before submitting.")
    
    /// The text displayed when the rating was sent successfully.
    public var feedbackSentSuccessMessage = ASAPPLocalizedString("Rating successfully sent!")
    
    /// The text displayed when a request can't be sent because there is no connection available.
    public var requestErrorMessageNoConnection = ASAPPLocalizedString("Please check your connection and try again.")
    
    /// The text for the cancel button of the modal.
    public var modalViewCancelButton = ASAPPLocalizedString("CANCEL")
    
    /// The text for the submit button of the modal.
    public var modalViewSubmitButton = ASAPPLocalizedString("SUBMIT")
    
    /// :nodoc:
    public var modalViewDoneButton = ASAPPLocalizedString("DONE")
    
    // MARK: Camera Permissions
    
    /// The title of the alert shown when camera permission is not granted.
    public var cameraPermissionsErrorTitle = ASAPPLocalizedString("Oops!")
    
    /// The text of the alert shown when camera permission is not granted.
    public var cameraPermissionsErrorMessage = ASAPPLocalizedString("You will need to enable the camera permission from the settings screen before using this feature.")
    
    /// The text for the cancel button of the alert shown when camera permission is not granted.
    public var cameraPermissionsErrorCancelButton = ASAPPLocalizedString("Cancel")
    
    /// The text for the go-to-settings button of the alert shown when camera permission is not granted.
    public var cameraPermissionsErrorSettingsButton = ASAPPLocalizedString("Settings")
}
