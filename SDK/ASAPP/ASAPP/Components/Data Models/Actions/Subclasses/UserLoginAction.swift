//
//  UserLoginAction.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 6/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class UserLoginAction: Action {
    
    // MARK: Properties
    
    enum JSONKey: String {
        case nextAction
    }
    
    let nextAction: Action?
    let previousSession: Session?
    
    // MARK: Init
    
    required init?(content: Any?) {
        guard let content = content as? [String: Any] else {
                return nil
        }
        
        self.nextAction = ActionFactory.action(with: content[JSONKey.nextAction.rawValue])
        self.previousSession = nil
        super.init(content: content)
    }
    
    init?(session: Session, nextAction: Action? = nil) {
        self.nextAction = nextAction
        self.previousSession = session
        super.init(content: nil)
    }

}
