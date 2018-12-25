//
//  ConversationManager+OutgoingAPI.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/15/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK: - Chat

extension ConversationManager {
    @discardableResult
    func endLiveChat() -> Bool {
        guard isConnected(retryConnectionIfNeeded: true) else {
            return false
        }
        
        sendRequest(path: "customer/EndConversation")
        
        return true
    }
}

// MARK: - SRS

extension ConversationManager {
    func sendEnterChatRequest(_ completion: (() -> Void)? = nil) {
        var params: [String: Any] = [:]
        
        if let string = pushNotificationPayload?["ProactiveTrigger"] as? String,
           let proactiveTrigger = string.toJSONObject() {
            params["ProactiveTrigger"] = proactiveTrigger
        }
        
        if let intentPayload = intentPayload {
            params["Intent"] = intentPayload
        }
        
        let handler: RequestResponseHandler = { [weak self] _ in
            self?.pushNotificationPayload = nil
            self?.intentPayload = nil
            completion?()
        }
        
        sendRequest(path: "customer/enterChat", params: params, completion: handler)
    }
    
    func sendAskRequest(intent: [String: Any]? = nil, _ completion: ((_ success: Bool) -> Void)? = nil) {
        var params: [String: Any] = [:]
        
        let handler: RequestResponseHandler = { message in
            let success = message.type != MessageType.responseError
            completion?(success)
        }
        
        if let intentPayload = intent {
            params["Intent"] = intentPayload
        }
        
        sendRequest(path: "customer/ask", params: params, completion: handler)
    }
}

// MARK: - Proactive Messaging

extension ConversationManager {
    func sendAcceptRequest(action: Action) {
        guard
            let data = action.data,
            let triggerUuid = data.string(for: "triggerUuid")
        else {
            return
        }
        
        let params = ["ProactiveTriggerUuid": triggerUuid]
        
        sendRequest(path: "customer/proactive/AcceptOfferedMessage", params: params)
    }
    
    func sendDismissRequest(action: Action) {
        guard
            let data = action.data,
            let triggerUuid = data.string(for: "triggerUuid")
        else {
            return
        }
        
        let params = ["ProactiveTriggerUuid": triggerUuid]
        
        sendRequest(path: "customer/proactive/DismissOfferedMessage", params: params)
    }
}
