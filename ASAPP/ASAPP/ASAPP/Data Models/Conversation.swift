//
//  Conversation.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation
import RealmSwift

class Conversation: Object {

    // MARK: Realm Properties
    
    dynamic var company: String = ""
    dynamic var isCustomer: Bool = true
    dynamic var userToken: String?
    dynamic var targetCustomerToken: String?
    dynamic var uniqueIdentifier: String?
    let messageEvents = List<Event>()
    
    convenience init(withCredentials credentials: Credentials) {
        self.init()
        self.company = credentials.companyMarker
        self.isCustomer = credentials.isCustomer
        self.userToken = credentials.userToken
        self.targetCustomerToken = credentials.targetCustomerToken
        
        self.uniqueIdentifier = "\(company)|\(isCustomer)|\(userToken ?? "")|\(targetCustomerToken ?? "")"
    }
    
    override static func primaryKey() -> String? {
        return "uniqueIdentifier"
    }
}
