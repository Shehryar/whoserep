//
//  Credentials.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/26/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

public typealias ASAPPCallbackHandler = ((_ deepLink: String, _ deepLinkData: [String : Any]?) -> Void)

public typealias ASAPPContextProvider = (() -> [String : Any])

public typealias ASAPPAuthProvider = (() -> [String : Any])


// MARK:- Credentials

public class Credentials: NSObject {
    
    // MARK: Public Properties
    
    public let environment: ASAPPEnvironment
    public let companyMarker: String
    public let isCustomer: Bool
    public let userToken: String?
    public let targetCustomerToken: String?
    
    public let authProvider: ASAPPAuthProvider
    public let contextProvider: ASAPPContextProvider
    public let callbackHandler: ASAPPCallbackHandler
    
    // MARK: Internal Properties
    
    internal var authMacaroon: ASAPPAuthMacaroon?
    
    // MARK: Initialization
    
    required public init(withCompany company: String,
                         userToken: String?,
                         isCustomer: Bool,
                         targetCustomerToken: String?,
                         environment: ASAPPEnvironment,
                         authProvider: @escaping ASAPPAuthProvider,
                         contextProvider: @escaping ASAPPContextProvider,
                         callbackHandler: @escaping ASAPPCallbackHandler) {
        
        self.companyMarker = company
        self.userToken = userToken
        self.isCustomer = isCustomer
        self.targetCustomerToken = targetCustomerToken
        self.environment = environment
        
        self.authProvider = authProvider
        self.contextProvider = contextProvider
        self.callbackHandler = callbackHandler
        
        super.init()
        
        self.authMacaroon = ASAPPAuthMacaroon.getSavedAuthMacaroon(forCredentials: self)
    }
    
    // MARK: DebugPrintable
    
    override open var description: String {
        if isCustomer {
            return "Customer @ \(companyMarker): \(userToken ?? "")"
        } else {
            return "Rep @ \(companyMarker): \(userToken ?? "") \(targetCustomerToken != nil ? "-> \(targetCustomerToken!)" : "")"
        }
    }
    override open var debugDescription: String {
        return description
    }
    
    func hashKey(withPrefix prefix: String? = nil) -> String {
        return "\(prefix ?? "")\(StringForASAPPEnvironment(environment))-\(companyMarker)-\(isCustomer ? "cust" : "rep")-\(userToken ?? "0")-\(targetCustomerToken ?? "0")"
    }
    
    // MARK: Instance Methods
    
    /// Should be performed asynchronously
    internal func getAuthToken() -> String? {
        if let authMacaroon = authMacaroon {
            if authMacaroon.isValid {
                return authMacaroon.accessToken
            }
        }
        
        DebugLog("Calling host app for auth credentials")
        
        let authJSON = authProvider()
    
        // First try
        if let refreshedAuthMacaroon = ASAPPAuthMacaroon.instanceWithJSON(json: authJSON) {
            refreshedAuthMacaroon.save(withCredentials: self)
            authMacaroon = refreshedAuthMacaroon
            return refreshedAuthMacaroon.accessToken
        } else {
            DebugLogError("Missing parameters in authProvider: \(authJSON)\n\nTo resolve this error, you must provide the \"access_token\" (String), and optionally, the \"issued_time\" (Date object), and \"expires_in\" (NSTimeInterval).")
        }
        
        // Retry
        if let refreshedAuthMacaroon = ASAPPAuthMacaroon.instanceWithJSON(json: authJSON) {
            refreshedAuthMacaroon.save(withCredentials: self)
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
