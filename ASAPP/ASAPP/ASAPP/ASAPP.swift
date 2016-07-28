//
//  ASAPP.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

internal let ASAPPBundle = NSBundle(forClass: ASAPP.self)

public class ASAPP: NSObject {
    
    // MARK:- Instance Methods
    
    public class func createChatViewController(withCredentials credentials: Credentials) -> UIViewController {
        return ChatViewController(withCredentials: credentials)
    }
}

public class Credentials: NSObject {
    
    // MARK:- Properties
    
    public private(set) var companyMarker: String
    public private(set) var isCustomer: Bool
    public private(set) var userToken: String?
    public private(set) var targetCustomerToken: String?
    
    // MARK:- Initialization
    
    public init(withCompany company: String, userToken: String?, isCustomer: Bool, targetCustomerToken: String? = nil) {
        self.companyMarker = company
        self.userToken = userToken
        self.isCustomer = isCustomer
        self.targetCustomerToken = targetCustomerToken
        
        super.init()
    }
    
    // MARK:- DebugPrintable
    
    override public var description: String {
        if isCustomer {
            return "Customer @ \(companyMarker): \(userToken ?? "")"
        } else {
            return "Rep @ \(companyMarker): \(userToken ?? "") \(targetCustomerToken != nil ? "-> \(targetCustomerToken!)" : "")"
        }
    }
    override public var debugDescription: String {
        return description
    }
}
 