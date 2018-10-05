//
//  Changes.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 10/2/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation
import UIKit

struct MessageReceived: Change {
    let message: ChatMessage
    let animated: Bool
}

struct FetchedSuggestions: Change {
    let suggestions: [String]
    let responseId: AutosuggestMetadata.ResponseId
}

struct DidChangeLiveChatStatus: Change {
    let isLiveChat: Bool
    let updateInput: Bool
}

struct ActionSheetChange: Change {
    let isVisible: Bool
}

struct WillTransition: Change {
    let size: CGSize
    let coordinator: UIViewControllerTransitionCoordinator
}

struct DidSelectSuggestion: Change {}
struct DidBeginEditing: Change {}
struct DidSelectQuickReply: Change {}
struct NoReplies: Change {}
struct GatekeeperViewDidAppear: Change {}
struct KeyboardDidDisappear: Change {}
struct DidSendMessage: Change {}
struct DidTransition: Change {}
struct WillRestart: Change {}
struct DidFailToRestart: Change {}
struct AnimationEnded: Change {}
