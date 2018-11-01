//
//  FinishAction.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class FinishAction: Action {

    // MARK: Properties
    
    enum JSONKey: String {
        case nextAction
    }
    
    let nextAction: Action?
    
    // MARK: Init
    
    required init?(content: Any?, performImmediately: Bool = false) {
        if let content = content as? [String: Any] {
            self.nextAction = ActionFactory.action(with: content[JSONKey.nextAction.rawValue])
        } else {
            self.nextAction = nil
        }
        super.init(content: content, performImmediately: performImmediately)
    }
}
