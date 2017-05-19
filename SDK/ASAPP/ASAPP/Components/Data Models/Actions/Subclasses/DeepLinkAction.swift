//
//  DeepLinkAction.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/2/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class DeepLinkAction: Action {

    // MARK: JSON Keys
    
    enum JSONKey: String {
        case data = "data"
        case name = "name"
    }
    
    // MARK: Properties
    
    override var type: ActionType {
        return .deepLink
    }
    
    let name: String
    
    let data: [String : Any]?
    
    override var willExitASAPP: Bool {
        return true
    }
    
    // MARK: Init
    
    required init?(content: Any?) {
        guard let content = content as? [String : Any],
            let name = content.string(for: JSONKey.name.rawValue) else {
                DebugLog.d(caller: DeepLinkAction.self, "name is required. Returning nil.")
                return nil
        }
        self.name = name
        self.data = content.jsonObject(for: JSONKey.data.rawValue)
        super.init(content: content)
    }
}

extension DeepLinkAction {
    
    func getWebLink() -> URL? {
        if name == "url", let urlString = data?["url"] as? String {
            return URL(string: urlString)
        }
        return nil
    }
}
