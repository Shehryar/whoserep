//
//  States.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/28/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

struct UIState: StateType {
    var queryUI = QueryUIState()
    var lastReply: ChatMessage?
    var shouldShowActionSheet: Bool = false
    var animation: AnimationState = .done
    var transitionCoordinator: UIViewControllerTransitionCoordinator?
    var transitionSize: CGSize?
    var isLiveChat: Bool = false
}

enum AnimationState {
    case withoutAnimation
    case needsToAnimate
    case done
}

struct QueryUIState: StateType {
    var input: InputState = .empty
    var autosuggest = AutosuggestState()
    var text: String = ""
    var shouldConfirmRestart: Bool = true
}

enum InputState: CaseIterable {
    typealias AllCases = [InputState]
    
    case chatInputWithQuickReplies
    case chatInput(keyboardIsVisible: Bool)
    case empty
    case prechat
    case newQuestionAlone
    case newQuestionWithInset
    case newQuestionAloneLoading
    case inset
    case quickRepliesAlone
    case quickRepliesWithNewQuestion
    
    var withoutKeyboard: InputState {
        switch self {
        case .prechat:
            return .chatInputWithQuickReplies
        case .chatInput:
            return .chatInput(keyboardIsVisible: false)
        default:
            return self
        }
    }
    
    var withKeyboard: InputState {
        switch self {
        case .chatInputWithQuickReplies:
            return .prechat
        case .chatInput:
            return .chatInput(keyboardIsVisible: true)
        default:
            return self
        }
    }
    
    var hasRestartButton: Bool {
        return [.newQuestionWithInset, .newQuestionAlone,
                .newQuestionAloneLoading, .quickRepliesWithNewQuestion].contains(self)
    }
    
    var isEmpty: Bool {
        return [.empty, .prechat, .chatInput(keyboardIsVisible: true), .chatInput(keyboardIsVisible: false), .inset].contains(self)
    }
    
    static var allCases: AllCases {
        return [.chatInputWithQuickReplies, .chatInput(keyboardIsVisible: true), .chatInput(keyboardIsVisible: false), .empty, .prechat, .newQuestionAlone, .newQuestionWithInset, .newQuestionAloneLoading, .inset, .quickRepliesAlone, .quickRepliesWithNewQuestion]
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
    case .chatInputWithQuickReplies:
        if case .chatInputWithQuickReplies = rhs { return true }
    case .chatInput:
        if case .chatInput = rhs { return true }
    case .empty:
        if case .empty = rhs { return true }
    case .prechat:
        if case .prechat = rhs { return true }
    case .newQuestionAlone:
        if case .newQuestionAlone = rhs { return true }
    case .newQuestionWithInset:
        if case .newQuestionWithInset = rhs { return true }
    case .newQuestionAloneLoading:
        if case .newQuestionAloneLoading = rhs { return true }
    case .inset:
        if case .inset = rhs { return true }
    case .quickRepliesAlone:
        if case .quickRepliesAlone = rhs { return true }
    case .quickRepliesWithNewQuestion:
        if case .quickRepliesWithNewQuestion = rhs { return true }
    }
    
    return false
}
