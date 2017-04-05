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
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject],
                let appOpenResponse = AppOpenResponse.instanceWithJSON(jsonObject)
                else {
                    return
            }
            
            completion?(appOpenResponse)
        }
    }
    
    func sendSRSQuery(_ query: String, isRequestFromPrediction: Bool = false) {
        if demo_OverrideMessageSend(message: query) {
            return
        }
        
        let path = "srs/SendTextMessageAndHierAndTreewalk"
        let params = [
            "Text" : query as AnyObject,
            "SearchQuery" : query as AnyObject
        ]
        
        sendSRSRequest(path: path, params: params, isRequestFromPrediction: isRequestFromPrediction)
    }
    
    func sendButtonItemSelection(_ buttonItem: SRSButtonItem,
                                 from message: ChatMessage?,
                                 originalSearchQuery: String?,
                                 completion: IncomingMessageHandler? = nil) {
        
        if demo_OverrideButtonItemSelection(buttonItem: buttonItem, completion: completion) {
            return
        }
        
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
                                params: [String : AnyObject]?,
                                isRequestFromPrediction: Bool = false,
                                completion: IncomingMessageHandler? = nil) {
        
        Dispatcher.performOnBackgroundThread {
            var srsParams: [String : AnyObject] = [ "Context" : self.config.getContextString() as AnyObject].with(params)
            srsParams[ASAPP.CLIENT_TYPE_KEY] = ASAPP.CLIENT_TYPE_VALUE as AnyObject
            srsParams[ASAPP.CLIENT_VERSION_KEY] = ASAPP.clientVersion as AnyObject
            if let authToken = self.config.getAuthToken() {
                srsParams["Auth"] = authToken as AnyObject
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
                                 with text: String,
                                 from message: ChatMessage?,
                                 originalSearchQuery: String?,
                                 completion: IncomingMessageHandler? = nil) {
        let path = "srs/SendTextMessageAndHierAndTreewalk"
        var params = [
            "Text" : text as AnyObject,
            "Classification" : classification as AnyObject
        ]
        if let originalSearchQuery = originalSearchQuery {
            params["SearchQuery"] = originalSearchQuery as AnyObject
        }
        if let eventId = message?.eventId {
            params["ParentEventLogSeq"] = eventId as AnyObject
        }
        
        sendSRSRequest(path: path, params: params) { [weak self] (incomingMessage, request, responseTime) in
            completion?(incomingMessage, request, responseTime)
            self?.trackTreewalk(message: text, classification: classification)
        }
    }
    
    private func sendSRSAction(action: String,
                               withUserMessage message: String,
                               payload: [String : AnyObject]?,
                                completion: IncomingMessageHandler? = nil) {
        let path = "srs/\(action)"
        var params = ["Text" : message as AnyObject]
        if let payload = payload {
            params["Payload"] = payload as AnyObject
        }
        
        sendSRSRequest(path: path, params: params, completion: completion)
    }
    
    private func sendSRSLinkButtonTapped(buttonItem: SRSButtonItem, completion: IncomingMessageHandler? = nil) {
        guard buttonItem.action.type == .link else {
            return
        }
        
        var params: [String : AnyObject] = [
            "Title" : buttonItem.title as AnyObject,
            "Link" : buttonItem.action.name as AnyObject
        ]
        if let deepLinkData = buttonItem.action.context as? AnyObject,
            let deepLinkDataJson = JSONUtil.stringify(deepLinkData) {
            params["Data"] = deepLinkDataJson as AnyObject
        }
        
        let path = "srs/CreateLinkButtonTapEvent"
        sendSRSRequest(path: path, params: params, completion: completion)
    }
    
    // MARK:- Component View API

    func sendAPIActionRequest(_ action: APIAction,
                              params: [String : AnyObject]?,
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
                       params: params as [String : AnyObject],
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
        socketConnection.sendRequest(withPath: path, params: params as [String : AnyObject]?)
    }
    
    func sendTextMessage(_ message: String, completion: IncomingMessageHandler? = nil) {
        if demo_OverrideMessageSend(message: message) {
            return
        }
        
        let path = "customer/SendTextMessage"
        socketConnection.sendRequest(withPath: path,
                                     params: ["Text" : message as AnyObject],
                                     requestHandler: completion)
    }
    
    func sendPictureMessage(_ image: UIImage, completion: (() -> Void)? = nil) {
        let path = "customer/SendPictureMessage"
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {
            DebugLog.e("Unable to get JPEG data for image: \(image)")
            return
        }
        let imageFileSize = imageData.count
        let params: [String : AnyObject] = [ "MimeType" : "image/jpeg" as AnyObject,
                                             "FileSize" : imageFileSize as AnyObject,
                                             "PicWidth" : image.size.width as AnyObject,
                                             "PicHeight" : image.size.height as AnyObject ]
        
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
        
        var params = [
            "FiveStarRating" : rating as AnyObject,
            "IssueId" : issueId as AnyObject
        ]
        if let feedback = feedback {
            params["Feedback"] = feedback as AnyObject
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
