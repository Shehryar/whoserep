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
        state.autosuggestState = AutosuggestState()
        
        switch change {
        case let chatInputChange as MessageReceived:
            let message = chatInputChange.message
            DebugLog.d(message.metadata.isReply ? "> RECEIVED:" : "< SENT:", message.text ?? "nil")
            
            if current.shouldShowActionSheet {
                state.inputState = .empty
                state.animationState = .withoutAnimation
            } else if message.metadata.isReply {
                state.lastReply = message
                let showChatInput = current.isLiveChat || message.userCanTypeResponse == true
                if showChatInput && message.hasQuickReplies {
                    state.inputState = .chatInputWithQuickReplies
                    state.animationState = .needsToAnimate
                } else if message.hasQuickReplies {
                    state.inputState = message.hideNewQuestionButton ? .quickRepliesAlone : .quickRepliesWithNewQuestion
                    state.animationState = .needsToAnimate
                } else if showChatInput {
                    state.inputState = current.isLiveChat ? .liveChat(keyboardIsVisible: true) : .chatInput(keyboardIsVisible: true)
                    state.lastReply = nil
                    state.animationState = chatInputChange.animated ? .needsToAnimate : .withoutAnimation
                } else if [EventType.conversationEnd, .conversationTimedOut].contains(message.metadata.eventType) {
                    state.inputState = .newQuestionAlone
                    state.animationState = current.inputState == .empty ? .withoutAnimation : .needsToAnimate
                } else if !message.hideNewQuestionButton {
                    state.inputState = .inset
                    state.animationState = current.inputState == .empty ? .withoutAnimation : .needsToAnimate
                } else {
                    state.inputState = .empty
                    state.animationState = chatInputChange.animated ? .needsToAnimate : .withoutAnimation
                }
                state.shouldConfirmRestart = !message.suppressNewQuestionConfirmation
            }
        case let autosuggestChange as FetchedSuggestions:
            state.autosuggestState = AutosuggestState(shouldShow: true, suggestions: autosuggestChange.suggestions, responseId: autosuggestChange.responseId)
            state.animationState = .withoutAnimation
        case _ as DidClearChatInput:
            state.animationState = .needsToAnimate
        case _ as DidSelectSuggestion:
            state.autosuggestState.shouldShow = false
            state.animationState = .withoutAnimation
        case _ as DidBeginEditing:
            if !state.shouldShowActionSheet {
                if state.inputState == .chatInputWithQuickReplies {
                    state.inputState = .prechat
                    state.animationState = .needsToAnimate
                } else {
                    state.inputState = current.inputState.withKeyboard
                    state.animationState = .withoutAnimation
                }
            }
        case _ as DidSelectQuickReply:
            state.inputState = .inset
            state.animationState = .needsToAnimate
        case _ as NoReplies:
            state.inputState = .newQuestionAlone
            state.shouldConfirmRestart = false
            state.animationState = .needsToAnimate
        case let liveChatChange as DidChangeLiveChatStatus:
            state.isLiveChat = liveChatChange.isLiveChat
            if liveChatChange.updateInput && !state.shouldShowActionSheet {
                state.inputState = liveChatChange.isLiveChat ? .liveChat(keyboardIsVisible: true) : .newQuestionAlone
            }
            state.animationState = liveChatChange.updateInput ? .needsToAnimate : .withoutAnimation
        case _ as GatekeeperViewDidAppear:
            state.inputState = .newQuestionAlone
            state.animationState = .withoutAnimation
        case _ as KeyboardDidDisappear:
            state.inputState = current.inputState.withoutKeyboard
            state.animationState = .needsToAnimate
        case let actionSheetChange as ActionSheetChange:
            state.shouldShowActionSheet = actionSheetChange.isVisible
            if !actionSheetChange.isVisible && current.isLiveChat {
                state.inputState = .liveChat(keyboardIsVisible: true)
            }
            state.animationState = .withoutAnimation
        case _ as WillRestart:
            state.inputState = .newQuestionAloneLoading
            state.animationState = .needsToAnimate
        case _ as DidFailToRestart:
            state.inputState = .newQuestionAlone
            state.animationState = .needsToAnimate
        case _ as DidWaitInInsetState:
            if current.inputState == .inset {
                state.inputState = .newQuestionWithInset
                state.animationState = .needsToAnimate
            }
        case let transition as WillTransition:
            state.transitionCoordinator = transition.coordinator
            state.transitionSize = transition.size
            state.animationState = .withoutAnimation
        case _ as DidTransition:
            state.transitionCoordinator = nil
            state.transitionSize = nil
            state.animationState = .withoutAnimation
        case _ as AnimationEnded:
            state.animationState = .done
        default: break
        }
        
        DebugLog.d("\(change)")
        if !(change is AnimationEnded) {
            DebugLog.d("\(state.inputState)")
        }
        return state
    }
}
