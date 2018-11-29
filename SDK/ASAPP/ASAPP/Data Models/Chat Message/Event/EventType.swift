//
//  EventType.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum EventType: Int {
    case unknown = -1
    case none = 0
    case textMessage = 1
    case newRep = 3
    case conversationEnd = 4
    case pictureMessage = 5
    case conversationTimedOut = 10
    case srsResponse = 22
    case srsAction = 24
    case switchSRSToChat = 28
    case accountMerge = 30
    case switchChatToSRS = 31
    
    static func from(_ value: Any?) -> EventType {
        guard let value = value as? Int else {
            return .unknown
        }
        return EventType(rawValue: value) ?? .unknown
    }
}

extension EventType {
    // MARK: Live Chat
    
    static func getLiveChatStatus(for type: EventType) -> Bool? {
        switch type {
        case conversationEnd, switchChatToSRS:
            return false
            
        case switchSRSToChat, newRep:
            return true
            
        default:
            return nil
        }
    }
}
