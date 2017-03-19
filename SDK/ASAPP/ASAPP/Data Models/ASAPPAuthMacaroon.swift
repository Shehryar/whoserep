//
//  ASAPPAuthMacaroon.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/26/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ASAPPAuthMacaroon: NSObject {
        
    // MARK: Public Properties
    
    let accessToken: String
    let issuedTime: Date
    let expiresAfterSeconds: TimeInterval
    
    // MARK: Internal Properties
    
    internal let expirationDate: Date
    
    internal var isValid: Bool {
        return !expirationDate.hasPassed()
    }

    // MARK: Initialization
    
    required init(accessToken: String, issuedTime: Date?, expiresAfterSeconds: TimeInterval?) {
        self.accessToken = accessToken
        self.issuedTime = issuedTime ?? Date()
        self.expiresAfterSeconds = expiresAfterSeconds ?? (60 /* seconds */ * 60 /* minutes */)
        self.expirationDate = Date(timeInterval: self.expiresAfterSeconds, since: self.issuedTime)
        super.init()
    }
    
    // MARK: JSON Parsing
    
    class func instanceWithJSON(json: [String : Any]?) -> ASAPPAuthMacaroon? {
        guard let json = json else { return nil }
        
        guard let accessToken = json[ASAPP.AUTH_KEY_ACCESS_TOKEN] as? String else {
            DebugLog.e("Missing \"access_token\" in auth dictionary")
            return nil
        }
        
        return ASAPPAuthMacaroon(accessToken: accessToken,
                                 issuedTime: json[ASAPP.AUTH_KEY_ISSUED_TIME] as? Date,
                                 expiresAfterSeconds: json[ASAPP.AUTH_KEY_EXPIRES_IN] as? TimeInterval)
    }
    
    func toJSON() -> [String : Any] {
        return [
            ASAPP.AUTH_KEY_ACCESS_TOKEN : accessToken,
            ASAPP.AUTH_KEY_EXPIRES_IN : expiresAfterSeconds,
            ASAPP.AUTH_KEY_ISSUED_TIME : issuedTime
        ]
    }
}


// MARK:- Storage

extension ASAPPAuthMacaroon {
    fileprivate class func storageKey(forCredentials credentials: Credentials) -> String {
        return credentials.hashKey(withPrefix: "AuthMacaroon:")
    }
    
    func save(withCredentials credentials: Credentials) {
        ASAPPAuthMacaroon.saveAuthMacaroon(macaroon: self, withCredentials: credentials)
    }
    
    class func saveAuthMacaroon(macaroon: ASAPPAuthMacaroon, withCredentials credentials: Credentials) {
        Dispatcher.performOnBackgroundThread {
            let json = macaroon.toJSON()
            let key = storageKey(forCredentials: credentials)
            
            UserDefaults.standard.set(json, forKey: key)
        }
    }
    
    class func getSavedAuthMacaroon(forCredentials credentials: Credentials) -> ASAPPAuthMacaroon? {
        let key = storageKey(forCredentials: credentials)
        if let storedJSON = UserDefaults.standard.object(forKey: key) as? [String : Any] {
            if let storedInstance = instanceWithJSON(json: storedJSON) {
                if storedInstance.isValid {
                    _debugLog("Successfully fetched and serialized valid auth macaroon")
                    return storedInstance
                } else {
                    _debugLog("Fetched expired auth macaroon.")
                    UserDefaults.standard.removeObject(forKey: key)
                }
            } else {
                _debugLog("Unable to serialize auth macaroon from json: \(storedJSON)")
                UserDefaults.standard.removeObject(forKey: key)
            }
        } else {
            _debugLog("No auth macaroon json found.")
        }
        
        return nil
    }
}

// MARK:- Logging

extension ASAPPAuthMacaroon {
    
    static let debugLoggingEnabled = false
    
    class func _debugLog(_ message: String) {
        if debugLoggingEnabled {
            DebugLog.d(message)
        }
    }
}

