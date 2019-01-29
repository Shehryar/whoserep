//
//  SavedSessionManager.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 11/3/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation

protocol SavedSessionManagerProtocol {
    func clearSession()
    func save(session: Session?)
    func getSession() -> Session?
}

class SavedSessionManager: SavedSessionManagerProtocol {
    static let shared = SavedSessionManager()
    
    private var secureStorage: SecureStorageProtocol
    
    init(secureStorage: SecureStorageProtocol = SecureStorage.default) {
        self.secureStorage = secureStorage
    }
    
    func clearSession() {
        save(session: nil)
        PushNotificationsManager.clearRegisteredDevice()
    }
    
    func save(session: Session?) {
        guard let session = session else {
            do {
                try secureStorage.remove(sessionKey)
                DebugLog.d("Cleared saved session")
            } catch {
                DebugLog.w(error.localizedDescription)
            }
            return
        }
        
        do {
            try secureStorage.store(session, as: sessionKey)
            DebugLog.d("Saved session for \(session.customerPrimaryIdentifier ?? session.customerId.description)")
        } catch {
            DebugLog.e(error)
        }
    }
    
    func getSession() -> Session? {
        do {
            let session = try secureStorage.retrieve(sessionKey, as: Session.self)
            DebugLog.d("Retrieved session for \(session.customerPrimaryIdentifier ?? session.customerId.description)")
            return session
        } catch {
            DebugLog.e(error)
            return nil
        }
    }
    
    private var sessionKey: String {
        return "Stored-Session"
    }
}
