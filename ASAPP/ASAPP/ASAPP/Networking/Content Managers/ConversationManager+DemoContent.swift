//
//  ConversationManager+DemoContent.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/9/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

extension ConversationManager {
    
    // MARK: Sample Responses
    
    func demo_AppOpenResponse() -> AppOpenResponse? {
        guard ASAPP.isDemoContentEnabled() else { return nil }
        
        return AppOpenResponse.sampleResponse(forCompany: credentials.companyMarker)
    }
}

// MARK:- Overriding SRS Button Actions

extension ConversationManager {
    
    class func demo_CanOverrideButtonItemSelection(buttonItem: SRSButtonItem) -> Bool {
        guard ASAPP.isDemoContentEnabled() else { return false }
        
        switch buttonItem.action.type {
        case .link:
            if ["troubleshoot", "restartdevicenow"].contains(buttonItem.action.name.lowercased()) {
                return true
            }
            break
            
        case .treewalk:
            if ["cancelAppointmentPrompt",
                "cancelAppointmentConfirmation",
                "chatWithAnAgent",
                "waitForAnAgent"].contains(buttonItem.action.name) {
                return true
            }
            break
        
        default:
            // No-op
            break
        }
        return false
    }
    
    func demo_OverrideStartSRS(completion: ((_ response: AppOpenResponse) -> Void)? = nil) -> Bool {
        guard ASAPP.isDemoContentEnabled() else { return false }
        
        if let demoResponse = self.demo_AppOpenResponse() {
            completion?(demoResponse)
            return true
        }
        
        return false
    }
    
    func demo_TriggerFakeAgentEntered() {
        guard ASAPP.isDemoContentEnabled() else { return }
        
        sendFakeAgentEnteredConversationEvent()
    }
    
    func demo_OverrideButtonItemSelection(buttonItem: SRSButtonItem, completion: IncomingMessageHandler? = nil) -> Bool {
        guard ASAPP.isDemoContentEnabled() else { return false }
        
        switch buttonItem.action.type {
        case .treewalk:
            switch buttonItem.action.name {
            case "cancelAppointmentPrompt":
                _sendMessage(buttonItem.title, completion: completion)
                sendFakeCancelAppointmentMessage()
                return true
                
            case "cancelAppointmentConfirmation":
                _sendMessage(buttonItem.title, completion: completion)
                sendFakeCancelAppointmentConfirmationMessage()
                return true
                
            case "chatWithAnAgent":
                _sendMessage(buttonItem.title, completion: completion)
                sendFakeChatWithAnAgentMessage()
                return true
                
            case "waitForAnAgent":
                _sendMessage(buttonItem.title, completion: completion)
                sendFakeWaitForAnAgentMessage()
                return true
                
            default: return false
            }
            break
            
        case.link:
            switch buttonItem.action.name.lowercased() {
            case "troubleshoot":
                _sendMessage(buttonItem.title, completion: completion)
                sendFakeTroubleshooterMessage(buttonItem)
                return true
                
            case "restartdevicenow":
                _sendMessage(buttonItem.title, completion: completion)
                sendFakeDeviceRestartMessage(buttonItem)
                return true
                
            default: return false
            }
            break
        
        default: return false
        }
    }
    
    func demo_OverrideMessageSend(message: String, completion: (() -> Void)? = nil) -> Bool {
        guard ASAPP.isDemoContentEnabled() else { return false }
        
        if message.containsAnySet(substringSets: [["switch", "to", "srs"], ["talk", "to", "srs"]])
                || message.containsAnySet(substringSets: [["switch", "to", "agent"], ["talk", "to", "agent"] , ["switch", "live", "chat"]]) {
            if let demoResponse = Event.demoResponseForMessage(message: message,
                                                               company: credentials.companyMarker) {
                _sendMessage(message)
                echoMessageResponse(withJSONString: demoResponse)
                return true
            }
        }
        
        if let demoResponse = Event.demoResponseForMessage(message: message,
                                                           company: credentials.companyMarker) {
            _sendMessage(message)
            echoMessageResponse(withJSONString: demoResponse)
            return true
        }
        
        return false
    }
}

// MARK:- Overriding Incoming Messages

extension ConversationManager {
    
