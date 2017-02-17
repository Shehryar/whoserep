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
            DebugLog("Updated SRSOriginalSearchQuery: \(query)")
            UserDefaults.standard.set(query, forKey: srsOriginalSearchQueryKey())
        } else {
            DebugLog("Removed saved SRSOriginalSearchQuery")
            UserDefaults.standard.removeObject(forKey: srsOriginalSearchQueryKey())
        }
    }
    
    func getSRSOriginalSearchQuery() -> String? {
        let query = UserDefaults.standard.object(forKey: srsOriginalSearchQueryKey())
        
        if let query = query as? String {
            DebugLog("Found SRSOriginalSearchQuery: \(query)")
            return query
        }
        
        DebugLog("Unable to find SRSOriginalSearchQuery")
        return nil
    }
}

// MARK:- Suggested Reply History

extension ChatSimpleStore {
    
    private func suggestedReplyEventLogSeqsKey() -> String {
        return credentials.hashKey(withPrefix: "SuggestedReplyEventLogSeqs")
    }
    
    func updateSuggestedReplyEventLogSeqs(eventLogSeqs: [Int]?) {
        if let eventLogSeqs = eventLogSeqs {
            UserDefaults.standard.set(eventLogSeqs, forKey: suggestedReplyEventLogSeqsKey())
            
            DebugLog("Saved SuggestedReplyEventLogSeqs: \(eventLogSeqs)")
        } else {
            UserDefaults.standard.removeObject(forKey: suggestedReplyEventLogSeqsKey())
            
            DebugLog("Cleared SuggestedReplyEventLogSeqs")
        }
    }
    
    func getSuggestedReplyEventLogSeqs() -> [Int]? {
        let eventLogSeqs = UserDefaults.standard.object(forKey: suggestedReplyEventLogSeqsKey()) as? [Int]
        
        if let eventLogSeqs = eventLogSeqs {
            DebugLog("Fetched saved SuggestedReplyEventLogSeqs: \(eventLogSeqs)")
            
            return eventLogSeqs
        }
        
        DebugLog("No saved SuggestedReplyEventLogSeqs found")
        
        return nil
    }
    
    /**
     If the most recent reply-event is an SRSResponse, this will return (true, event). Otherwise, will return (false, nil)
     */
    func mostRecentReplyIsSRSResponse(fromEvent events: [Event]?) -> (Bool, Event?) {
        guard let events = events else {
            return (false, nil)
        }
        
        for (_, event) in events.enumerated().reversed() {
            if event.isCustomerEvent {
                continue
            }
            
            if event.eventType == .srsResponse {
                return (true, event)
            } else {
                return (false, nil)
            }
        }
        return (false, nil)
    }
    
    func getSuggestedReplyEvents(fromEvents allEvents: [Event]?) -> [Event]? {
        guard let allEvents = allEvents,
            let eventLogSeqs = getSuggestedReplyEventLogSeqs()
            else {
                return nil
        }
        
        let (mostRecentReplyIsSRS, mostRecentSRSEvent) = mostRecentReplyIsSRSResponse(fromEvent: allEvents)
        guard let lastSRSEvent = mostRecentSRSEvent else {
            return nil
        }
        guard mostRecentReplyIsSRS && eventLogSeqs.contains(lastSRSEvent.eventLogSeq) else {
            return nil
        }

        let eventLogSeqSet = Set(eventLogSeqs)
        
        var suggestedReplyEvents = [Event]()
        for (_, event) in allEvents.enumerated().reversed() {
            if eventLogSeqSet.contains(event.eventLogSeq) {
                suggestedReplyEvents.append(event)
            }
            if suggestedReplyEvents.count >= eventLogSeqSet.count {
                break
            }
        }
        suggestedReplyEvents = suggestedReplyEvents.reversed()
        
        return suggestedReplyEvents.count > 0 ? suggestedReplyEvents : nil
    }
}
