//
//  ConversationManager+API.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/15/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- Chat

extension ConversationManager {
    
    func sendUserTypingStatus(isTyping: Bool, withText text: String?) {
        let path = "customer/NotifyTypingPreview"
        let params = [ "Text": text ?? "" ]
        sendRequest(path: path, params: params, requiresContext: false, completion: nil)
    }
    
    func sendTextMessage(_ message: String, completion: IncomingMessageHandler? = nil) {
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
        
        socketConnection.sendRequest(withPath: path, params: params)
        socketConnection.sendRequestWithData(imageData) { _, _, _ in
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

// MARK:- SRS

extension ConversationManager {
    
    func getAppOpen(_ completion: ((_ response: AppOpenResponse) -> Void)? = nil) {
        
        let onResponse: IncomingMessageHandler = { (message, request, responseTime) in
            if ASAPP.isDemoContentEnabled(), let appOpenResponse = self.demo_AppOpenResponse() {
                completion?(appOpenResponse)
            }
            
            guard message.type == .response,
                let data = message.bodyString?.data(using: String.Encoding.utf8),
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any],
                let appOpenResponse = AppOpenResponse.fromJSON(jsonObject)
                else {
                    return
            }
            
            completion?(appOpenResponse)
        }
        
        sendRequest(path: "srs/AppOpen", completion: onResponse)
    }
    
    func sendSRSQuery(_ query: String, isRequestFromPrediction: Bool = false) {
        if ASAPP.isDemoContentEnabled(), let demoResponse = Event.demoResponseForQuery(query) {
            echoMessageResponse(withJSONString: demoResponse)
            return
        }
        
        let path = "srs/SendTextMessageAndHierAndTreewalk"
        let params = [
            "Text": query,
            "SearchQuery": query
        ]
        
        sendRequest(path: path, params: params, isRequestFromPrediction: isRequestFromPrediction)
    }
}

// MARK:- Use cases

extension ConversationManager {
    
    func sendRating(_ rating: Int, resolved: Bool?, forIssueId issueId: Int, withFeedback feedback: String?, completion: ((_ success: Bool) -> Void)?) {
        let path = "customer/SendRatingAndFeedback"
        
        var params: [String : Any] = [
            "FiveStarRating": rating,
            "IssueId": issueId
        ]
        if let resolved = resolved {
            params["Resolved"] = resolved
        }
        if let feedback = feedback {
            params["Feedback"] = feedback
        }
        
        socketConnection.sendRequest(withPath: path, params: params, context: nil) { (message, _, _) in
            completion?(message.type == .response)
        }
    }
    
    func sendCreditCard(_ creditCard: CreditCard, completion: @escaping ((_ response: CreditCardResponse) -> Void)) {
        let path = "customer/SendCreditCard"
        let params = creditCard.toASAPPParams()
        
        socketConnection.sendRequest(withPath: path, params: params, context: nil) { (message: IncomingMessage, _, _) in
            let creditCardResponse = CreditCardResponse.from(json: message.body)
            completion(creditCardResponse)
        }
    }
}
