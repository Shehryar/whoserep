//
//  ASAPPUser.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

/// A type of closure that returns `[String: Any]`. The dictionary needs to contain the key-value pair `ASAPP.AUTH_KEY_ACCESS_TOKEN: authToken` where `authToken` is the user's authentication token.
public typealias ASAPPRequestContextProvider = (() -> [String: Any])

// MARK: - ASAPPUser

/**
 Holds configuration information pertaining to the current user session.
 */
@objc(ASAPPUser)
@objcMembers
public class ASAPPUser: NSObject {
    /// Whether the user is anonymous.
    public let isAnonymous: Bool
    
    /// Unique identifier for the user.
    public let userIdentifier: String
    
    /// Reference to context provider given at initialization.
    public let requestContextProvider: ASAPPRequestContextProvider

    // MARK: - Initialization
    
    /**
     Creates an `ASAPPUser` instance.
     
     - parameter userIdentifier: A unique `String` identifier for the user. If `nil`, the user is anonymous and a special identifier will be automatically generated.
     - parameter requestContextProvider: A function called to provide context information when making requests.
     - parameter userLoginHandler: A function called when the user login action is performed.
     */
    public init(userIdentifier: String?,
                requestContextProvider: @escaping ASAPPRequestContextProvider) {
        if let userIdentifier = userIdentifier {
            self.userIdentifier = userIdentifier
            self.isAnonymous = false
        } else {
            self.userIdentifier = ASAPPUser.createAnonymousIdentifier()
            self.isAnonymous = true
        }
        self.requestContextProvider = requestContextProvider
        super.init()
    }
    
    private class func createAnonymousIdentifier() -> String {
        return "anonymous_user_\(UUID().uuidString)"
    }
}

// MARK: - Auth / Context Utilities

extension ASAPPUser {
    
    typealias ContextRequestCompletion = ((_ context: [String: Any]?, _ authToken: String?) -> Void)
    
    func getContext(completion: @escaping ContextRequestCompletion) {
        Dispatcher.performOnBackgroundThread { [weak self] in
            let context = self?.requestContextProvider()
            let authToken = context?[ASAPP.authTokenKey] as? String
            
            completion(context, authToken)
        }
    }
}
