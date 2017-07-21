//
//  ConversationManager+API.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/15/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- Internal

extension ConversationManager {

    func getRequestParameters(with params: [String : Any]?,
                              requiresContext: Bool = true,
                              insertContextAsString: Bool = true,
                              contextKey: String = "Context",
                              completion: @escaping (_ params: [String : Any]) -> Void) {
        
        var requestParams: [String : Any] = [
            ASAPP.CLIENT_TYPE_KEY: ASAPP.CLIENT_TYPE_VALUE,
            ASAPP.CLIENT_VERSION_KEY: ASAPP.clientVersion
        ].with(params)
        
        if requiresContext {
            user.getContext(completion: { (context, authToken) in
                if let context = context {
                    if !insertContextAsString {
                        requestParams[contextKey] =  context
                    } else if insertContextAsString, let contextString = JSONUtil.stringify(context) {
                        requestParams[contextKey] =  contextString
                    }
                }
                if let authToken = authToken {
                    requestParams["Auth"] = authToken
                }
                completion(requestParams)
            })
        } else {
            completion(requestParams)
        }
    }
    
    fileprivate func sendSRSRequest(path: String,
                                    params: [String : Any]?,
                                    isRequestFromPrediction: Bool = false,
                                    completion: IncomingMessageHandler? = nil) {
        getRequestParameters(with: params) { (requestParams) in
            
            Dispatcher.performOnMainThread {
                self.socketConnection.sendRequest(withPath: path, params: requestParams, context: nil, requestHandler: { (incomingMessage, request, responseTime) in
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
}

// MARK: SRS

extension ConversationManager {
    
    func startSRS(completion: ((_ response: AppOpenResponse) -> Void)? = nil) {
        sendSRSRequest(path: "srs/AppOpen", params: nil) { (incomingMessage, request, responseTime) in
            
            if ASAPP.isDemoContentEnabled(), let appOpenResponse = self.demo_AppOpenResponse() {
                completion?(appOpenResponse)
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
}

// MARK:- Action Requests

extension ConversationManager {
    
    func sendRequestForAPIAction(_ action: APIAction,
                                 formData: [String : Any]?,
                                 completion: @escaping APIActionResponseHandler) {
            
        func handleResponse(_ message: IncomingMessage,
                            _ request: SocketRequest?,
                            _ responseTime: ResponseTimeInMilliseconds) {
            
            let response = APIActionResponse.fromJSON(message.body)
            completion(response)
        }
        
        var params = [String : Any]()
        if let data = action.getDataWithFormData(formData) {
            params["data"] = data
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
    
    func sendRequestForHTTPAction(_ action: Action,
                                  formData: [String : Any]?,
                                  completion: @escaping ((_ data: [String : Any]?) -> Void)) {
        guard let action = action as? HTTPAction else {
            DebugLog.d(caller: self, "Passed non-HTTPAction to sendRequestForHTTPAction")
            return
        }

        var params = [String : Any]()
        if let data = action.getDataWithFormData(formData) {
            params["data"] = data
        }
        
        HTTPClient.shared.sendRequest(method: action.method,
                                      url: action.url,
                                      params: params) { (responseBody, response, error) in
                                        
        }
    }
    
    func getComponentView(named name: String, completion: @escaping ((ComponentViewContainer?) -> Void)) {
        let path = "srs/GetComponentView"
        let params = [
            "ComponentView" : name
        ]
        
        sendSRSRequest(path: path,
                       params: params as [String : Any],
                       isRequestFromPrediction: false) { (message, request, responseTime) in
                        let componentViewContainer = ComponentViewContainer.from(message.body)
                        completion(componentViewContainer)
        }
    }
    
    func sendRequestForComponentViewAction(_ action: ComponentViewAction,
                                           completion: @escaping ((ComponentViewContainer?) -> Void)) {
        getComponentView(named: action.name, completion: completion)
    }
    
    func sendRequestForDeepLinkAction(_ action: DeepLinkAction,
                                      with buttonTitle: String,
                                      completion: IncomingMessageHandler? = nil) {
        var params: [String : Any] = [
            "Title" : buttonTitle,
            "Link" : action.name
        ]
        if let deepLinkDataJson = JSONUtil.stringify(action.data) {
            params["Data"] = deepLinkDataJson
        }
        
        let path = "srs/CreateLinkButtonTapEvent"
        sendSRSRequest(path: path, params: params, completion: completion)
    }
    
    func sendRequestForTreewalkAction(_ action: TreewalkAction,
                                      messageText: String?,
                                      parentMessage: ChatMessage?,
                                      originalSearchQuery: String?,
                                      completion: ((Bool) -> Void)? = nil) {
        let text = action.messageText ?? messageText ?? ""
        
        let path = "srs/SendTextMessageAndHierAndTreewalk"
        var params: [String : Any] = [
            "Text" : text,
            "Classification" : action.classification
        ]
        if let originalSearchQuery = originalSearchQuery {
            params["SearchQuery"] = originalSearchQuery
        }
        if let eventId = parentMessage?.metadata.eventId {
            params["ParentEventLogSeq"] = eventId
        }
        
        sendSRSRequest(path: path, params: params) { [weak self] (incomingMessage, request, responseTime) in
            completion?(incomingMessage.type == .Response)
            
            self?.trackTreewalk(message: text, classification: action.classification)
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
