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
    
    typealias EventsJSONArray = [[String : AnyObject]]
    
    typealias ErrorMessage = String
    
    func parseEvents() -> (Events?, EventsJSONArray?, ErrorMessage?) {
        
        var events: [Event]?
        var eventsJSONArray: [[String : AnyObject]]?
        var errorMessage: String?
        
        if type == .Response {
            eventsJSONArray = (body?["EventList"] as? [[String : AnyObject]] ?? body?["Events"] as? [[String : AnyObject]])
            if let eventsJSONArray = eventsJSONArray {
                events = [Event]()
                for eventJSON in eventsJSONArray {
                    if let event = Event.fromJSON(eventJSON) {
                        events?.append(event)
                    }
                }
                
            }
        } else if type == .ResponseError {
            errorMessage = debugError
        }
        
        let numberOfEventsFetched = (events != nil ? events!.count : 0)
        if numberOfEventsFetched == 0 && errorMessage == nil {
            errorMessage = "No results returned."
        }
        
        DebugLog.d("Fetched \(numberOfEventsFetched) events\(errorMessage != nil ? " with error: \(errorMessage!)" : "")")
        
        return (events, eventsJSONArray, errorMessage)
    }
}
