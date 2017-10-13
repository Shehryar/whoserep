//
//  ChatSimpleStore.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/26/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatSimpleStore: NSObject {
    
    let config: ASAPPConfig
    
    let user: ASAPPUser
    
    required init(config: ASAPPConfig, user: ASAPPUser) {
        self.config = config
        self.user = user
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
            UserDefaults.standard.set(query, forKey: srsOriginalSearchQueryKey())
        } else {
            DebugLog.d("Removed saved SRSOriginalSearchQuery")
            UserDefaults.standard.removeObject(forKey: srsOriginalSearchQueryKey())
        }
    }
    
    func getSRSOriginalSearchQuery() -> String? {
        let query = UserDefaults.standard.object(forKey: srsOriginalSearchQueryKey())
        
        if let query = query as? String {
            DebugLog.d("Found SRSOriginalSearchQuery: \(query)")
            return query
        }
        
        DebugLog.d("Unable to find SRSOriginalSearchQuery")
        return nil
    }
}
