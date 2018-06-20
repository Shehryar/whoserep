//
//  LinkAction.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 6/14/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

class LinkAction: Action {
    enum JSONKey: String {
        case link
        case data
    }
    
    let link: PlatformIndependentLink
    
    required init?(content: Any?) {
        guard
            let content = content as? [String: Any],
            let link = content.string(for: JSONKey.link.rawValue)
        else {
            DebugLog.d(caller: DeepLinkAction.self, "link is required. Returning nil.")
            return nil
        }
        
        self.link = link
        super.init(content: content)
    }
}