    func demo_OverrideReceivedMessageEvent(event: Event) -> Bool {
        guard ASAPP.isDemoContentEnabled() else { return false }
        
        if event.srsResponse?.classification == "BR" {
            sendFakeEquipmentReturnMessage()
            return true
        }
        if event.srsResponse?.classification == "ST" {
            sendFakeTechLocationMessage()
            return true
        }
        
        return false
    }
}

// MARK:- Sending Fake Data

extension ConversationManager {
    
    // MARK: Generic
    
    func sendDemoMessageEvent(_ message: Event?) {
        guard let message = message else { return }
        
        Dispatcher.delay(600, closure: {
            self.delegate?.conversationManager(self, didReceiveMessageEvent: message)
        })
    }
    
    func echoMessageResponse(withJSONString jsonString: String?) {
        guard let jsonString = jsonString else { return }
        
        let editedString = jsonString.replacingOccurrences(of: "\n", with: "")
        
        socketConnection.sendRequest(withPath: "srs/Echo",
                                     params: ["Echo" : editedString as AnyObject])
        { (incomingMessage) in
            // no-op
            
        }
    }
    
    // MARK: Specific
    
    func sendFakeTroubleshooterMessage(_ buttonItem: SRSButtonItem) {
        let jsonString = Event.getDemoEventJsonString(eventType: .troubleshooter,
                                                      company: credentials.companyMarker)
        echoMessageResponse(withJSONString: jsonString)
    }
    
    func sendFakeDeviceRestartMessage(_ buttonItem: SRSButtonItem) {
        var deviceRestartString = Event.getDemoEventJsonString(eventType: .deviceRestart,
                                                               company: credentials.companyMarker)
        let finishedAt = Int(Date(timeIntervalSinceNow: 15).timeIntervalSince1970)
        deviceRestartString = deviceRestartString?.replacingOccurrences(of: "\"loaderBar\"", with: "\"loaderBar\", \"finishedAt\" : \(finishedAt)")
        
        echoMessageResponse(withJSONString: deviceRestartString)
    }
    
    func sendFakeCancelAppointmentMessage() {
        let jsonString = Event.getDemoEventJsonString(eventType: .cancelAppointment,
                                                      company: credentials.companyMarker)
        
        echoMessageResponse(withJSONString: jsonString)
    }
    
    func sendFakeCancelAppointmentConfirmationMessage() {
        let jsonString = Event.getDemoEventJsonString(eventType: .cancelAppointmentConfirmation,
                                                      company: credentials.companyMarker)
        echoMessageResponse(withJSONString: jsonString)
    }
    
    func sendFakeChatWithAnAgentMessage() {
        let jsonString = Event.getDemoEventJsonString(eventType: .chatFlowWaitOrCallback,
                                                      company: credentials.companyMarker)
        echoMessageResponse(withJSONString: jsonString)
    }
    
    func sendFakeWaitForAnAgentMessage() {
        let jsonString = Event.getDemoEventJsonString(eventType: .chatFlowQueueEntered,
                                                      company: credentials.companyMarker)
        echoMessageResponse(withJSONString: jsonString)
    }
    
    func sendFakeAgentEnteredConversationEvent() {
        let jsonString = Event.getDemoEventJsonString(eventType: .chatFlowAgentEntered,
                                                      company: credentials.companyMarker)
        echoMessageResponse(withJSONString: jsonString)
    }
    
    // MARK: Mock Data overriding responses
    
    func sendFakeEquipmentReturnMessage(_ eventLogSeq: Int? = nil) {
        let demoEvent = Event.getDemoEvent(eventType: .equipmentReturn,
                                           eventLogSeq: eventLogSeq)
        sendDemoMessageEvent(demoEvent)
    }
    
    func sendFakeTechLocationMessage(_ eventLogSeq: Int? = nil) {
        let demoEvent = Event.getDemoEvent(eventType: .techLocation,
                                           eventLogSeq: eventLogSeq)
        sendDemoMessageEvent(demoEvent)
    }
    
    func sendScheduleAppointmentMessage(_ eventLogSeq: Int? = nil) {
        let demoEvent = Event.getDemoEvent(eventType: .scheduleAppointment,
                                           eventLogSeq: eventLogSeq)
        sendDemoMessageEvent(demoEvent)
    }
}
