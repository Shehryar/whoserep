//
//  ConversationManager+Analytics.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/18/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

enum AnalyticsEventType: String {
    case buttonClick = "BUTTON_CLICK"
    case srsRequest = "SRS_REQUEST"
    case deepLink = "DEEP_LINK"
    case webLink = "EXTERNAL_URL"
    case sdkError = "SDK_ERROR"
}

enum AnalyticsButtonName: String {
    case openChat = "open_chat"
    case closeChatFromChat = "close_chat_from_chat"
    case closeChatFromPredictive = "close_chat_from_predictive"
    case showPredictiveFromChat = "show_predictive_from_chat"
    case showChatFromPredictive = "show_chat_from_predictive"
    case srsBack = "srs_back"
}

typealias AnalyticsAttributes = [String : String]

typealias AnalyticsMetrics = [String : Double]

// MARK:- Generic Analytics Tracking

extension ConversationManager {
    
    func trackEvent(eventType: AnalyticsEventType, attributes: AnalyticsAttributes? = nil, metrics: AnalyticsMetrics? = nil) {
        var params: [String : AnyObject] = [
            "EventType" : eventType.rawValue as AnyObject,
            "Attributes" : [ "platform" : "iOS" ].with(attributes) as AnyObject
        ]
        if let metrics = metrics {
            params["Metrics"] = metrics as AnyObject
        }
        
//        DebugLog("\n\nLogging Event: \(params)\n")
        
        socketConnection.sendRequest(withPath: "srs/PutMAEvent", params: params)
    }
}

// MARK:- Event-specific Functions

extension ConversationManager {
    
    func trackButtonTap(buttonName: AnalyticsButtonName) {
        trackEvent(eventType: .buttonClick,
                   attributes: [ "button_clicked" : buttonName.rawValue ],
                   metrics: nil)
    }
    
    func trackSRSQuery(query: String) {
        trackEvent(eventType: .srsRequest,
                   attributes: [ "query_text" : query ],
                   metrics: nil)
    }
    
    func trackDeepLink(link: String) {
        trackEvent(eventType: .deepLink,
                   attributes: [ "url" : link ],
                   metrics: nil)
    }
    
    func trackWebLink(link: String) {
        trackEvent(eventType: .webLink,
                   attributes: [ "url" : link ],
                   metrics: nil)
    }
}
