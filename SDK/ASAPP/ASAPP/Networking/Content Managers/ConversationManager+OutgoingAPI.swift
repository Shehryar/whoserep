//
//  ConversationManager+API.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/15/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- SRS

extension ConversationManager {
    
    func startSRS(completion: ((_ response: AppOpenResponse) -> Void)? = nil) {
        sendSRSRequest(path: "srs/AppOpen", params: nil) { (incomingMessage, request, responseTime) in
            
            if self.demo_OverrideStartSRS(completion: completion) {
                return
            }
            
            guard incomingMessage.type == .Response,
                let data = incomingMessage.bodyString?.data(using: String.Encoding.utf8),
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any],
                let appOpenResponse = AppOpenResponse.fromJSON(jsonObject)
                else {
                    return
            }
            
            completion?(appOpenResponse)
        }
    }
    
    func sendSRSQuery(_ query: String, isRequestFromPrediction: Bool = false) {
        let path = "srs/SendTextMessageAndHierAndTreewalk"
        let params = [
            "Text" : query,
            "SearchQuery" : query
        ]
        
        sendSRSRequest(path: path, params: params, isRequestFromPrediction: isRequestFromPrediction)
    }
    
    func sendButtonItemSelection(_ buttonItem: SRSButtonItem,
                                 from message: ChatMessage?,
                                 originalSearchQuery: String?,
                                 completion: IncomingMessageHandler? = nil) {
        
 
        let action = buttonItem.action
        switch action.type {
        case .treewalk:
            sendSRSTreewalk(classification: action.name,
                            with: buttonItem.title,
                            from: message,
                            originalSearchQuery: originalSearchQuery,
                            completion: completion)
            break
            
        case .api:
            sendSRSAction(action: action.name,
                          withUserMessage: buttonItem.title,
                          payload: action.context,
                          completion: completion)
            break
            
        case .link:
            sendSRSLinkButtonTapped(buttonItem: buttonItem, completion: completion)
            break
            
        case .action, .componentView:
            
            break
        }
    }
    
    // MARK: Private
    
    private func sendSRSRequest(path: String,
                                params: [String : Any]?,
                                isRequestFromPrediction: Bool = false,
                                completion: IncomingMessageHandler? = nil) {
        
        Dispatcher.performOnBackgroundThread {
            var srsParams: [String : Any] = [ "Context" : self.user.getContextString()].with(params)
            srsParams[ASAPP.CLIENT_TYPE_KEY] = ASAPP.CLIENT_TYPE_VALUE
            srsParams[ASAPP.CLIENT_VERSION_KEY] = ASAPP.clientVersion
            let (authToken, _) = self.user.getAuthToken()
            if let authToken = authToken {
                srsParams["Auth"] = authToken
            }
            
            Dispatcher.performOnMainThread {
                self.socketConnection.sendRequest(withPath: path, params: srsParams, context: nil, requestHandler: { (incomingMessage, request, responseTime) in
                    completion?(incomingMessage, request, responseTime)
                    
                    self.trackSRSRequest(path: path,
                                         requestUUID: request?.requestUUID,
                                         isPredictive: isRequestFromPrediction,
                                         params: params,
                                         responseTimeInMilliseconds: responseTime)
                })
            }
        }
    }
    
    private func sendSRSTreewalk(classification: String,
                                 text: String,
                                 from message: ChatMessage?,
                                 originalSearchQuery: String?,
                                 completion: IncomingMessageHandler? = nil) {
        let path = "srs/SendTextMessageAndHierAndTreewalk"
        var params = [
            "Text" : text,
            "Classification" : classification
        ]
        if let originalSearchQuery = originalSearchQuery {
            params["SearchQuery"] = originalSearchQuery
        }
        if let eventId = message?.metadata.eventId {
            params["ParentEventLogSeq"] = eventId
        }
        
        sendSRSRequest(path: path, params: params) { [weak self] (incomingMessage, request, responseTime) in
            completion?(incomingMessage, request, responseTime)
            self?.trackTreewalk(message: text, classification: classification)
        }
    }
    
    private func sendSRSAction(action: String,
                               withUserMessage message: String,
                               payload: [String : Any]?,
                                completion: IncomingMessageHandler? = nil) {
        let path = "srs/\(action)"
        var params = ["Text" : message]
        if let payload = payload {
            params["Payload"] = payload
        }
        
        sendSRSRequest(path: path, params: params, completion: completion)
    }
    
    private func sendSRSLinkButtonTapped(buttonItem: SRSButtonItem, completion: IncomingMessageHandler? = nil) {
        guard buttonItem.action.type == .link else {
            return
        }
        
        var params: [String : Any] = [
            "Title" : buttonItem.title,
            "Link" : buttonItem.action.name
        ]
        if let deepLinkDataJson = JSONUtil.stringify(buttonItem.action.context) {
            params["Data"] = deepLinkDataJson
        }
        
        let path = "srs/CreateLinkButtonTapEvent"
        sendSRSRequest(path: path, params: params, completion: completion)
    }
    
    // MARK:- Component View API

    func sendAPIActionRequest(_ action: APIAction,
                              params: [String : Any]?,
                              completion: @escaping ((ComponentAction?) -> Void)) {
        
        func handleResponse(_ message: IncomingMessage,
                            _ request: SocketRequest?,
                            _ responseTime: ResponseTimeInMilliseconds) {
            
            // Get Action from this
            let action = ComponentActionFactory.action(with: message.body)
            completion(action)
            
        }
 
        let path = action.requestPath
        if path.contains("srs/") {
            sendSRSRequest(path: action.requestPath,
                           params: params,
                           isRequestFromPrediction: false,
                           completion: handleResponse)
        } else {
            socketConnection.sendRequest(withPath: path,
                                         params: params,
                                         context: nil,
                                         requestHandler: handleResponse)
        }
    }
    
    func getComponentView(named name: String,
                          completion: @escaping ((ComponentViewContainer?) -> Void)) {
        
        let path = "srs/GetComponentView"
        let params = [
            "Classification" : name
        ]
        
        sendSRSRequest(path: path,
                       params: params as [String : Any],
                       isRequestFromPrediction: false) { (message, request, responseTime) in
                        let componentViewContainer = ComponentViewContainer.from(message.body)
                        completion(componentViewContainer)
        }
    }
    
}

