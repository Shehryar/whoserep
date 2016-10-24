//
//  DemoUserManager.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/8/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

class DemoUserManager: NSObject {

    let companyMarker: String
    
    required init(companyMarker: String) {
        self.companyMarker = companyMarker
        super.init()
    }
}

// MARK:- User Token

extension DemoUserManager {
    
    private func userTokenStorageKey() -> String {
        return "\(companyMarker)-Demo-User-Token"
    }
    
    func getUserToken() -> String {
        if DemoSettings.useComcastPhoneUser() {
            return "+13126089137"
        }
        
        return UserDefaults.standard.string(forKey: userTokenStorageKey())
            ?? createNewUserToken()
    }
    
    func createNewUserToken() -> String {
        let freshUserToken = "\(companyMarker)-Test-Account-\(floor(Date().timeIntervalSince1970))"
        
        UserDefaults.standard.set(freshUserToken, forKey: userTokenStorageKey())
        
        return freshUserToken
    }
}

// MARK:- Auth + Context

extension DemoUserManager {
    
    func getContext() -> [String : Any] {
        return [
            "fake_context_key_1" : "fake_context_value_1",
            "fake_context_key_2" : "fake_context_value_2"
        ]
    }
    
    func getAuthData() -> [String : Any] {
        
        //        sleep(1) // Mimic slow response from Comcast
        
        return [
            ASAPP.AUTH_KEY_ACCESS_TOKEN : "fake_access_token_abc12345",
            ASAPP.AUTH_KEY_ISSUED_TIME : Date(),
            ASAPP.AUTH_KEY_EXPIRES_IN : 60 * 60
        ]
    }
}

