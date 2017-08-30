//
//  ASAPPUser.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public typealias ASAPPRequestContextProvider = (() -> [String : Any])

public typealias ASAPPUserLoginHandlerCompletion = ((_ newUser: ASAPPUser) -> Void)

public typealias ASAPPUserLoginHandler = ((_ onUserLogin: @escaping ASAPPUserLoginHandlerCompletion) -> Void)

// MARK:- ASAPPUser

public class ASAPPUser: NSObject {

    public let isAnonymous: Bool
    
    public let userIdentifier: String
    
    public let requestContextProvider: ASAPPRequestContextProvider
    
    public let userLoginHandler: ASAPPUserLoginHandler
    
    // MARK:- Internal properties
    
    internal var sessionInfo: String?

    // MARK:- Init
    
    public init(userIdentifier: String?,
                requestContextProvider: @escaping ASAPPRequestContextProvider,
                userLoginHandler: @escaping ASAPPUserLoginHandler) {
        if let userIdentifier = userIdentifier {
            self.userIdentifier = userIdentifier
            self.isAnonymous = false
        } else {
            self.userIdentifier = ASAPPUser.createAnonymousIdentifier()
            self.isAnonymous = true
        }
        self.requestContextProvider = requestContextProvider
        self.userLoginHandler = userLoginHandler
        super.init()
    }
    
    private class func createAnonymousIdentifier() -> String {
        return "anonymous_user_\(UUID().uuidString)"
    }
}

// MARK:- Auth / Context Utilities

extension ASAPPUser {
    
    typealias ContextRequestCompletion = ((_ context: [String : Any]?, _ authToken: String?) -> Void)
    
    func getContext(completion: @escaping ContextRequestCompletion) {
        Dispatcher.performOnBackgroundThread { [weak self] in
            let context = self?.requestContextProvider()
            let authToken = context?[ASAPP.AUTH_KEY_ACCESS_TOKEN] as? String
            
            completion(context, authToken)
        }
    }
}
