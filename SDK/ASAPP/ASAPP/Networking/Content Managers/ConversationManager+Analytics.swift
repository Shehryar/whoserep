//
//  ConversationManager+Analytics.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/18/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

enum AnalyticsEventType: String {
    case sessionStart = "SESSION_START"
    case buttonClick = "BUTTON_CLICK"
    case deepLink = "DEEP_LINK"
    case webLink = "EXTERNAL_URL"
    case treewalk = "TREEWALK"
    case srsRequestTime = "SRS_REQUEST_CLIENT"
    case liveChatBegan = "LIVE_CHAT_BEGAN"
    case liveChatEnded = "LIVE_CHAT_ENDED"
}

enum AnalyticsButtonName: String {
    case openChat = "open_chat"
    case closeChatFromChat = "close_chat_from_chat"
    case closeChatFromPredictive = "close_chat_from_predictive"
    case showPredictiveFromChat = "show_predictive_from_chat"
    case showChatFromPredictive = "show_chat_from_predictive"
    case srsBack = "srs_back"
}

enum SDKErrorType: String {
    case authenticationFailure = "authentication_failure"
    case apiResponseError = "api_request_error"
}

typealias AnalyticsAttributes = [String : String]

typealias AnalyticsMetrics = [String : Double]

// MARK:- Generic Analytics Tracking

extension ConversationManager {
    
    func trackEvent(eventType: AnalyticsEventType,
                    attributes: AnalyticsAttributes? = nil,
                    metrics: AnalyticsMetrics? = nil) {
        
        var defaultAttributes: [String : Any] = [
            "device_model" : UIDevice.current.model,
            "device_platform_name" : UIDevice.current.systemName,
            "device_platform_version" : UIDevice.current.systemVersion,
            "device_uuid" : sessionManager.deviceIdentifier,
            "device_event_sequence" : String(sessionManager.getNextEventSequence())
        ]
        if let currentIntent = currentSRSClassification {
            defaultAttributes["current_classification"] = currentIntent
        }
        
        var params: [String : Any] = [
            "EventType" : eventType.rawValue,
            "Attributes" : defaultAttributes.with(attributes)
        ]
        if let metrics = metrics {
            params["Metrics"] = metrics
        }
        
        socketConnection.sendRequest(withPath: "srs/PutMAEvent", params: params)
    }
}

// MARK:- Event-specific Functions

extension ConversationManager {
    
    func trackSessionStart() {
        trackEvent(eventType: .sessionStart)
    }
    
    func trackButtonTap(buttonName: AnalyticsButtonName) {
        trackEvent(eventType: .buttonClick,
                   attributes: [ "button_clicked" : buttonName.rawValue ],
                   metrics: nil)
    }
    
    func trackSRSButtonItemTap(buttonItem: SRSButtonItem) {
        if let webURL = buttonItem.action.getWebLink() {
            trackWebLink(webURL.absoluteString)
            return
        }
        
        switch buttonItem.action.type {
        case .link:
            trackDeepLink(link: buttonItem.action.name, deepLinkData: buttonItem.action.context)
            break
            
        case .treewalk, .api:
            // Tracked via events
            break
            
        case .action:
            // Not tracked yet
            break
            
        case .componentView:
            // Not tracked yet
            break;
        }
    }
    
    func trackDeepLink(link: String, deepLinkData: Any?) {
        var attributes = [ "url" : link ]
        if let deepLinkData = deepLinkData,
            let deepLinkDataString = JSONUtil.stringify(deepLinkData) {
            attributes["deep_link_data"] = deepLinkDataString
        }
        
        trackEvent(eventType: .deepLink,
                   attributes: attributes,
                   metrics: nil)
    }
    
    func trackWebLink(_ link: String) {
        trackEvent(eventType: .webLink,
                   attributes: [ "url" : link ],
                   metrics: nil)
    }
    
    func trackTreewalk(message: String, classification: String) {
        trackEvent(eventType: .treewalk,
                   attributes: [
                    "button_clicked" : message,
                    "classification" : classification
            ])
    }
    
    func trackSRSRequest(path: String,
                         requestUUID: String?,
                         isPredictive: Bool,
                         params: [String : Any]?,
                         responseTimeInMilliseconds: Int) {
        
        var attributes = [
            "endpoint" : path,
            "query_is_predictive" : isPredictive ? "true" : "false"
        ]
        if let requestUUID = requestUUID {
            attributes["request_id"] = requestUUID
        }
        
        if let paramsString = JSONUtil.stringify(params) {
            attributes["request_parameters"] = paramsString
        }
        
        let metrics = [ "elapsed_time" : Double(responseTimeInMilliseconds * 1000) ]
        
        trackEvent(eventType: .srsRequestTime,
                   attributes: attributes,
                   metrics: metrics)
    }
    
    func trackLiveChatBegan(issueId: Int) {
        let requestResponse = ["issueId" : issueId]
        guard let responseJson = JSONUtil.stringify(requestResponse) else {
            DebugLog.e("Unabled to stringify JSON for trackLiveChatBegan")
            return
        }
        
        trackEvent(eventType: .liveChatBegan, attributes: ["request_response" : responseJson])
    }
    
    func trackLiveChatEnded(issueId: Int) {
        let requestResponse = ["issueId" : issueId]
        guard let responseJson = JSONUtil.stringify(requestResponse) else {
            DebugLog.e("Unabled to stringify JSON for trackLiveChatBegan")
            return
        }
        
        trackEvent(eventType: .liveChatEnded, attributes: ["request_response" : responseJson])
    }
}
