//
//  SavedSessionManager.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 11/3/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation

class SavedSessionManager {
    private init() {}
    
    static func clearSession() {
        save(session: nil)
    }
    
    static func save(session: Session?) {
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
    
    static func getSession() -> Session? {
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
    
    private static var sessionFileName: String {
        return "Stored-Session"
    }
}
