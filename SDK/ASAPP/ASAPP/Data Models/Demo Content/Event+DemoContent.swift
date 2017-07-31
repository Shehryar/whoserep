//
//  Event+DemoContent.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/9/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit


enum DemoEventType {
    case billAutoPay
    case billCredit
    case billPaid
    case billPastDue
    case billSummary
    case troubleshooter
    case deviceRestart
    case equipmentReturn
    case techLocation
    case cancelAppointment
    case cancelAppointmentConfirmation
    case phoneUpgrade
    case phonePlanUpgrade
    case deviceTracking
    case scheduleAppointment
    case appointmentConfirmation
    case jsonStyleExample
    case addCreditCard
    case liveChatBegin
    case liveChatEnd
    case transactionHistory
    
    case chatFlowPayBill
    case chatFlowWaitOrCallback
    case chatFlowQueueEntered
    case chatFlowAgentEntered
    
    case dataUsage
    
    static let allTypes = [billAutoPay,
                           billCredit,
                           billPaid,
                           billPastDue,
                           billSummary,
                           troubleshooter,
                           deviceRestart,
                           equipmentReturn,
                           techLocation,
                           cancelAppointment,
                           cancelAppointmentConfirmation,
                           phonePlanUpgrade,
                           phoneUpgrade,
                           deviceTracking,
                           scheduleAppointment,
                           appointmentConfirmation,
                           jsonStyleExample,
                           addCreditCard,
                           liveChatBegin,
                           liveChatEnd,
                           transactionHistory,
                           chatFlowPayBill,
                           chatFlowWaitOrCallback,
                           chatFlowQueueEntered,
                           chatFlowAgentEntered,
                           dataUsage
                           ]
}

// MARK: Generic Sample Events

extension Event {
    
    class func demoEvent(type: EventType,
                         eventJSON: String,
                         afterEvent: Event? = nil,
                         eventLogSeq: Int? = nil) -> Event? {
        
        let eventTime: Double = Date().timeIntervalSince1970 * 1000000.0
        
        var companyEventLogSeq = 0
        var customerEventLogSeq = 0
        if let eventLogSeq = eventLogSeq {
            companyEventLogSeq = eventLogSeq
            customerEventLogSeq = eventLogSeq
        } else if let previousEventLogSeq = afterEvent?.eventLogSeq {
            companyEventLogSeq = previousEventLogSeq + 1
            customerEventLogSeq = companyEventLogSeq
        }
        
        let json = [
            "CreatedTime" : eventTime,
            "IssueId" :  afterEvent?.issueId ?? 350001,
            "CompanyId" : afterEvent?.companyId ?? 10001,
            "CustomerId" : afterEvent?.customerId ?? 130001,
            "RepId" : afterEvent?.repId ?? 20001,
            "EventTime" : eventTime,
            "EventType" : type.rawValue,
            "EphemeralType" : 0,
            "EventFlags" : 0,
            "CompanyEventLogSeq" : companyEventLogSeq,
            "CustomerEventLogSeq" : customerEventLogSeq,
            "EventJSON" : eventJSON
            ] as [String : Any]
        
        return Event.fromJSON(json)
    }
    
    class func demoEventWithJSONFile(_ fileName: String,
                                     afterEvent: Event? = nil,
                                     eventLogSeq: Int? = nil) -> Event? {
        
        if let jsonString = DemoUtils.jsonStringForFile(fileName) {
            let event = demoEvent(type: EventType.srsResponse,
                                  eventJSON: jsonString,
                                  afterEvent: afterEvent,
                                  eventLogSeq: eventLogSeq)
            return event
        }
        return nil
    }
}

// MARK: Specific Demo Events

extension Event {
    
    fileprivate class func jsonFileName(forEventType eventType: DemoEventType) -> String {
        switch eventType {
        case .billAutoPay: return "bill-autopay-scheduled"
        case .billCredit: return "bill-credit"
        case .billPaid: return "bill-paid"
        case .billPastDue: return "bill-past-due"
        case .billSummary: return "bill-summary"
        case .troubleshooter: return "troubleshooter"
        case .deviceRestart: return "device-restart"
        case .equipmentReturn: return "equipment-return"
        case .techLocation: return "tech-location"
        case .cancelAppointment: return "cancel-appointment"
        case .cancelAppointmentConfirmation: return "cancel-appointment-confirmation"
        case .phoneUpgrade:
            if UserDefaults.standard.bool(forKey: "ASAPP_DEMO_PHONE_UPGRADE_INELIGIBLE") {
                return "phone-upgrade-ineligible"
            } else {
                return "phone-upgrade"
            }
        case .phonePlanUpgrade: return "phone-plan-upgrade"
        case .deviceTracking: return "device-tracking"
        case .scheduleAppointment: return "schedule-appointment"
        case .appointmentConfirmation: return "appointment-confirmation"
        case .jsonStyleExample: return "json-style-example"
        case .addCreditCard: return "add-credit-card"
        case .liveChatBegin: return "live-chat-begin"
        case .liveChatEnd: return "live-chat-end"
        case .chatFlowPayBill: return "chat-flow-pay-bill"
        case .chatFlowWaitOrCallback: return "chat-flow-wait-or-callback"
        case .chatFlowQueueEntered: return "chat-flow-queue-entered"
        case .chatFlowAgentEntered: return "chat-flow-agent-entered"
        
        
        case .transactionHistory: return "transaction-history-message"
        case .dataUsage: return "data-usage-near-full-message"
        }
    }
    
