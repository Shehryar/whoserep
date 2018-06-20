//
//  LinkResolver.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 6/14/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

typealias PlatformIndependentLink = String

protocol LinkResolverProtocol {
    func resolve(linkAction: LinkAction, completion: @escaping ((Action?) -> Void))
}

class LinkResolver: LinkResolverProtocol {
    static let shared = LinkResolver()
    
    enum ResolvedLinkType: String {
        case app
        case web
    }
    
    func resolve(linkAction: LinkAction, completion: @escaping ((Action?) -> Void)) {
        let params: [String: Any] = [
            "link": linkAction.link,
            "data": linkAction.data as Any
        ]
        
        HTTPClient.shared.sendRequest(method: .POST, path: "customer/resolveLink", params: params) { (data, _, _) in
            guard
                let data = data,
                let typeString = data["type"] as? String,
                let linkType = ResolvedLinkType(rawValue: typeString),
                let resolvedLink = data["link"] as? String
            else {
                completion(nil)
                return
            }
            
            let action: Action?
            switch linkType {
            case .app:
                action = DeepLinkAction(content: ["name": resolvedLink, "data": data["data"]])
            case .web:
                action = WebPageAction(content: ["url": resolvedLink, "data": data["data"]])
            }
            
            completion(action)
        }
    }
}
