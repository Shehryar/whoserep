//
//  FullCredentials.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/22/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import RealmSwift

class FullCredentials: Object {
    // Basic Credentials
    dynamic var companyMarker: String = ""
    dynamic var userToken: String? = nil
    dynamic var isCustomer: Bool = true
    
    dynamic var targetCustomerToken: String?
    dynamic var myId: Int = 0
    dynamic var customerTargetCompanyId: Int = 0
    dynamic var issueId: Int = 0
    dynamic var reqId: Int = 0
    dynamic var sessionInfo: String?
    
    // MARK: Initialization
    
    convenience init(withCompany company: String, userToken: String? = nil, isCustomer: Bool = true) {
        self.init()
        self.companyMarker = company
        self.userToken = userToken
        self.isCustomer = isCustomer
    }
    
    convenience init(withCredentials credentials: Credentials) {
        self.init()
        self.companyMarker = credentials.companyMarker
        self.userToken = credentials.userToken
        self.isCustomer = credentials.isCustomer
    }
}
