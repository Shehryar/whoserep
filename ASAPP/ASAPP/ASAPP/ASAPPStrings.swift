//
//  ASAPPStrings.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

func ASAPPLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, tableName: nil, bundle: ASAPPBundle, comment: "")
}

public class ASAPPStrings: NSObject {
    public var asappButton: String = ASAPPLocalizedString("HELP")
    public var accessibilityClose: String = ASAPPLocalizedString("Close Help")
    
    // Predictive
    
    public var predictiveBackToChatButton: String = ASAPPLocalizedString("HISTORY")
    public var predictiveWelcomeText: String = ASAPPLocalizedString("How can we help?")
    public var predictiveOtherSuggestions: String = ASAPPLocalizedString("OTHER SUGGESTIONS:")
    public var predictiveInputPlaceholder: String = ASAPPLocalizedString("Ask a new question...")
    public var predictiveSendButton: String = ASAPPLocalizedString("SEND")
    public var predictiveNoConnectionText: String = ASAPPLocalizedString("PLEASE CHECK YOUR CONNECTION...")

    // Connection Status Banner
    
    public var connectionBannerConnected: String = ASAPPLocalizedString("Connection Established")
    public var connectionBannerConnecting: String = ASAPPLocalizedString("Connecting...")
    public var connectionBannerDisconnected: String = ASAPPLocalizedString("Not connected. Retry connection?")
    
    // Chat Messages View
    
    public var chatEmptyTitle: String = ASAPPLocalizedString("Hi there, how can we help you?")
    public var chatEmptyMessage: String = ASAPPLocalizedString("Tap 'ASK' to get started.")
    public var chatAskNavBarButton: String = ASAPPLocalizedString("ASK")
    public var chatAskTooltip: String = ASAPPLocalizedString("Tap 'ASK' to ask a new question.")
    public var chatInputPlaceholder: String = ASAPPLocalizedString("Enter a message...")
    public var chatInputSend: String = ASAPPLocalizedString("SEND")
    
    // Modal View
    
    public var modalViewCancelButton: String = ASAPPLocalizedString("CANCEL")
    public var modalViewSubmitButton: String = ASAPPLocalizedString("SUBMIT")
    public var modalViewDoneButton: String = ASAPPLocalizedString("DONE")
 
    // Modal View: Credit Card
    
    public var creditCardViewTitle: String = ASAPPLocalizedString("Add a New Card")
    public var creditCardPlaceholderName: String = ASAPPLocalizedString("NAME ON CARD")
    public var creditCardPlaceholderNumber: String = ASAPPLocalizedString("CARD NUMBER")
    public var creditCardPlaceholderExpiry: String = ASAPPLocalizedString("EXP DATE (MM/YY)")
    public var creditCardPlaceholderCVV: String = ASAPPLocalizedString("SECURITY CODE")
    public var creditCardNoConnectionError: String = ASAPPLocalizedString("Please check your connection and try again.")
    public var creditCardInvalidFieldsError: String = ASAPPLocalizedString("Please check that your information is correct and try again.")
    public var creditCardDefaultError: String = ASAPPLocalizedString("Unable to process your request at this time.")
    public var creditCardConfirmButton: String = ASAPPLocalizedString("CONFIRM")
    public var creditCardFinishButton: String = ASAPPLocalizedString("FINISH")
    public var creditCardSuccessText: String = ASAPPLocalizedString("New Card Added Successfully!")
    
    // Modal View: Feedback
    
    public var feedbackViewTitle: String = ASAPPLocalizedString("How did we do?")
    public var feedbackSubmitButton: String = ASAPPLocalizedString("SUBMIT")
    public var feedbackDoneButton: String = ASAPPLocalizedString("DONE")
    public var feedbackMissingRatingError: String = ASAPPLocalizedString("Please select a rating before submitting.")
    public var feedbackSentSuccessMessage: String = ASAPPLocalizedString("Rating successfully sent!")
    
    // Generic
    
    public var reqeustErrorMessageNoConnection: String = ASAPPLocalizedString("Please check your connection and try again.")
    public var requestErrorGenericFailure: String = ASAPPLocalizedString("We were unable to complete your request. Please try again later.")
}