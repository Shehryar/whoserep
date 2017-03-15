//
//  ChatSimpleStore.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/26/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatSimpleStore: NSObject {
    
    let credentials: Credentials
    
    required init(credentials: Credentials) {
        self.credentials = credentials
        super.init()
    }
}

// MARK:- Original SRS Search Query

extension ChatSimpleStore {
    
    private func srsOriginalSearchQueryKey() -> String {
        return credentials.hashKey(withPrefix: "SRSOriginalSearchQuery")
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

// MARK:- Suggested Reply History

extension ChatSimpleStore {
    
    private func quickReplyEventIdsKey() -> String {
        return credentials.hashKey(withPrefix: "SuggestedReplyEventLogSeqs")
    }
    
    func updateQuickReplyEventIds(_ eventIds: [Int]?) {
        if let eventIds = eventIds {
            UserDefaults.standard.set(eventIds, forKey: quickReplyEventIdsKey())
            
            DebugLog.d("Saved QuickReplyEventIds: \(eventIds)")
        } else {
            UserDefaults.standard.removeObject(forKey: quickReplyEventIdsKey())
            
            DebugLog.d("Cleared QuickReplyEventIds")
        }
    }
    
    func getQuickReplyEventIds() -> [Int]? {
        let eventIds = UserDefaults.standard.object(forKey: quickReplyEventIdsKey()) as? [Int]
        
        if let eventIds = eventIds {
            DebugLog.d("Fetched saved QuickReplyEventIds: \(eventIds)")
            return eventIds
        }
        
        DebugLog.d("No saved QuickReplyEventIds found")
        
        return nil
    }
    
    func mostRecentReplyMessageIfHasQuickReplies(fromEvents events: [Event]?) -> ChatMessage? {
        guard let events = events else {
            return nil
        }
        
        for (_, event) in events.enumerated().reversed() {
            if event.isReply {
                if let message = event.chatMessage,
                    message.quickReplies != nil {
                    return message
                }
            }
        }
        return nil
    }
    
    func getQuickReplyMessages(fromEvents events: [Event]?) -> [ChatMessage]? {
        guard let events = events, let eventIds = getQuickReplyEventIds() else {
            return nil
        }
        
        guard let lastQuickReplyMessage = mostRecentReplyMessageIfHasQuickReplies(fromEvents: events) else {
            return nil
        }
        

        let eventIdsSet = Set(eventIds)
        
        var quickReplyMessages = [ChatMessage]()
        for (_, event) in events.enumerated().reversed() {
            
            if eventIdsSet.contains(event.eventLogSeq),
                let message = event.chatMessage,
                message.quickReplies != nil {
                
                quickReplyMessages.append(message)
                
                if quickReplyMessages.count >= eventIdsSet.count {
                    break
                }
            }
        }
        quickReplyMessages = quickReplyMessages.reversed()
        
        return quickReplyMessages.count > 0 ? quickReplyMessages : nil
    }
}
