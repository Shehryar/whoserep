//
//  Reducers.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 10/2/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

class Reducers {
    static func reduceUIState(_ change: Change, state: UIState?) -> UIState {
        let current = state ?? UIState()
        var state = current
        state.queryUI.autosuggest = AutosuggestState()
        
        switch change {
        case let chatInputChange as MessageReceived:
            let message = chatInputChange.message
            DebugLog.d(message.metadata.isReply ? "> RECEIVED:" : "< SENT:", message.text ?? "nil")
            
            if current.shouldShowActionSheet {
                state.queryUI.input = .empty
                state.animation = .withoutAnimation
            } else if message.metadata.isReply {
                state.lastReply = message
                let showChatInput = current.isLiveChat || message.userCanTypeResponse == true
                if showChatInput && message.hasQuickReplies {
                    state.queryUI.input = .chatInputWithQuickReplies
                    state.animation = .needsToAnimate
                } else if message.hasQuickReplies {
                    state.queryUI.input = message.hideNewQuestionButton ? .quickRepliesAlone : .quickRepliesWithNewQuestion
                    state.animation = .needsToAnimate
                } else if showChatInput {
                    state.queryUI.input = current.isLiveChat ? .liveChat(keyboardIsVisible: true) : .chatInput(keyboardIsVisible: true)
                    state.lastReply = nil
                    state.animation = chatInputChange.animated ? .needsToAnimate : .withoutAnimation
                } else if [EventType.conversationEnd, .conversationTimedOut].contains(message.metadata.eventType) {
                    state.queryUI.input = .newQuestionAlone
                    state.animation = current.queryUI.input == .empty ? .withoutAnimation : .needsToAnimate
                } else if !message.hideNewQuestionButton && current.queryUI.input != .newQuestionWithInset {
                    state.queryUI.input = .inset
                    state.animation = current.queryUI.input == .empty ? .withoutAnimation : .needsToAnimate
                } else if current.queryUI.input != .newQuestionWithInset {
                    state.queryUI.input = .empty
                    state.animation = chatInputChange.animated ? .needsToAnimate : .withoutAnimation
                }
                state.queryUI.shouldConfirmRestart = !message.suppressNewQuestionConfirmation
            }
        case let autosuggestChange as FetchedSuggestions:
            if !current.queryUI.text.isEmpty {
                state.queryUI.autosuggest = AutosuggestState(shouldShow: true, suggestions: autosuggestChange.suggestions, responseId: autosuggestChange.responseId)
                state.animation = .withoutAnimation
            }
        case let textChange as DidUpdateChatInputText:
            state.queryUI.text = textChange.text
            if textChange.text.isEmpty {
                state.queryUI.autosuggest = AutosuggestState()
                state.animation = .needsToAnimate
            } else {
                state.queryUI.autosuggest = current.queryUI.autosuggest
            }
        case _ as DidSelectSuggestion:
            state.queryUI.autosuggest.shouldShow = false
            state.animation = .withoutAnimation
        case _ as DidBeginEditing:
            if !state.shouldShowActionSheet {
                if state.queryUI.input == .chatInputWithQuickReplies {
                    state.queryUI.input = .prechat
                    state.animation = .needsToAnimate
                } else {
                    state.queryUI.input = current.queryUI.input.withKeyboard
                    state.animation = .withoutAnimation
                }
            }
        case _ as DidSelectQuickReply:
            state.queryUI.input = .inset
            state.animation = .needsToAnimate
        case _ as NoReplies:
            state.queryUI.input = .newQuestionAlone
            state.queryUI.shouldConfirmRestart = false
            state.animation = .needsToAnimate
        case let liveChatChange as DidChangeLiveChatStatus:
            state.isLiveChat = liveChatChange.isLiveChat
            if liveChatChange.updateInput && !state.shouldShowActionSheet {
                state.queryUI.input = liveChatChange.isLiveChat ? .liveChat(keyboardIsVisible: true) : .newQuestionAlone
            }
            state.animation = liveChatChange.updateInput ? .needsToAnimate : .withoutAnimation
        case _ as GatekeeperViewDidAppear:
            state.queryUI.input = .newQuestionAlone
            state.animation = .withoutAnimation
        case _ as KeyboardDidDisappear:
            state.queryUI.input = current.queryUI.input.withoutKeyboard
            state.animation = .needsToAnimate
        case let actionSheetChange as ActionSheetChange:
            state.shouldShowActionSheet = actionSheetChange.isVisible
            if !actionSheetChange.isVisible && current.isLiveChat {
                state.queryUI.input = .liveChat(keyboardIsVisible: true)
            }
            state.animation = .withoutAnimation
        case _ as WillRestart:
            state.queryUI.input = .newQuestionAloneLoading
            state.animation = .needsToAnimate
        case _ as DidFailToRestart:
            state.queryUI.input = .newQuestionAlone
            state.animation = .needsToAnimate
        case _ as DidWaitInInsetState:
            if current.queryUI.input == .inset {
                state.queryUI.input = .newQuestionWithInset
                state.animation = .needsToAnimate
            }
        case let transition as WillTransition:
            state.transitionCoordinator = transition.coordinator
            state.transitionSize = transition.size
            state.animation = .withoutAnimation
        case _ as DidTransition:
            state.transitionCoordinator = nil
            state.transitionSize = nil
            state.animation = .withoutAnimation
        case _ as AnimationEnded:
            state.animation = .done
        default: break
        }
        
        DebugLog.d("\(change)")
        if !(change is AnimationEnded) {
            DebugLog.d("\(state.queryUI.input)")
        }
        return state
    }
}
