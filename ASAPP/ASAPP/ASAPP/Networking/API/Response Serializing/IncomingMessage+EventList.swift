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
    
    typealias EventList = [Event]
    
    typealias EventsJSONArray = [[String : AnyObject]]
    
    typealias ErrorMessage = String
    
    func parseEventList() -> (EventList?, EventsJSONArray?, ErrorMessage?) {
        
        var eventList: [Event]?
        var eventsJSONArray: [[String : AnyObject]]?
        var errorMessage: String?
        
        if type == .Response {
            eventsJSONArray = (body?["EventList"] as? [[String : AnyObject]] ?? body?["Events"] as? [[String : AnyObject]])
            if let eventsJSONArray = eventsJSONArray {
                eventList = [Event]()
                for eventJSON in eventsJSONArray {
                    if let event = Event.fromJSON(eventJSON) {
                        eventList?.append(event)
                    }
                }
                
            }
        } else if type == .ResponseError {
            errorMessage = debugError
        }
        
        let numberOfEventsFetched = (eventList != nil ? eventList!.count : 0)
        if numberOfEventsFetched == 0 && errorMessage == nil {
            errorMessage = "No results returned."
        }
        
        DebugLog.d("Fetched \(numberOfEventsFetched) events\(errorMessage != nil ? " with error: \(errorMessage!)" : "")")
        
        return (eventList, eventsJSONArray, errorMessage)
    }
}
