//
//  SessionManager.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 12/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SessionManager: NSObject {

    let credentials: Credentials;
    
    let deviceIdentifier: String
    
    private let eventSequenceKey: String
    
    required init(credentials: Credentials) {
        self.credentials = credentials
        self.deviceIdentifier = SessionManager.getSavedDeviceIdentifier(forCredentials: credentials)
            ?? SessionManager.generateDeviceIdentifier(forCredentials: credentials)
        self.eventSequenceKey = credentials.hashKey(withPrefix: "ASAPP_EVENT_SEQUENCE_")

        super.init()
        
        DebugLog("\nDevice Identifier: \(deviceIdentifier)\nEvent sequence: \(previousEventSequence())\n\n")
    }
    
    func getNextEventSequence() -> Int {
        let nextEventSequence = previousEventSequence() + 1
        
        UserDefaults.standard.set(nextEventSequence, forKey: eventSequenceKey)
        
        return nextEventSequence
    }
    
    /// Returns without incrementing
    func previousEventSequence() -> Int {
        return UserDefaults.standard.integer(forKey: eventSequenceKey)
    }
}

// MARK: UUID Helper

extension SessionManager {
    
    private class func deviceIdentifierStorageKey(forCredentials credentials: Credentials) -> String {
        return credentials.hashKey(withPrefix: "ASAPP_DEVICE_ID_")
    }
    
    fileprivate class func generateDeviceIdentifier(forCredentials credentials: Credentials) -> String {
        let deviceIdentifier = UUID().uuidString
        let storageKey = deviceIdentifierStorageKey(forCredentials: credentials)
        
        UserDefaults.standard.set(deviceIdentifier, forKey: storageKey)
        
        return deviceIdentifier
    }
    
    fileprivate class func getSavedDeviceIdentifier(forCredentials credentials: Credentials) -> String? {
        let storageKey = deviceIdentifierStorageKey(forCredentials: credentials)
        let savedDeviceIdentifier = UserDefaults.standard.string(forKey: storageKey)
        
        return savedDeviceIdentifier
    }
}
