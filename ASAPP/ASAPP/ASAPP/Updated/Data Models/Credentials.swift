//
//  Credentials.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/20/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class Credentials: NSObject {

    // MARK:- Properties
    
    var companyMarker: String
    var userToken: String?
    var isCustomer: Bool
        
    // MARK:- Initialization
    
    init(withCompany company: String, userToken: String? = nil, isCustomer: Bool = true) {
        self.companyMarker = company
        self.userToken = userToken
        self.isCustomer = isCustomer
        
        super.init()
    }
}
