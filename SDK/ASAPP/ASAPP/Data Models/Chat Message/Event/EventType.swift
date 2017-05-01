//
//  EventType.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum EventType: Int {
    case none = 0
    case textMessage = 1
    case newRep = 3
    case conversationEnd = 4
    case pictureMessage = 5
    case conversationTimedOut = 10
    case srsResponse = 22
    case srsEcho = 23
    case srsAction = 24
    case scheduleAppointment = 27
    case switchSRSToChat = 28
    
    static func from(_ value: Any?) -> EventType? {
        guard let value = value as? Int else {
            return nil
        }
        return EventType(rawValue: value)
    }
}

extension EventType {
    
    // MARK: Chat Message
    
    static func typeMayContainMessage(_ type: EventType) -> Bool {
        return [
            srsResponse,
            srsEcho,
            srsAction,
            newRep,
            conversationEnd,
            conversationTimedOut,
            switchSRSToChat
        ].contains(type)
    }
    
    // MARK: Live Chat
    
    static func getLiveChatStatus(for type: EventType) -> Bool? {
        switch type {
        case conversationEnd:
            return false
            
        case switchSRSToChat, newRep:
            return true
            
        default:
            return nil
        }
    }
    
    static func getLiveChatStatus(from events: [Event]) -> Bool {
        var liveChat = false
        for (_, event) in events.enumerated().reversed() {
            if let liveChatStatus = EventType.getLiveChatStatus(for: event.eventType) {
                liveChat = liveChatStatus
                break
            }
        }
        return liveChat
    }
}
