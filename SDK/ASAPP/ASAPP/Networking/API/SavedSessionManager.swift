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
    
    private init() {}
    
    func clearSession() {
        save(session: nil)
    }
    
    func save(session: Session?) {
        guard let session = session else {
            do {
                try CodableStorage.remove(sessionFileName, from: Session.defaultDirectory)
                DebugLog.d("Cleared saved session")
            } catch {
                DebugLog.e(error)
            }
            return
        }
        
        do {
            try CodableStorage.store(session, as: sessionFileName)
            DebugLog.d("Saved session for \(session.customer.primaryIdentifier ?? session.customer.id.description)")
        } catch {
            DebugLog.e(error)
        }
    }
    
    func getSession() -> Session? {
        do {
            if let session = try CodableStorage.retrieve(sessionFileName, as: Session.self) {
                DebugLog.d("Retrieved session for \(session.customer.primaryIdentifier ?? session.customer.id.description)")
                return session
            } else {
                DebugLog.d("Retrieved nil session: expired or non-existent")
                return nil
            }
        } catch {
            DebugLog.e(error)
            return nil
        }
    }
    
    private var sessionFileName: String {
        return "Stored-Session"
    }
}
