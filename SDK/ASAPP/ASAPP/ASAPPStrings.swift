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
@objcMembers
public class ASAPPStrings: NSObject {
    // MARK: General
    
    /// The text of an `ASAPPButton`.
    public var asappButton: String = ASAPPLocalizedString("HELP")
    
    /// The accessibility label for the close/back button.
    public var accessibilityClose: String = ASAPPLocalizedString("Close Help")
    
    // MARK: Predictive
    
    /// The title for the predictive view. Overridden by `ASAPPViews.predictiveTitle`. Defaults to `nil`.
    public var predictiveTitle: String?
    
    /// The text for the button that displays the chat view.
    public var predictiveBackToChatButton: String = ASAPPLocalizedString("HISTORY")
    
    /// The welcome text in the predictive view.
    public var predictiveWelcomeText: String = ASAPPLocalizedString("How can we help?")
    
    /// The text for the subheader displayed below the welcome text.
    public var predictiveOtherSuggestions: String = ASAPPLocalizedString("OTHER SUGGESTIONS:")
    
    /// The placeholder text for the input field of the predictive view.
    public var predictiveInputPlaceholder: String = ASAPPLocalizedString("Ask a new question...")
    
    /// The text for the send button of the predictive view.
    public var predictiveSendButton: String = ASAPPLocalizedString("SEND")
    
    /// The text displayed when no connection is available in the predictive view.
    public var predictiveNoConnectionText: String = ASAPPLocalizedString("PLEASE CHECK YOUR CONNECTION...")

    // MARK: Connection Status Banner
    
    /// The text displayed in the chat view when a connection has been established.
    public var connectionBannerConnected: String = ASAPPLocalizedString("Connection Established")
    
    /// The text displayed in the chat view when a connection is being established.
    public var connectionBannerConnecting: String = ASAPPLocalizedString("Connecting...")
    
    /// The text displayed in the chat view when there is no connection available.
    public var connectionBannerDisconnected: String = ASAPPLocalizedString("Not connected. Retry connection?")
    
    // MARK: Chat Messages View
    
    /// The title for the chat view. Overridden by `ASAPPViews.chatTitle`. Defaults to `nil`.
    public var chatTitle: String?
    
    /// The text for the header displayed when there is no chat history.
    public var chatEmptyTitle: String = ASAPPLocalizedString("Hi there, how can we help you?")
    
    /// The text for the message displayed when there is no chat history.
    public var chatEmptyMessage: String = ASAPPLocalizedString("Tap 'ASK' to get started.")
    
    /// The text for the navigation bar button that appears in the chat view when not chatting with an agent. When tapped, it shows the predictive view. Overridden by `ASAPPNavBarButtonImages.ask`.
    public var chatAskNavBarButton: String = ASAPPLocalizedString("ASK")
    
    /// The text for the navigation bar button that appears in the chat view when chatting with an agent. When tapped, it ends the chat. Overridden by `ASAPPNavBarButtonImages.end`.
    public var chatEndChatNavBarButton: String = ASAPPLocalizedString("END CHAT")
    
    /// The placeholder text for the input field of the chat view.
    public var chatInputPlaceholder: String = ASAPPLocalizedString("Enter a message...")
    
    /// The text for the send button of the chat view.
    public var chatInputSend: String = ASAPPLocalizedString("SEND")
    
    // MARK: Generic
    
    /// The text displayed when the screen contents are hidden.
    public var secureScreenCoverText: String = ASAPPLocalizedString("View content hidden for security purposes.\n\nTap to dismiss.")
    
    /// The title displayed when a request fails to send.
    public var requestErrorGenericFailureTitle: String = ASAPPLocalizedString("Oops!")
    
    /// The text displayed when a request fails to send.
    public var requestErrorGenericFailure: String = ASAPPLocalizedString("We were unable to complete your request. Please try again later.")
    
    /// The text for the dismiss button of a generic error alert.
    public var alertDismissButton: String = ASAPPLocalizedString("Ok")
    
    /// The text displayed when a view could not load.
    public var failureToLoadScreen: String = ASAPPLocalizedString("Oops! We were unable to find what you're looking for. Please try again later.")
    
    /// The text for the retry button displayed when a view could not load.
    public var failureToLoadScreenReloadButton: String = ASAPPLocalizedString("Try Again")
    
    /// The text for the close button displayed when a view could not load.
    public var failureToLoadScreenCloseButton: String = ASAPPLocalizedString("Close")
    
    // MARK: Ending Chat
    
    /// The title for the alert displayed when ending chat.
    public var endChatConfirmationTitle: String = ASAPPLocalizedString("Are you sure?")
    
    /// The text for the alert displayed when ending chat.
    public var endChatConfirmationMessage: String = ASAPPLocalizedString("This will end your current conversation.")
    
    /// The text for the confirmation button of the end chat alert.
    public var endChatConfirmationEndChatButton: String = ASAPPLocalizedString("End Chat")
    
    /// The text for the cancel button of the end chat alert.
    public var endChatConfirmationCancelButton: String = ASAPPLocalizedString("Cancel")
    
    // Modal View: Feedback
    
    /// The title for the feedback form.
    public var feedbackViewTitle: String = ASAPPLocalizedString("How did we do?")
    
    /// The text prompting the user to indicate whether their issues was resolved.
    public var feedbackIssueResolutionPrompt: String = ASAPPLocalizedString("Was your issue resolved?")
    
    /// The text indicating that the issue was resolved.
    public var feedbackIssueResolutionYes: String = ASAPPLocalizedString("YES")
    
    /// The text indicating that the issue was not resolved.
    public var feedbackIssueResolutionNo: String = ASAPPLocalizedString("NO")
    
    /// The text prompting the user to leave feedback, shown as a placeholder in the text area.
    public var feedbackPrompt: String = ASAPPLocalizedString("Leave Feedback (optional)")
    
    /// The text displayed when a rating was no chosen.
    public var feedbackMissingRatingError: String = ASAPPLocalizedString("Please select a rating before submitting.")
    
    /// The text displayed when the rating was sent successfully.
    public var feedbackSentSuccessMessage: String = ASAPPLocalizedString("Rating successfully sent!")
    
    /// The text displayed when a request can't be sent because there is no connection available.
    public var requestErrorMessageNoConnection: String = ASAPPLocalizedString("Please check your connection and try again.")
    
    /// The text for the cancel button of the modal.
    public var modalViewCancelButton: String = ASAPPLocalizedString("CANCEL")
    
    /// The text for the submit button of the modal.
    public var modalViewSubmitButton: String = ASAPPLocalizedString("SUBMIT")
    
    /// :nodoc:
    public var modalViewDoneButton: String = ASAPPLocalizedString("DONE")
    
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
