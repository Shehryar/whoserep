//
//  Credentials.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/20/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation
import RealmSwift

class Credentials: Object {
    // Required
    dynamic var companyMarker: String = ""
    dynamic var userToken: String? = nil
    dynamic var isCustomer: Bool = true
    
    // Updated later
    dynamic var targetCustomerToken: String = ""
    dynamic var myId: Int = 0
    dynamic var customerTargetCompanyId: Int = 0
    dynamic var issueId: Int = 0
    dynamic var reqId: Int = 0
    dynamic var sessionInfo: String? = nil
    
    // MARK:- Initialization
    
    convenience init(withCompany company: String, userToken: String? = nil, isCustomer: Bool = true) {
        self.init()
        
        self.companyMarker = company
        self.userToken = userToken
        self.isCustomer = isCustomer
    }
}
