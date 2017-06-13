//
//  UserLoginAction.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 6/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class UserLoginAction: Action {
    
    enum JSONKey: String {
        case mergeCustomerId = "mergeCustomerId"
        case mergeCustomerGUID = "mergeCustomerGUID"
        case nextAction = "nextAction"
    }
    
    // MARK: Properties
    
    let classification: String?
    
    let text: String?
    
    // MARK: Init
    
    required init?(content: Any?) {
        return nil
    }

}
