//
//  AnalyticsClient.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 6/26/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

struct AnalyticsEvent: Encodable {
    typealias Attributes = [String: AnyEncodableProtocol]
    
    enum Name: String, Encodable {
        case quickReplySelected = "quickReply.selected"
        case viewDismissed = "view.dismissed"
        case actionLinkSelected = "action.link.selected"
    }
    
    let name: Name
    let time: Date
    let attributes: Attributes
    
    init(name: Name, attributes: Attributes, metadata: [String: AnyCodable]?) {
        self.name = name
        self.time = Date()
        self.attributes = attributes.adding(metadata)
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case time
        case attributes
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(time.asRFC3339String, forKey: .time)
        try container.encode(attributes.mapValues { AnyEncodable($0.value) }, forKey: .attributes)
    }
}

protocol AnalyticsClientProtocol {
    func record(event: AnalyticsEvent)
}

class AnalyticsClient: AnalyticsClientProtocol {
    static let shared = AnalyticsClient()
    
    private func _record(event: AnalyticsEvent) {
        guard
            let data = try? JSONEncoder().encode(event),
            let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else {
            DebugLog.d(caller: self, "Could not encode analytics event: \(event)")
            return
        }
        
        let params = [
            "events": [dict]
        ]
        
        HTTPClient.shared.sendRequest(method: .POST, path: "customer/analytics", params: params) { (_, _, error) in
            if let error = error {
                DebugLog.e(caller: AnalyticsClient.self, "Received error in response to recording analytics events: \(error)")
            }
        }
    }
    
    func record(event: AnalyticsEvent) {
        Dispatcher.performOnBackgroundThread { [weak self] in
            self?._record(event: event)
        }
    }
}
