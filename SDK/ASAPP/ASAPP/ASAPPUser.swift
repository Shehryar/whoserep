//
//  ASAPPUser.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public typealias ASAPPAuthProvider = (() -> [String : Any])

public typealias ASAPPContextProvider = (() -> [String : Any])

// MARK:- ASAPPUser

public class ASAPPUser: NSObject {

    public let userId: String
    
    public let authProvider: ASAPPAuthProvider
    
    public let contextProvider: ASAPPContextProvider

    // MARK:- Init
    
    public init(userId: String,
                authProvider: @escaping ASAPPAuthProvider,
                contextProvider: @escaping ASAPPContextProvider) {
        self.userId = userId
        self.authProvider = authProvider
        self.contextProvider = contextProvider
        super.init()
    }
}

// MARK:- Auth / Context Utilities

internal extension ASAPPUser {
    
    internal func getAuthToken() -> (String?, [String : Any]) {
        DebugLog.d("Calling host app for authentication")
        
        let authJSON = authProvider()
        let accessToken = authJSON[ASAPP.AUTH_KEY_ACCESS_TOKEN] as? String
        
        DebugLog.d(caller: self, "Access Token: \(String(describing: accessToken)), from auth json: \(authJSON)")
        
        return (accessToken, authJSON)
    }
    
    internal func getContextString() -> String {
        let context = contextProvider()
        if let contextData = try? JSONSerialization.data(withJSONObject: context, options: .prettyPrinted) {
            if let contextString = String(data: contextData, encoding: .utf8) {
                return contextString
            }
        }
        return ""
    }
}
