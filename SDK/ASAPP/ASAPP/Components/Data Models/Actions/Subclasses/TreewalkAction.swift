//
//  TreewalkAction.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/2/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TreewalkAction: Action {

    // MARK: JSON Keys
    
    enum JSONKey: String {
        case classification = "classification"
    }
    
    // MARK: Properties
    
    let classification: String
    
    // MARK: Init
    
    required init?(content: Any?) {
        guard let content = content as? [String : Any],
            let classification = content.string(for: JSONKey.classification.rawValue) else {
                DebugLog.d(caller: TreewalkAction.self, "classification is required. Returning nil.")
                return nil
        }
        self.classification = classification
        super.init(content: content)
    }
}
