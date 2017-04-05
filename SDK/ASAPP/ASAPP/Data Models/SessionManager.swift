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
    
    let deviceIdentifier: String
    
    private let eventSequenceKey: String
    
    init(with config: ASAPPConfig) {
        self.config = config
        self.deviceIdentifier = SessionManager.getSavedDeviceIdentifier(for: config)
            ?? SessionManager.generateDeviceIdentifier(for: config)
        self.eventSequenceKey = config.hashKey(prefix: "ASAPP_EVENT_SEQUENCE_")

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
    
    private class func deviceIdentifierStorageKey(for config: ASAPPConfig) -> String {
        return config.hashKey(prefix: "ASAPP_DEVICE_ID_")
    }
    
    fileprivate class func generateDeviceIdentifier(for config: ASAPPConfig) -> String {
        let deviceIdentifier = UUID().uuidString
        let storageKey = deviceIdentifierStorageKey(for: config)
        
        UserDefaults.standard.set(deviceIdentifier, forKey: storageKey)
        
        return deviceIdentifier
    }
    
    fileprivate class func getSavedDeviceIdentifier(for config: ASAPPConfig) -> String? {
        let storageKey = deviceIdentifierStorageKey(for: config)
        let savedDeviceIdentifier = UserDefaults.standard.string(forKey: storageKey)
        
        return savedDeviceIdentifier
    }
}
