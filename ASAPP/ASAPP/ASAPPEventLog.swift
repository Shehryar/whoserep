//
//  ASAPPEventLog.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/16/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

protocol ASAPPEventLogDelegate {
    func didProcessEvent(event: ASAPPEvent, isNew: Bool)
}

typealias ASAPPTime = Int64
typealias ASAPPId = UInt64

enum ASAPPEventType: UInt16 {
    case EventTypeNone = 0
    case EventTypeTextMessage = 1
    case EventTypeNewIssue = 2
    case EventTypeNewRep = 3
    case EventTypeConversationEnd = 4
    case EventTypePictureMessage = 5
    case EventTypePrivateNote = 6
    case EventTypeNewIssueTopic = 7
    case EventTypeIssueEnqueued = 8
    case EventTypeConversationRated = 9
    case EventTypeCustomerTimedOut = 10
    case EventTypeCRMCustomerLinked = 11
    case EventTypeIssueSummarized = 12
    case EventTypeTextAnnotation = 13
    case EventTypeCustomerPrompt = 14
    case EventTypeCustomerConversationEnd = 15
    case EventTypeIssueAnnotation = 16
    case EventTypeWhisperMessage = 17
    case EventTypeCustomerFeedback = 18
    case EventTypeVCardMessage = 19
}

enum ASAPPEphemeralType: UInt16 {
    case EphemeralTypeNone = 0
    case EphemeralTypeTypingStatus = 1
    case EphemeralTypeTypingPreview = 2
    case EphemeralTypeCustomerCRMInfo = 3
    case EphemeralTypeUpdateCustomerIdentifiers = 4
    case EphemeralTypeConnectionUpdate = 5
    case EphemeralTypeIPBlock = 6
}

typealias ASAPPCreatedTime = ASAPPTime
typealias ASAPPIssueId = ASAPPId
typealias ASAPPCompanyId = ASAPPId
typealias ASAPPCustomerId = ASAPPId
typealias ASAPPRepId = ASAPPId
typealias ASAPPEventTime = ASAPPTime
typealias ASAPPEventFlag = UInt32
typealias ASAPPEventJSON = String

struct ASAPPEvent {
    let CreatedTime: ASAPPCreatedTime
    let IssueId: ASAPPIssueId
    let CompanyId: ASAPPCompanyId
    let CustomerId: ASAPPCustomerId
    let RepId: ASAPPRepId
    let EventTime: ASAPPEventTime
    let EventType: ASAPPEventType
    let EphemeralType: ASAPPEphemeralType
    let EventFlags: ASAPPEventFlag
    let EventJSON: ASAPPEventJSON
    
//    init() {
//        CreatedTime = 0
//        IssueId = 0
//        CompanyId = 0
//        CustomerId = 0
//        RepId = 0
//        EventTime = 0
//        EventType = ASAPPEventType.EventTypeNone
//        EphemeralType = ASAPPEphemeralType.EphemeralTypeNone
//        EventFlags = 0
//        EventJSON = "{}"
//    }
}

class ASAPPEventLog: NSObject {
    
    var delegate: ASAPPEventLogDelegate!
    var events: [ASAPPEvent] = []
    
    func processEvent(eventData: String, isNew: Bool) {
        var json: [String: AnyObject] = [:]
        do {
            json = try NSJSONSerialization.JSONObjectWithData(eventData.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as! [String: AnyObject]
        } catch let err as NSError {
            ASAPPLoge(err)
        }
        
        guard let createdTime = json["CreatedTime"] as? ASAPPCreatedTime,
            let issueId = json["IssueId"] as? ASAPPIssueId,
            let companyId = json["CompanyId"] as? ASAPPCompanyId,
            let customerId = json["CustomerId"] as? ASAPPCustomerId,
            let repId = json["RepId"] as? ASAPPRepId,
            let eventTime = json["EventTime"] as? ASAPPEventTime,
            let eventType = json["EventType"] as? ASAPPEventType,
            let ephemeralType = json["EphemeralType"] as? ASAPPEphemeralType,
            let eventFlags = json["EventFlags"] as? ASAPPEventFlag,
            let eventJSON = json["EventJSON"] as? ASAPPEventJSON
            else {
                return
        }
        
        let event = ASAPPEvent(CreatedTime: createdTime, IssueId: issueId, CompanyId: companyId, CustomerId: customerId, RepId: repId, EventTime: eventTime, EventType: eventType, EphemeralType: ephemeralType, EventFlags: eventFlags, EventJSON: eventJSON)
    
        if isNew {
            saveEvent(event)
        }
        
        if delegate != nil {
            delegate.didProcessEvent(event, isNew: isNew)
        }
    }
    
    func saveEvent(event: ASAPPEvent) {
        
    }
}