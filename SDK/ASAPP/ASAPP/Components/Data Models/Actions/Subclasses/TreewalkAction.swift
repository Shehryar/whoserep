//
//  TreewalkAction.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/2/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TreewalkAction: Action {

    // MARK: Properties
    
    enum JSONKey: String {
        case classification
        case messageText
    }
    
    let classification: String
    
    let messageText: String?
    
    // MARK: Init
    
    required init?(content: Any?, performImmediately: Bool = false) {
        guard let content = content as? [String: Any],
            let classification = content.string(for: JSONKey.classification.rawValue) else {
                DebugLog.d(caller: TreewalkAction.self, "classification is required. Returning nil.")
                return nil
        }
        self.classification = classification
        self.messageText = content.string(for: JSONKey.messageText.rawValue)
        
        super.init(content: content, performImmediately: performImmediately)
    }
}
