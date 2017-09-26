//
//  SessionManager.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 12/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SessionManager: NSObject {

    let config: ASAPPConfig
    
    let user: ASAPPUser
    
    let deviceIdentifier: String
    
    private let eventSequenceKey: String
    
    init(config: ASAPPConfig, user: ASAPPUser) {
        self.config = config
        self.user = user
        self.deviceIdentifier = SessionManager.getSavedDeviceIdentifier(for: config, user: user)
            ?? SessionManager.generateDeviceIdentifier(for: config, user: user)
        self.eventSequenceKey = config.hashKey(with: user, prefix: "ASAPP_EVENT_SEQUENCE_")

        super.init()
        
        DebugLog.d("Created Session:\nDevice Identifier: \(deviceIdentifier)\nEvent sequence: \(previousEventSequence())")
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
    
    private class func deviceIdentifierStorageKey(for config: ASAPPConfig, user: ASAPPUser) -> String {
        return config.hashKey(with: user, prefix: "ASAPP_DEVICE_ID_")
    }
    
    private class func generateDeviceIdentifier(for config: ASAPPConfig, user: ASAPPUser) -> String {
        let deviceIdentifier = UUID().uuidString
        let storageKey = deviceIdentifierStorageKey(for: config, user: user)
        
        UserDefaults.standard.set(deviceIdentifier, forKey: storageKey)
        
        return deviceIdentifier
    }
    
    private class func getSavedDeviceIdentifier(for config: ASAPPConfig, user: ASAPPUser) -> String? {
        let storageKey = deviceIdentifierStorageKey(for: config, user: user)
        let savedDeviceIdentifier = UserDefaults.standard.string(forKey: storageKey)
        
        return savedDeviceIdentifier
    }
}
