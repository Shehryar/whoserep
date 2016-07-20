//
//  ASAPPEventLog.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/16/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation
import RealmSwift

protocol ASAPPEventLogDelegate {
    func didProcessEvent(event: ASAPPEvent, isNew: Bool)
    func didClearEventLog()
}

class ASAPPEventLog: NSObject {
    
    var dataSource: ASAPPStateDataSource!
    var delegate: ASAPPEventLogDelegate!
    var store: ASAPPStore!
    
    var events: Results<ASAPPEvent>?
    
    convenience init(dataSource: ASAPPStateDataSource, delegate: ASAPPEventLogDelegate, store: ASAPPStore) {
        self.init()
        self.dataSource = dataSource
        self.delegate = delegate
        self.store = store
    }
    
    func load() {
        if events != nil || delegate == nil {
            return
        }
        
        events = store.mEventLog.sorted("EventLogSeq", ascending: true)
        for i in 0 ..< events!.count {
            let event = events![i]
            delegate.didProcessEvent(event, isNew: false)
        }
        
        if events?.last != nil {
            dataSource.fetchEvents((events?.last?.EventLogSeq)!)
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
        
        guard let createdTime = json["CreatedTime"] as? ASAPPCreatedTime,
            let issueId = json["IssueId"] as? ASAPPIssueId,
            let companyId = json["CompanyId"] as? ASAPPCompanyId,
            let customerId = json["CustomerId"] as? ASAPPCustomerId,
            let repId = json["RepId"] as? ASAPPRepId,
            let eventTime = json["EventTime"] as? ASAPPEventTime,
            let eventType = eventTypeEnumValue(json["EventType"]),
            let ephemeralType = ephemeralTypeEnumValue(json["EphemeralType"]),
            let eventFlags = json["EventFlags"] as? ASAPPEventFlag,
            let eventJSON = json["EventJSON"] as? ASAPPEventJSON
            else {
                return
        }
        
        let event = ASAPPEvent(createdTime: createdTime, issueId: issueId, companyId: companyId, customerId: customerId, repId: repId, eventTime: eventTime, eventType: eventType, ephemeralType: ephemeralType, eventFlags: eventFlags, eventJSON: eventJSON)
        
        if dataSource.isCustomer() {
            if let eventLogSeq = json["CustomerEventLogSeq"] as? Int {
                event.EventLogSeq = eventLogSeq
            }
        } else {
            if let eventLogSeq = json["CompanyEventLogSeq"] as? Int {
                event.EventLogSeq = eventLogSeq
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
    
    func eventTypeEnumValue(rawValue: AnyObject?) -> ASAPPEventType? {
        var enumValue: ASAPPEventType? = nil
        if let value = rawValue as? Int {
            enumValue = ASAPPEventType(value)
        }
        return enumValue
    }
    
    func ephemeralTypeEnumValue(rawValue: AnyObject?) -> ASAPPEphemeralType? {
        var enumValue: ASAPPEphemeralType? = nil
        if let value = rawValue as? Int {
            enumValue = ASAPPEphemeralType(value)
        }
        return enumValue
    }
    
    func saveEvent(event: ASAPPEvent) {
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