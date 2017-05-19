//
//  ASAPPUser.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public typealias ASAPPRequestAuthProvider = (() -> [String : Any])

public typealias ASAPPRequestContextProvider = (() -> [String : Any])

// MARK:- ASAPPUser

public class ASAPPUser: NSObject {

    public let userIdentifier: String
    
    public let requestAuthProvider: ASAPPRequestAuthProvider
    
    public let requestContextProvider: ASAPPRequestContextProvider

    // MARK:- Init
    
    public init(userIdentifier: String,
                requestAuthProvider: @escaping ASAPPRequestAuthProvider,
                requestContextProvider: @escaping ASAPPRequestContextProvider) {
        self.userIdentifier = userIdentifier
        self.requestAuthProvider = requestAuthProvider
        self.requestContextProvider = requestContextProvider
        super.init()
    }
}

// MARK:- Auth / Context Utilities

extension ASAPPUser {
    
    func getAuthToken() -> (String?, [String : Any]) {
        DebugLog.d("Requesting auth for user: \(userIdentifier)")
        
        let authJSON = requestAuthProvider()
        let accessToken = authJSON[ASAPP.AUTH_KEY_ACCESS_TOKEN] as? String
        
        DebugLog.d(caller: self, "Access Token: \(String(describing: accessToken)), from auth json: \(authJSON)")
        
        return (accessToken, authJSON)
    }
    
    func getContextString() -> String {
        let context = requestContextProvider()
        let contextString = JSONUtil.stringify(context)
        
        return contextString ?? ""
    }
}
