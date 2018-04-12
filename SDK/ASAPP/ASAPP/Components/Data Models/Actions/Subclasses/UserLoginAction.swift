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
    let customer: Session.Customer?
    
    // MARK: Init
    
    required init?(content: Any?) {
        guard let content = content as? [String: Any] else {
                return nil
        }
        
        self.nextAction = ActionFactory.action(with: content[JSONKey.nextAction.rawValue])
        self.customer = nil
        super.init(content: content)
    }
    
    init?(customer: Session.Customer, nextAction: Action? = nil) {
        self.nextAction = nextAction
        self.customer = customer
        super.init(content: nil)
    }

}
