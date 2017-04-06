//
//  ASAPPUser.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public typealias ASAPPRequestAuthenticationBlock = (() -> [String : Any])

public typealias ASAPPRequestContextBlock = (() -> [String : Any])

// MARK:- ASAPPUser

public class ASAPPUser: NSObject {

    public let userIdentifier: String
    
    public let requestAuthenticationBlock: ASAPPRequestAuthenticationBlock
    
    public let requestContextBlock: ASAPPRequestContextBlock

    // MARK:- Init
    
    public init(userIdentifier: String,
                requestAuthenticationBlock: @escaping ASAPPRequestAuthenticationBlock,
                requestContextBlock: @escaping ASAPPRequestContextBlock) {
        self.userIdentifier = userIdentifier
        self.requestAuthenticationBlock = requestAuthenticationBlock
        self.requestContextBlock = requestContextBlock
        super.init()
    }
}

// MARK:- Auth / Context Utilities

extension ASAPPUser {
    
    func getAuthToken() -> (String?, [String : Any]) {
        DebugLog.d("Requesting auth for user: \(userIdentifier)")
        
        let authJSON = requestAuthenticationBlock()
        let accessToken = authJSON[ASAPP.AUTH_KEY_ACCESS_TOKEN] as? String
        
        DebugLog.d(caller: self, "Access Token: \(String(describing: accessToken)), from auth json: \(authJSON)")
        
        return (accessToken, authJSON)
    }
    
    func getContextString() -> String {
        let context = requestContextBlock()
        let contextString = JSONUtil.stringify(context)
        
        return contextString ?? ""
    }
}
