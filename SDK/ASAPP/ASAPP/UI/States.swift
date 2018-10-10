//
//  States.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/28/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

struct UIState: StateType {
    var chatInputState: InputState = .empty
    var autosuggestState = AutosuggestState()
    var lastReply: ChatMessage?
    var shouldShowActionSheet: Bool = false
    var shouldConfirmRestart: Bool = true
    var animationState: AnimationState = .done
    var transitionCoordinator: UIViewControllerTransitionCoordinator?
    var transitionSize: CGSize?
    var isLiveChat: Bool = false
}

enum AnimationState {
    case withoutAnimation
    case needsToAnimate
    case done
}

enum InputState {
    case both
    case chatInput(keyboardIsVisible: Bool)
    case empty
    case liveChat(keyboardIsVisible: Bool)
    case prechat
    case newQuestionAlone
    case newQuestionWithInset
    case newQuestionAloneLoading
    case quickRepliesAlone
    case quickRepliesWithNewQuestion
    
    var withoutKeyboard: InputState {
        switch self {
        case .prechat:
            return .both
        case .chatInput:
            return .chatInput(keyboardIsVisible: false)
        case .liveChat:
            return .liveChat(keyboardIsVisible: false)
        default:
            return self
        }
    }
    
    var withKeyboard: InputState {
        switch self {
        case .both:
            return .prechat
        case .chatInput:
            return .chatInput(keyboardIsVisible: true)
        case .liveChat:
            return .liveChat(keyboardIsVisible: true)
        default:
            return self
        }
    }
    
    var isLiveChat: Bool {
        if case .liveChat = self {
            return true
        } else {
            return false
        }
    }
}

struct AutosuggestState: StateType {
    var shouldShow: Bool = false
    var suggestions: [String] = []
    var responseId: AutosuggestMetadata.ResponseId = ""
}

extension InputState: Equatable {}

func == (lhs: InputState, rhs: InputState) -> Bool {
    switch lhs {
    case .both:
        if case .both = rhs { return true }
    case .chatInput:
        if case .chatInput = rhs { return true }
    case .empty:
        if case .empty = rhs { return true }
    case .liveChat:
        if case .liveChat = rhs { return true }
    case .prechat:
        if case .prechat = rhs { return true }
    case .newQuestionAlone:
        if case .newQuestionAlone = rhs { return true }
    case .newQuestionWithInset:
        if case .newQuestionWithInset = rhs { return true }
    case .newQuestionAloneLoading:
        if case .newQuestionAloneLoading = rhs { return true }
    case .quickRepliesAlone:
        if case .quickRepliesAlone = rhs { return true }
    case .quickRepliesWithNewQuestion:
        if case .quickRepliesWithNewQuestion = rhs { return true }
    }
    
    return false
}
