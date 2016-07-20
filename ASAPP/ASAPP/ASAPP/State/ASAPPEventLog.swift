//
//  EventLog.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/16/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation
import RealmSwift

protocol EventLogDelegate {
    func didProcessEvent(event: Event, isNew: Bool)
    func didClearEventLog()
}

class EventLog: NSObject {
    
    var dataSource: ASAPPStateDataSource!
    var delegate: EventLogDelegate!
    var store: ASAPPStore!
    
    var events: Results<Event>?
    
    convenience init(dataSource: ASAPPStateDataSource, delegate: EventLogDelegate, store: ASAPPStore) {
        self.init()
        self.dataSource = dataSource
        self.delegate = delegate
        self.store = store
    }
    
    func load() {
        if events != nil || delegate == nil {
            return
        }
        
        events = store.mEventLog.sorted("eventLogSeq", ascending: true)
        for i in 0 ..< events!.count {
            let event = events![i]
            delegate.didProcessEvent(event, isNew: false)
        }
        
        if events?.last != nil {
            dataSource.fetchEvents((events?.last?.eventLogSeq)!)
        } else if delegate != nil {
            dataSource.fetchEvents(0)
        }
    }
    
    func processEvent(eventData: String, isNew: Bool) {
        var json: [String: AnyObject] = [:]
        do {
            json = try NSJSONSerialization.JSONObjectWithData(eventData.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as! [String: AnyObject]
        } catch let err as NSError {
            ASAPPLoge(err)
        } catch {
            ASAPPLoge("Unknown Error")
        }
        
        guard let createdTime = json["CreatedTime"] as? Int,
            let issueId = json["IssueId"] as? Int,
            let companyId = json["CompanyId"] as? Int,
            let customerId = json["CustomerId"] as? Int,
            let repId = json["RepId"] as? Int,
            let eventTime = json["EventTime"] as? Int,
            let eventType = eventTypeEnumValue(json["EventType"]),
            let ephemeralType = ephemeralTypeEnumValue(json["EphemeralType"]),
            let eventFlags = json["EventFlags"] as? Int,
            let eventJSON = json["EventJSON"] as? String
            else {
                return
        }
        
        let event = Event(createdTime: createdTime, issueId: issueId, companyId: companyId, customerId: customerId, repId: repId, eventTime: eventTime, eventType: eventType, ephemeralType: ephemeralType, eventFlags: eventFlags, eventJSON: eventJSON)
        
        if dataSource.isCustomer() {
            if let eventLogSeq = json["CustomerEventLogSeq"] as? Int {
                event.eventLogSeq = eventLogSeq
            }
        } else {
            if let eventLogSeq = json["CompanyEventLogSeq"] as? Int {
                event.eventLogSeq = eventLogSeq
            }
        }
//        event.state = state
//        if isNew {
            saveEvent(event)
//        }
        
        if delegate != nil {
            delegate.didProcessEvent(event, isNew: isNew)
        }
    }
    
    func eventTypeEnumValue(rawValue: AnyObject?) -> EventType? {
        var enumValue: EventType? = nil
        if let value = rawValue as? Int {
            enumValue = EventType(rawValue: value)
        }
        return enumValue
    }
    
    func ephemeralTypeEnumValue(rawValue: AnyObject?) -> EphemeralType? {
        var enumValue: EphemeralType? = nil
        if let value = rawValue as? Int {
            enumValue = EphemeralType(rawValue: value)
        }
        return enumValue
    }
    
    func saveEvent(event: Event) {
        store.addEvent(event)
    }
    
    func reloadEventLog() {
        
    }
    
    func clearAll() {
        ASAPPLog("CLEAR EVENTLOG")
        
        if delegate != nil {
            delegate.didClearEventLog()
        }
    }
}