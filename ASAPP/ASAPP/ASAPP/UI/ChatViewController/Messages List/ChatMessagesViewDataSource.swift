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
    
    var secondsBetweenSections: Int = (20 * 60)
    
    let allowedEventTypes: Set<EventType>
    
    private var allEvents = [Event]()
    
    private var eventsByTime = [[Event]]()
    
    // MARK: Init
    
    init(withAllowedEventTypes allowedEventTypes: Set<EventType>) {
        self.allowedEventTypes = allowedEventTypes
        super.init()
    }
    
    // MARK: Instance Methods
    
    func numberOfSections() -> Int {
        return eventsByTime.count
    }
    
    func numberOfRowsInSection(row: Int) -> Int {
        guard row >= 0 && row < eventsByTime.count else {
            return 0
        }
        return eventsByTime[row].count
    }
    
    func eventsForSection(section: Int) -> [Event]? {
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
    
    func eventForIndexPath(indexPath: NSIndexPath) -> Event? {
        return getEvent(inSection: indexPath.section, row: indexPath.row)
    }
    
    func indexPathOfEvent(event: Event?) -> NSIndexPath? {
        guard let event = event else {
            return nil
        }
        
        for (section, eventsAtTime) in eventsByTime.reverse().enumerate() {
            
            // Could skip over arrays here if the event happened before the first event's time
            
            for (row, currEvent) in eventsAtTime.reverse().enumerate() {
                if currEvent.eventLogSeq == event.eventLogSeq {
                    return NSIndexPath(forRow: row, inSection: section)
                }
            }
        }
        return nil
    }
    
    func timeStampInMicroSecondsForSection(section: Int) -> Double {
        guard let event = getEvent(inSection: section, row: 0) else {
            return 0
        }
        return event.eventTime
    }
    
    func timeStampInSecondsForSection(section: Int) -> Double {
        return timeStampInMicroSecondsForSection(section) / 1000000.0
    }
    
    func getLastEvent() -> Event? {
        return eventsByTime.last?.last
    }
    
    func isEmpty() -> Bool {
        return getEvent(inSection: 0, row: 0) == nil
    }
    
    // MARK:- Changing Content
    
    func reloadWithEvents(events: [Event]) {
        allEvents.removeAll()
        allEvents.appendContentsOf(events)
        eventsByTime.removeAll()
        
        let sortedEvents = events.sort { (event1, event2) -> Bool in
            return event1.eventLogSeq < event2.eventLogSeq
        }
        for event in sortedEvents {
            addEvent(event)
        }
    }
    
    func mergeWithEvents(newEvents: [Event]) {
        guard newEvents.count > 0 else {
            return
        }
        
        var dedupedEvents = [Event]()
    
        var setOfMessageEventLogSeqs = Set<Int>()
        func addOrSkipMessageEvent(event: Event) {
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
    
    func addEvent(event: Event) -> NSIndexPath? {
        guard allowedEventTypes.contains(event.eventType) else {
            return nil
        }
        
        // Empty case
        guard let lastEvent = getLastEvent() else {
            eventsByTime.append([event])
            return NSIndexPath(forRow: 0, inSection: 0)
        }
        
        // Insert not-at-end case
        if event.eventLogSeq < lastEvent.eventLogSeq {
            
            // TODO: support this
            
            fatalError("Must call addEvent in order.")
        }
        
        // Insert at end
        
        let maxTimeForSameSection = lastEvent.eventTime + Double(secondsBetweenSections * 1000000)
        if event.eventTime < maxTimeForSameSection {
            eventsByTime[eventsByTime.count - 1].append(event)
        } else {
            eventsByTime.append([event])
        }
        
        return indexPathOfEvent(event)
    }
}
