//
//  ChatMessagesViewDataSource.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/29/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatMessagesViewDataSource: NSObject {

    // MARK: Properties
    
    var secondsBetweenSections: Int = (4 * 60)
    
    let supportedEventTypes: Set<EventType>
    
    fileprivate(set) var allEvents = [Event]()
    
    fileprivate var eventsByTime = [[Event]]()
    
    // MARK: Init
    
    init(withSupportedEventTypes supportedEventTypes: Set<EventType>) {
        self.supportedEventTypes = supportedEventTypes
        super.init()
    }
    
    // MARK: Instance Methods
    
    func numberOfSections() -> Int {
        return eventsByTime.count
    }
    
    func numberOfRowsInSection(_ row: Int) -> Int {
        guard row >= 0 && row < eventsByTime.count else {
            return 0
        }
        return eventsByTime[row].count
    }
    
    func eventsForSection(_ section: Int) -> [Event]? {
        guard section >= 0 && section < eventsByTime.count else {
            return nil
        }
        return eventsByTime[section]
    }
    
    func getEvent(inSection section: Int, row: Int) -> Event? {
        if let eventsInSection = eventsForSection(section) {
            if row >= 0 && row < eventsInSection.count {
                return eventsInSection[row]
            }
        }
        return nil
    }
    
    func eventForIndexPath(_ indexPath: IndexPath) -> Event? {
        return getEvent(inSection: (indexPath as NSIndexPath).section, row: (indexPath as NSIndexPath).row)
    }
    
    func indexPathOfEvent(_ event: Event?) -> IndexPath? {
        guard let event = event else {
            return nil
        }
        
        for (section, eventsAtTime) in eventsByTime.enumerated().reversed() {
            
            // Could skip over arrays here if the event happened before the first event's time
            
            for (row, currEvent) in eventsAtTime.enumerated().reversed() {
                if currEvent.eventLogSeq == event.eventLogSeq {
                    return IndexPath(row: row, section: section)
                }
            }
        }
        return nil
    }
    
    func timeStampInMicroSecondsForSection(_ section: Int) -> Double {
        guard let event = getEvent(inSection: section, row: 0) else {
            return 0
        }
        return event.eventTime
    }
    
    func timeStampInSecondsForSection(_ section: Int) -> Double {
        return timeStampInMicroSecondsForSection(section) / 1000000.0
    }
    
    func getLastEvent() -> Event? {
        return eventsByTime.last?.last
    }
    
    func isEmpty() -> Bool {
        return getEvent(inSection: 0, row: 0) == nil
    }
    
    // MARK:- Changing Content
    
    func reloadWithEvents(_ events: [Event]) {
        allEvents.removeAll()
        allEvents.append(contentsOf: events)
        
        eventsByTime.removeAll()
        
        let sortedEvents = allEvents.sorted { (event1, event2) -> Bool in
            return event1.eventLogSeq < event2.eventLogSeq
        }
        for event in sortedEvents {
            _ = addEvent(event)
        }
    }
    
    func mergeWithEvents(_ newEvents: [Event]) {
        guard newEvents.count > 0 else {
            return
        }
        
        var dedupedEvents = [Event]()
    
        var setOfMessageEventLogSeqs = Set<Int>()
        func addOrSkipMessageEvent(_ event: Event) {
            if !setOfMessageEventLogSeqs.contains(event.eventLogSeq) {
                dedupedEvents.append(event)
                setOfMessageEventLogSeqs.insert(event.eventLogSeq)
            }
        }
        
        // Favor newMessageEvents over old
        for event in newEvents { addOrSkipMessageEvent(event) }
        for event in allEvents { addOrSkipMessageEvent(event) }

        reloadWithEvents(dedupedEvents)
    }
    
    func addEvent(_ event: Event) -> IndexPath? {
        guard supportedEventTypes.contains(event.eventType) else {
            return nil
        }
        
        allEvents.append(event)
        
        // Empty case
        guard let lastEvent = getLastEvent() else {
            eventsByTime.append([event])
            return IndexPath(row: 0, section: 0)
        }
        
//        // Insert not-at-end case
//        if event.eventLogSeq < lastEvent.eventLogSeq {
//            
//            // TODO: support this
//            
//            fatalError("Must call addEvent in order.")
//        }
//        
        // Insert at end
        
        let maxTimeForSameSection = lastEvent.eventTime + Double(secondsBetweenSections * 1000000)
        if event.eventTime < maxTimeForSameSection {
            eventsByTime[eventsByTime.count - 1].append(event)
        } else {
            eventsByTime.append([event])
        }
        
        return indexPathOfEvent(event)
    }
    
    func updateEvent(updatedEvent: Event) -> IndexPath? {
        var allEventsIndex: Int?
        for (idx, event) in allEvents.enumerated() {
            if event.eventLogSeq == updatedEvent.eventLogSeq {
                // Update the updatedEvent's times to the original times
                updatedEvent.createdTime = event.createdTime
                updatedEvent.eventTime = event.eventTime
                
                allEventsIndex = idx
                break
            }
        }
        
        var eventsByTimeIndex: Int?
        var eventsByTimeEventsIndex: Int?
        for (eventsIdx, anEventsByTimeArray) in eventsByTime.enumerated() {
            
            for (eventIdx, event) in anEventsByTimeArray.enumerated() {
                if event.eventLogSeq == updatedEvent.eventLogSeq {
                    eventsByTimeIndex = eventsIdx
                    eventsByTimeEventsIndex = eventIdx
                    break
                }
            }
        }
        
        if let allEventsIndex = allEventsIndex,
            let eventsByTimeIndex = eventsByTimeIndex,
            let eventsByTimeEventsIndex = eventsByTimeEventsIndex {
            
            allEvents[allEventsIndex] = updatedEvent
            eventsByTime[eventsByTimeIndex][eventsByTimeEventsIndex] = updatedEvent
            
            let updatedIndex = indexPathOfEvent(updatedEvent)
    
            return updatedIndex
        }
        
        return nil
    }
}
