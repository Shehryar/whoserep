//
//  ConversationManager+Actions.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/24/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

extension ConversationManager {
    
    // MARK: API Action
    
    func sendRequestForAPIAction(_ action: Action?,
                                 formData: [String : Any]?,
                                 completion: @escaping APIActionResponseHandler) {
        
        guard let action = action as? APIAction else {
            DebugLog.w(caller: self, "sendRequestForAPIAction called without APIAction")
            completion(nil)
            return
        }
        
        var params = [String : Any]()
        if let data = JSONUtil.stringify(action.getDataWithFormData(formData)) {
            params["Data"] = data
        }
        
        let responseHandler: IncomingMessageHandler = { (message, _, _) in
            let response = APIActionResponse.fromJSON(message.body)
            completion(response)
        }
        sendRequest(path: action.requestPath, params: params, completion: responseHandler)
    }
    
    // MARK: HTTP Action
    
    func sendRequestForHTTPAction(_ action: Action,
                                  formData: [String : Any]?,
                                  completion: @escaping ((_ data: [String : Any]?) -> Void)) {
        
        guard let action = action as? HTTPAction else {
            DebugLog.w(caller: self, "sendRequestForHTTPAction called without HTTPAction")
            completion(nil)
            return
        }
        
        var params = [String : Any]()
        if let data = action.getDataWithFormData(formData) {
            params["data"] = data
        }
        
        let responseHandler: HTTPClient.CompletionHandler = { (body, response, error) in
            completion(nil)
        }
        getRequestParameters(with: params, contextKey: "context") { (fullParams) in
            HTTPClient.shared.sendRequest(method: action.method,
                                          url: action.url,
                                          params: fullParams,
                                          completion: responseHandler)
        }
    }
    
    // MARK: Component View
    
    typealias ComponentViewHandler = (ComponentViewContainer?) -> Void
    
    func getComponentView(named name: String, data: [String : Any]? = nil, completion: @escaping ComponentViewHandler) {
        
        let path = "srs/GetComponentView"
        var params: [String : Any] = [
            "ComponentView" : name
        ]
        if let data = JSONUtil.stringify(data) {
            params["Data"] = data
        }
        
        let responseHandler: IncomingMessageHandler = { (message, _, _) in
            let componentViewContainer = ComponentViewContainer.from(message.body)
            completion(componentViewContainer)
        }
        
        sendRequest(path: path, params: params, completion: responseHandler)
    }
    
    func sendRequestForComponentViewAction(_ action: Action?, completion: @escaping ComponentViewHandler) {
        guard let action = action as? ComponentViewAction else {
            DebugLog.w(caller: self, "sendRequestForComponentViewAction called without ComponentViewAction")
            completion(nil)
            return
        }
        
        getComponentView(named: action.name, data: action.data, completion: completion)
    }
    
    // MARK: Deep Link
    
    func sendRequestForDeepLinkAction(_ action: Action?,
                                      with buttonTitle: String,
                                      completion: IncomingMessageHandler? = nil) {
        guard let action = action as? DeepLinkAction else {
            DebugLog.w(caller: self, "sendRequestForDeepLinkAction called without DeepLinkAction")
            completion?(IncomingMessage.errorMessage("Missing DeepLinkAction"), nil, 0)
            return
        }
        
        let path = "srs/CreateLinkButtonTapEvent"
        
        var params: [String : Any] = [
            "Title" : buttonTitle,
            "Link" : action.name
        ]
        if let deepLinkDataJson = JSONUtil.stringify(action.data) {
            params["Data"] = deepLinkDataJson
        }
        
        sendRequest(path: path, params: params, completion: completion)
    }
    
    // MARK: Treewalk
    
    func sendRequestForTreewalkAction(_ action: TreewalkAction,
                                      messageText: String?,
                                      parentMessage: ChatMessage?,
                                      completion: ((Bool) -> Void)? = nil) {
        let path = "srs/SendTextMessageAndHierAndTreewalk"
        
        let text = action.messageText ?? messageText ?? ""
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
        if let data = JSONUtil.stringify(action.data) {
            params["Data"] = data
        }
        
        let responseHandler: IncomingMessageHandler = { [weak self] (message, request, _) in
            completion?(message.type == .Response)
            self?.trackTreewalk(message: text, classification: action.classification)
        }
        sendRequest(path: path, params: params, completion: responseHandler)
    }
}