// MARK:- Chat

extension ConversationManager {
    
    func sendUserTypingStatus(isTyping: Bool, withText text: String?) {
        let path = "customer/NotifyTypingPreview"
        let params = [ "Text" : text ?? "" ]
        socketConnection.sendRequest(withPath: path, params: params)
    }
    
    func sendTextMessage(_ message: String, completion: IncomingMessageHandler? = nil) {
        let path = "customer/SendTextMessage"
        socketConnection.sendRequest(withPath: path,
                                     params: ["Text" : message],
                                     requestHandler: completion)
    }
    
    func sendPictureMessage(_ image: UIImage, completion: (() -> Void)? = nil) {
        let path = "customer/SendPictureMessage"
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {
            DebugLog.e("Unable to get JPEG data for image: \(image)")
            return
        }
        let imageFileSize = imageData.count
        let params: [String : Any] = [ "MimeType" : "image/jpeg",
                                       "FileSize" : imageFileSize,
                                       "PicWidth" : image.size.width,
                                       "PicHeight" : image.size.height ]
        
        socketConnection.sendRequest(withPath: path, params: params)
        socketConnection.sendRequestWithData(imageData) { (incomingMessage) in
            completion?()
        }
    }
    
    func endLiveChat() {
        guard isConnected(retryConnectionIfNeeded: true) else {
            return
        }
        
        socketConnection.sendRequest(withPath: "customer/EndConversation", params: nil)
    }
}

// MARK:- Use cases

extension ConversationManager {
    
    func sendRating(_ rating: Int, forIssueId issueId: Int, withFeedback feedback: String?, completion: ((_ success: Bool) -> Void)?) {
        let path = "customer/SendRatingAndFeedback"
        
        var params: [String : Any] = [
            "FiveStarRating" : rating,
            "IssueId" : issueId
        ]
        if let feedback = feedback {
            params["Feedback"] = feedback
        }
        
        socketConnection.sendRequest(withPath: path, params: params, context: nil) { (message, request, responseTime) in
            completion?(message.type == .Response)
        }
    }
    
    func sendCreditCard(_ creditCard: CreditCard, completion: @escaping ((_ response: CreditCardResponse) -> Void)) {
        let path = "customer/SendCreditCard"
        let params = creditCard.toASAPPParams()
        
        socketConnection.sendRequest(withPath: path, params: params, context: nil)
        { (message: IncomingMessage, request: SocketRequest?, responseTime: ResponseTimeInMilliseconds) in
            let creditCardResponse = CreditCardResponse.from(json: message.body)
            completion(creditCardResponse)
        }
    }
}
