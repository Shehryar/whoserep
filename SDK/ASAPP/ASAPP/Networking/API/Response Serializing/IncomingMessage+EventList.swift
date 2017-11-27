//
//  IncomingMessage+EventList.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/18/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

// MARK: Event List

extension IncomingMessage {
    
    typealias Events = [Event]
    
    typealias EventsJSONArray = [[String: AnyObject]]
    
    typealias ErrorMessage = String
    
    struct ParsedEvents {
        let events: Events?
        let eventsJSONArray: EventsJSONArray?
        let errorMessage: ErrorMessage?
    }
    
    func parseEvents() -> ParsedEvents {
        
        var events: [Event]?
        var eventsJSONArray: [[String: AnyObject]]?
        var errorMessage: String?
        
        if type == .response {
            if let array = body?["EventList"] as? [[String: AnyObject]] ?? body?["Events"] as? [[String: AnyObject]] {
                events = [Event]()
                eventsJSONArray = [[String: AnyObject]]()
                for eventJSON in array {
                    if let event = Event.fromJSON(eventJSON) {
                        events?.append(event)
                        eventsJSONArray?.append(eventJSON)
                    }
                }
            }
        } else if type == .responseError {
            errorMessage = debugError
        }
        
        let numberOfEventsFetched = (events != nil ? events!.count : 0)
        if numberOfEventsFetched == 0 && errorMessage == nil {
            errorMessage = "No results returned."
        }
        
        DebugLog.d("Fetched \(numberOfEventsFetched) events\(errorMessage != nil ? " with error: \(errorMessage!)" : "")")
        
        return ParsedEvents(events: events, eventsJSONArray: eventsJSONArray, errorMessage: errorMessage)
    }
}
