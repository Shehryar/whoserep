//
//  HTTPAction.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 6/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum HTTPMethod: String {
    case GET
    case POST
    
    static func from(_ value: String?) -> HTTPMethod? {
        guard let value = value else {
            return nil
        }
        return HTTPMethod(rawValue: value)
    }
}

class HTTPAction: Action {
    
    enum JSONKey: String {
        case method
        case url
        case onResponseAction
        case response
    }
    
    let method: HTTPMethod
    
    let url: URL
    
    let onResponseAction: Action?
    
    // MARK: Init
    
    required init?(content: Any?) {
        if let content = content as? [String: Any],
           let method = HTTPMethod.from(content[JSONKey.method.rawValue] as? String),
           let urlString = content[JSONKey.url.rawValue] as? String,
           let url = URL(string: urlString) {
            self.method = method
            self.url = url
            self.onResponseAction = ActionFactory.action(with: content[JSONKey.onResponseAction.rawValue])
        } else {
            DebugLog.w(caller: HTTPAction.self, "Unable to create HTTPAction without valid method and url: \(String(describing: content))")
            return nil
        }
        super.init(content: content)
    }
}
