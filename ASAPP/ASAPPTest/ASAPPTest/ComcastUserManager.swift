//
//  ComcastUserManager.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 9/26/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

class ComcastUserManager {
    
    // MARK: User Token
    
    static let USER_TOKEN_STORAGE_KEY = "ASAPP_DEMO_USER_TOKEN"
    
    class func getCompany() -> String {
        return "comcast"
    }
    
    class func getUserToken() -> String {
        return UserDefaults.standard.string(forKey: USER_TOKEN_STORAGE_KEY) ?? createNewUserToken()
    }
    
    class func createNewUserToken() -> String {
         let freshUserToken = "ASAPP-TEST-ACCOUNT_\(Date().timeIntervalSince1970)"
        
        UserDefaults.standard.set(freshUserToken, forKey: USER_TOKEN_STORAGE_KEY)
        
        return freshUserToken
    }
    
    // MARK: Context / Auth
    
    class func getContext() -> [String : Any] {
        return [
            "fake_context_key_1" : "fake_context_value_1",
            "fake_context_key_2" : "fake_context_value_2"
        ]
    }
    
    class func getAuthData() -> [String : Any] {
                
//        sleep(1) // Mimic slow response from Comcast
        
        return [
            ASAPP.AUTH_KEY_ACCESS_TOKEN : "fake_access_token_abc12345",
            ASAPP.AUTH_KEY_ISSUED_TIME : Date(),
            ASAPP.AUTH_KEY_EXPIRES_IN : 60 * 60
        ]
    }
}
