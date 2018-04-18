//
//  ChatSimpleStore.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/26/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol UserDefaultsProtocol {
    func set(_ value: Any?, forKey defaultName: String)
    func removeObject(forKey defaultName: String)
    func object(forKey defaultName: String) -> Any?
    func string(forKey defaultName: String) -> String?
    func integer(forKey defaultName: String) -> Int
}

extension UserDefaults: UserDefaultsProtocol {}

class ChatSimpleStore: NSObject {
    
    let config: ASAPPConfig
    
    let user: ASAPPUser
    
    private let userDefaults: UserDefaultsProtocol
    
    required init(config: ASAPPConfig, user: ASAPPUser, userDefaults: UserDefaultsProtocol = UserDefaults.standard) {
        self.config = config
        self.user = user
        self.userDefaults = userDefaults
        super.init()
    }
}

// MARK: - Original SRS Search Query

extension ChatSimpleStore {
    
    private func srsOriginalSearchQueryKey() -> String {
        return config.hashKey(with: user, prefix: "SRSOriginalSearchQuery")
    }
    
    func updateSRSOriginalSearchQuery(query: String?) {
        if let query = query {
            DebugLog.d("Updated SRSOriginalSearchQuery: \(query)")
            userDefaults.set(query, forKey: srsOriginalSearchQueryKey())
        } else {
            DebugLog.d("Removed saved SRSOriginalSearchQuery")
            userDefaults.removeObject(forKey: srsOriginalSearchQueryKey())
        }
    }
    
    func getSRSOriginalSearchQuery() -> String? {
        let query = userDefaults.object(forKey: srsOriginalSearchQueryKey())
        
        if let query = query as? String {
            DebugLog.d("Found SRSOriginalSearchQuery: \(query)")
            return query
        }
        
        DebugLog.d("Unable to find SRSOriginalSearchQuery")
        return nil
    }
}
