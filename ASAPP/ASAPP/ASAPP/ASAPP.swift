//
//  ASAPP.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

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


/*** Reference for later - TargetCustomerToken
 
 
 public func targetCustomerToken(targetCustomerToken: String) {
     if mState.isCustomer() {
        ASAPPLoge("ERROR: Cannot set targetCustomer for Customer chat session.")
        return
     }
     
     if mState.targetCustomerToken() != nil && mState.targetCustomerToken() == targetCustomerToken {
        ASAPPLoge("WARNING: Same targetCustomerToken provided.")
        return
     }
     
     mState.reloadStateForRep(targetCustomerToken)
 }
 
 
 */
 
 