//
//  ASAPPConfig.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public typealias ASAPPAuthProvider = (() -> [String : Any])

public typealias ASAPPContextProvider = (() -> [String : Any])

public typealias ASAPPAppCallbackHandler = ((_ deepLink: String, _ deepLinkData: [String : Any]?) -> Void)

private let OLD_CLIENT_SECRET = "BD0ED4C975FF217D3FCD00A895130849E5521F517F0162F5D28D61D628B2B990"

// MARK:- ASAPPConfig

public class ASAPPConfig: NSObject {
    
    public let appId: String
    
    public let apiHostName: String
    
    public let clientId: String
    
    public let userIdentifier: String
    
    public let authProvider: ASAPPAuthProvider
    
    public let contextProvider: ASAPPContextProvider
    
    // MARK: Internal Properties
    
    internal var authMacaroon: ASAPPAuthMacaroon?
    
    // MARK: Init
    
    public init(appId: String,
                apiHostName: String,
                clientId: String,
                userIdentifier: String,
                authProvider: @escaping ASAPPAuthProvider,
                contextProvider: @escaping ASAPPContextProvider) {
        self.appId = appId
        self.apiHostName = apiHostName
        self.clientId = clientId
        self.userIdentifier = userIdentifier
        self.authProvider = authProvider
        self.contextProvider = contextProvider
        super.init()
        
        self.authMacaroon = ASAPPAuthMacaroon.getSavedAuthMacaroon(for: self)
    }
}

public extension ASAPPConfig {
    
    // MARK: DebugPrintable
    
    override public var description: String {
        return "\(appId) @ \(apiHostName) : \(userIdentifier)"
    }
    override public var debugDescription: String {
        return description
    }
    
    // MARK: Hash Key
    
    internal func hashKey(prefix: String? = nil) -> String {
        let key = "\(prefix ?? "")\(apiHostName))-\(appId)-cust-\(userIdentifier)-0"
        return key
    }
}

internal extension ASAPPConfig {
    
    /// Should be performed asynchronously
    internal func getAuthToken() -> String? {
        if let authMacaroon = authMacaroon {
            if authMacaroon.isValid {
                return authMacaroon.accessToken
            }
        }
        
        DebugLog.d("Calling host app for authentication")
        
        let authJSON = authProvider()
        
        // First try
        if let refreshedAuthMacaroon = ASAPPAuthMacaroon.instanceWithJSON(json: authJSON) {
            refreshedAuthMacaroon.save(for: self)
            authMacaroon = refreshedAuthMacaroon
            return refreshedAuthMacaroon.accessToken
        } else {
            DebugLog.e("Missing parameters in authProvider: \(authJSON)\n\nTo resolve this error, you must provide the \"access_token\" (String), and optionally, the \"issued_time\" (Date object), and \"expires_in\" (NSTimeInterval).")
        }
        
        // Retry
        if let refreshedAuthMacaroon = ASAPPAuthMacaroon.instanceWithJSON(json: authJSON) {
            refreshedAuthMacaroon.save(for: self)
            authMacaroon = refreshedAuthMacaroon
            return refreshedAuthMacaroon.accessToken
        }
        
        return nil
    }
    
    /// Can be performed synchronously
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
