//
//  DeepLinkAction.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/2/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class DeepLinkAction: Action {

    // MARK: Properties
    
    enum JSONKey: String {
        case name
        case url
    }
    
    let name: String
    
    // MARK: Init
    
    required init?(content: Any?) {
        guard let content = content as? [String: Any],
            let name = content.string(for: JSONKey.name.rawValue) else {
                DebugLog.d(caller: DeepLinkAction.self, "name is required. Returning nil.")
                return nil
        }
        self.name = name
        super.init(content: content)
    }
}

extension DeepLinkAction {
    
    func getWebLink() -> URL? {
        if name == JSONKey.url.rawValue, let urlString = data?[JSONKey.url.rawValue] as? String {
            return URL(string: urlString)
        }
        return nil
    }
}
