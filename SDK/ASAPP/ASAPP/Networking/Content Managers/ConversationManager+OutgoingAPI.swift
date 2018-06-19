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
    
    func sendUserTypingStatus(isTyping: Bool, with text: String?) {
        let path = "customer/NotifyTypingPreview"
        let params = [ "Text": text ?? "" ]
        sendRequest(path: path, params: params, requiresContext: false, completion: nil)
    }
    
    func sendTextMessage(_ message: String, completion: RequestResponseHandler? = nil) {
        let path = "customer/SendTextMessage"
        let params = ["Text": message]
        sendRequest(path: path, params: params, completion: completion)
    }
    
    func sendPictureMessage(_ image: UIImage, completion: (() -> Void)? = nil) {
        let path = "customer/SendPictureMessage"
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {
            DebugLog.e("Unable to get JPEG data for image: \(image)")
            return
        }
        let imageFileSize = imageData.count
        let params: [String: Any] = [
            "MimeType": "image/jpeg",
            "FileSize": imageFileSize,
            "PicWidth": image.size.width,
            "PicHeight": image.size.height
        ]
        
        httpClient.sendRequest(method: .POST, path: path, headers: nil, params: params, data: imageData) { (_: Data?, _, _) in
            completion?()
        }
    }
    
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
        let handler: RequestResponseHandler = { _ in
            completion?()
        }
        sendRequest(path: "customer/enterChat", completion: handler)
    }
    
    func sendAskRequest(_ completion: ((_ success: Bool) -> Void)? = nil) {
        let handler: RequestResponseHandler = { message in
            let success = message.type != MessageType.responseError
            completion?(success)
        }
        sendRequest(path: "customer/ask", completion: handler)
    }
    
    func sendSRSQuery(_ query: String, isRequestFromPrediction: Bool = false, autosuggestMetadata: AutosuggestMetadata?) {
        if ASAPP.isDemoContentEnabled(), let demoResponse = Event.demoResponseForQuery(query) {
            echoMessageResponse(withJSONString: demoResponse)
            return
        }
        
        let path = "srs/SendTextMessageAndHierAndTreewalk"
        var params: [String: Any] = [
            "Text": query,
            "SearchQuery": query
        ]
        
        if let data = try? JSONEncoder().encode(autosuggestMetadata),
           let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            params["CustAutoCompleteAnalytics"] = dict
        }
        
        sendRequest(path: path, params: params)
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
