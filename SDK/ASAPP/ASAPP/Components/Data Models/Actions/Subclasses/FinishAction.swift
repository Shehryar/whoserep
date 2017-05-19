//
//  FinishAction.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class FinishAction: Action {

    enum JSONKey: String {
        case classification = "classification"
        case text = "text"
    }
    
    // MARK: Properties
    
    override var type: ActionType {
        return .finish
    }
    
    let classification: String?
    
    let text: String?
    
    // MARK: Init
    
    required init?(content: Any?) {
        guard let content = content as? [String : Any] else {
            return nil
        }
        self.classification = content.string(for: JSONKey.classification.rawValue)
        self.text = content.string(for: JSONKey.text.rawValue)
        
        super.init(content: content)
    }
}