    class func getDemoEvent(eventType: DemoEventType,
                            afterEvent: Event? = nil,
                            eventLogSeq: Int? = nil) -> Event? {
        let fileName = jsonFileName(forEventType: eventType)
        let demoEvent = demoEventWithJSONFile(fileName,
                                              afterEvent: afterEvent,
                                              eventLogSeq: eventLogSeq)
        return demoEvent
    }
    
    class func getDemoEventJsonString(eventType: DemoEventType) -> String? {
        let fileName = jsonFileName(forEventType: eventType)
        let jsonString = DemoUtils.jsonObjectAsStringForFile(fileName)
        
        return jsonString
    }
}

// MARK: Matching Demo Events to Queries

extension Event {
    
    class func demoResponseForQuery(_ query: String?) -> String? {
        guard let query = query else { return nil }
        
        if let demoEventType = demoEventTypeForResponseToQuery(query) {
            return Event.getDemoEventJsonString(eventType: demoEventType)
        }
        
        return nil
    }
    
    class func demoEventTypeForResponseToQuery(_ query: String) -> DemoEventType? {
        
        for demoEventType in DemoEventType.allTypes {
            if let triggeringStringSets = triggeringSubstringSet(demoEventType: demoEventType) {
                if query.containsAnySet(substringSets: triggeringStringSets) {
                    return demoEventType
                }
            }
        }
        return nil
    }
    
    fileprivate class func triggeringSubstringSet(demoEventType: DemoEventType) -> [[String]]? {
        switch demoEventType {
        case .chatFlowPayBill:
            return [
                ["pay", "my", "bill"]
            ]
            
        case .billAutoPay:
            return [
                ["bill", "auto"]
            ]
        
        case .billCredit:
            return [
                ["bill", "credit"]
            ]
            
        case .billPaid:
            return [
                ["bill", "paid"]
            ]
            
        case .billPastDue:
            return [
                ["bill", "past", "due"],
                ["bill", "overdue"]
            ]
            
        case .billSummary:
            return [
                ["what", "bill"],
                ["see", "bill"],
                ["what", "owe"],
                ["how", "owe"]
            ]
            
        case .equipmentReturn:
            return [
                ["where", "return"]
            ]
            
        case .phoneUpgrade:
            return [
                ["upgrade", "phone"],
                ["new", "phone"],
                ["change", "phone"]
            ]
            
        case .phonePlanUpgrade:
            return [
                ["add", "data"],
                ["upgrade", "plan"],
                ["change", "plan"]
            ]
            
        case .deviceTracking:
            return [
                ["where", "is", "device"],
                ["when", "will", "device"],
                ["where", "is", "package"],
                ["where", "is", "phone"],
                ["when", "will", "phone"]
            ]
            
        case .scheduleAppointment:
            return [
                ["schedule", "appointment"],
                ["make", "appointment"]
            ]
            
        case .appointmentConfirmation:
            return [
                ["schedule", "on 10/24/2016"],
                ["schedule", "on 10/25/2016"],
                ["schedule", "on 10/26/2016"],
                ["schedule", "on 10/27/2016"],
                ["schedule", "on 10/28/2016"],
            ]
            
        case .jsonStyleExample:
            return [
                ["json", "styl"]
            ]
            
        case .addCreditCard:
            return [
                ["add", "card"]
            ]
            
        case .transactionHistory:
            return [
                ["transaction", "history"]
            ]
            
        case .dataUsage:
            return [
                ["data", "usage"]
            ]
            
        case .troubleshooter, .deviceRestart, .techLocation, .cancelAppointment,
             .cancelAppointmentConfirmation, .liveChatBegin, .liveChatEnd,
             .chatFlowWaitOrCallback, .chatFlowQueueEntered, .chatFlowAgentEntered:
            return nil
        }
    }
}

extension String {
    func containsAll(substrings: [String]) -> Bool {
        guard !substrings.isEmpty else { return false }
        
        var containsAllSubstrings = true
        for substring in substrings {
            if !localizedCaseInsensitiveContains(substring) {
                containsAllSubstrings = false
                break
            }
        }
        return containsAllSubstrings
    }
    
    func containsAnySet(substringSets: [[String]]) -> Bool {
        guard !substringSets.isEmpty else { return false }
        
        for substringSet in substringSets {
            if containsAll(substrings: substringSet) {
                return true
            }
        }
        return false
    }
}
