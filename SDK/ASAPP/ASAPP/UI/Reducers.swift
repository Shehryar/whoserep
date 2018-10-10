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
                state.chatInputState = .empty
                state.animationState = .withoutAnimation
            } else if message.metadata.isReply {
                state.lastReply = message
                let showChatInput = current.isLiveChat || message.userCanTypeResponse == true
                if showChatInput && message.hasQuickReplies {
                    state.chatInputState = .both
                    state.animationState = .needsToAnimate
                } else if message.hasQuickReplies {
                    state.chatInputState = message.hideNewQuestionButton ? .quickRepliesAlone : .quickRepliesWithNewQuestion
                    state.animationState = .needsToAnimate
                } else if showChatInput {
                    state.chatInputState = current.isLiveChat ? .liveChat(keyboardIsVisible: true) : .chatInput(keyboardIsVisible: true)
                    state.lastReply = nil
                    state.animationState = chatInputChange.animated ? .needsToAnimate : .withoutAnimation
                } else if [EventType.conversationEnd, .conversationTimedOut].contains(message.metadata.eventType) || !message.hideNewQuestionButton {
                    state.chatInputState = .newQuestionAlone
                    state.animationState = current.chatInputState == .empty ? .withoutAnimation : .needsToAnimate
                } else {
                    state.chatInputState = .empty
                    state.animationState = chatInputChange.animated ? .needsToAnimate : .withoutAnimation
                }
                state.shouldConfirmRestart = !message.suppressNewQuestionConfirmation
            }
        case let autosuggestChange as FetchedSuggestions:
            state.autosuggestState = AutosuggestState(shouldShow: true, suggestions: autosuggestChange.suggestions, responseId: autosuggestChange.responseId)
            state.animationState = .withoutAnimation
        case _ as DidSelectSuggestion:
            state.autosuggestState.shouldShow = false
            state.animationState = .withoutAnimation
        case _ as DidBeginEditing:
            if !state.shouldShowActionSheet {
                if state.chatInputState == .both {
                    state.chatInputState = .prechat
                    state.animationState = .needsToAnimate
                } else {
                    state.chatInputState = current.chatInputState.withKeyboard
                    state.animationState = .withoutAnimation
                }
            }
        case _ as DidSelectQuickReply:
            state.chatInputState = .newQuestionWithInset
            state.animationState = .needsToAnimate
        case _ as NoReplies:
            state.chatInputState = .newQuestionAlone
            state.shouldConfirmRestart = false
            state.animationState = .needsToAnimate
        case let liveChatChange as DidChangeLiveChatStatus:
            state.isLiveChat = liveChatChange.isLiveChat
            if liveChatChange.updateInput && !state.shouldShowActionSheet {
                state.chatInputState = liveChatChange.isLiveChat ? .liveChat(keyboardIsVisible: true) : .newQuestionAlone
            }
            state.animationState = liveChatChange.updateInput ? .needsToAnimate : .withoutAnimation
        case _ as GatekeeperViewDidAppear:
            state.chatInputState = .newQuestionAlone
            state.animationState = .withoutAnimation
        case _ as KeyboardDidDisappear:
            state.chatInputState = current.chatInputState.withoutKeyboard
            state.animationState = .needsToAnimate
        case let actionSheetChange as ActionSheetChange:
            state.shouldShowActionSheet = actionSheetChange.isVisible
            if !actionSheetChange.isVisible && current.isLiveChat {
                state.chatInputState = .liveChat(keyboardIsVisible: true)
            }
            state.animationState = .withoutAnimation
        case _ as WillRestart:
            state.chatInputState = .newQuestionAloneLoading
            state.animationState = .needsToAnimate
        case _ as DidFailToRestart:
            state.chatInputState = .newQuestionAlone
            state.animationState = .needsToAnimate
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
            DebugLog.d("\(state.chatInputState)")
        }
        return state
    }
}
