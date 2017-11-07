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
        case mergeCustomerId
        case mergeCustomerGUID
        case nextAction
    }
    
    let mergeCustomerId: UInt64
    
    let mergeCustomerGUID: String
    
    let nextAction: Action?
    
    // MARK: Init
    
    required init?(content: Any?) {
        guard let content = content as? [String : Any],
            let mergeCustomerId = content[JSONKey.mergeCustomerId.rawValue] as? UInt64,
            let mergeCustomerGUID = content.string(for: JSONKey.mergeCustomerGUID.rawValue) else {
                DebugLog.w(caller: UserLoginAction.self, "\(JSONKey.mergeCustomerId.rawValue) and \(JSONKey.mergeCustomerGUID.rawValue) are both required. Returning nil")
                return nil
        }
        self.mergeCustomerId = mergeCustomerId
        self.mergeCustomerGUID = mergeCustomerGUID
        self.nextAction = ActionFactory.action(with: content[JSONKey.nextAction.rawValue])
        super.init(content: content)
    }
    
    init?(customer: Session.Customer, nextAction: Action? = nil) {
        guard let guid = customer.guid else {
            return nil
        }
        
        self.mergeCustomerId = customer.id
        self.mergeCustomerGUID = guid
        self.nextAction = nextAction
        super.init(content: nil)
    }

}
