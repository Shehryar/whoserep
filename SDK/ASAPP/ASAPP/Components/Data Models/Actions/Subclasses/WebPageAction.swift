//
//  WebPageAction.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/2/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class WebPageAction: Action {
    
    // MARK: Properties
    
    enum JSONKey: String {
        case url
    }
    
    let url: URL
    
    // MARK: Init
    
    required init?(content: Any?, performImmediately: Bool = false) {
        guard let content = content as? [String: Any],
            let urlString = content.string(for: JSONKey.url.rawValue) else {
                DebugLog.d(caller: DeepLinkAction.self, "url is required. Returning nil.")
                return nil
        }
        guard let url = URL(string: urlString) else {
            DebugLog.d(caller: WebPageAction.self, "Unable to create url from: \(urlString)")
            return nil
        }
        
        self.url = url
        
        super.init(content: content, performImmediately: performImmediately)
    }
}
