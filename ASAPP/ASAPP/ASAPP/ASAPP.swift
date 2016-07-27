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
    
    public func createChatViewController(withCompany company: String,
                                                     userToken: String? = nil,
                                                     isCustomer: Bool = false,
                                                     targetCustomerToken: String? = nil) -> UIViewController {
        let credentials = Credentials(withCompany: company,
                                      userToken: userToken,
                                      isCustomer: isCustomer,
                                      targetCustomerToken: targetCustomerToken)
            
        return ChatViewController(withCredentials: credentials)
    }
}
 