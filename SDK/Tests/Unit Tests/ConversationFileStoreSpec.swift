//
//  ConversationFileStoreSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 4/12/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class ConversationFileStoreSpec: QuickSpec {
    override func spec() {
        var url: URL!
        
        TestUtil.setUpASAPP()
        
        let fileName = "\(ASAPP.config.hashKey(with: ASAPP.user, prefix: "Stored-Events_")).txt"
        if let dir = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory,
            FileManager.SearchPathDomainMask.allDomainsMask,
            true).first {
            url = NSURL(fileURLWithPath: dir).appendingPathComponent(fileName)!
        }
        
        describe("ConversationFileStore") {
            
            func createTestEventDict(time: TimeInterval = Date().timeIntervalSince1970) -> [String: Any] {
                return [
                    "CreatedTime": time,
                    "IssueId": 2,
                    "CompanyId": 3,
                    "CustomerId": 4,
                    "RepId": 5,
                    "EventTime": time,
                    "EventType": EventType.conversationEnd.rawValue,
                    "EphemeralType": EphemeralEventType.none.rawValue,
                    "EventFlags": 6,
                    "CompanyEventLogSeq": 0,
                    "CustomerEventLogSeq": 0
                ] as [String: Any]
            }
            
            func clear() {
                if let data = try? JSONSerialization.data(withJSONObject: [:], options: .prettyPrinted) {
                    try? data.write(to: url, options: [.completeFileProtection, .atomic])
                }
            }
            
            beforeEach {
                clear()
            }
            
            context(".getSavedEvents()") {
                context("with no stored events") {
                    it("returns an empty array") {
                        let store = ConversationFileStore(config: ASAPP.config, user: ASAPP.user)
                        let events = store.getSavedEvents()
                        expect(events).to(equal([]))
                    }
                }
                context("with no stored data at all") {
                    it("returns nil") {
                        try? FileManager.default.removeItem(at: url)
                        let store = ConversationFileStore(config: ASAPP.config, user: ASAPP.user)
                        let events = store.getSavedEvents()
                        expect(events).to(beNil())
                    }
                }
                
                context("with a stored event") {
                    it("returns the event") {
                        let eventDict = createTestEventDict()
                        let event = Event.fromJSON(eventDict)
                        if let data = try? JSONSerialization.data(withJSONObject: eventDict, options: .prettyPrinted) {
                            try? data.write(to: url, options: [.completeFileProtection, .atomic])
                        }
                        
                        let store = ConversationFileStore(config: ASAPP.config, user: ASAPP.user)
                        let events = store.getSavedEvents()
                        expect(events?.first?.eventDate.timeIntervalSince1970).to(equal(event?.eventDate.timeIntervalSince1970))
                    }
                }
            }
            
            context(".getSavedEventsWithCompletion(completion:)") {
                context("with no stored events") {
                    it("returns nil") {
                        let store = ConversationFileStore(config: ASAPP.config, user: ASAPP.user)
                        waitUntil { done in
                            store.getSavedEventsWithCompletion { events in
                                expect(events).to(equal([]))
                                done()
                            }
                        }
                    }
                }
                
                context("with a stored event") {
                    it("returns the event") {
                        let eventDict = createTestEventDict()
                        let event = Event.fromJSON(eventDict)
                        if let data = try? JSONSerialization.data(withJSONObject: eventDict, options: .prettyPrinted) {
                            try? data.write(to: url, options: [.completeFileProtection, .atomic])
                        }
                        
                        let store = ConversationFileStore(config: ASAPP.config, user: ASAPP.user)
                        waitUntil { done in
                            store.getSavedEventsWithCompletion { events in
                                expect(events?.first?.eventDate.timeIntervalSince1970).to(equal(event?.eventDate.timeIntervalSince1970))
                                done()
                            }
                        }
                    }
                }
            }
            
            context(".addEventJSON(eventJSON:)") {
                context("with nil") {
                    it("does nothing") {
                        let store = ConversationFileStore(config: ASAPP.config, user: ASAPP.user)
                        store.addEventJSON(eventJSON: nil)
                        store.save(async: true)
                        
                        func getWritten() -> String? {
                            return try? String(contentsOf: url, encoding: .utf8)
                        }
                        
                        expect(getWritten()).toEventually(equal("{\n\n}"))
                    }
                }
                
                context("with a non-event dictionary") {
                    it("writes the dictionary") {
                        let store = ConversationFileStore(config: ASAPP.config, user: ASAPP.user)
                        let value = "deadbeef"
                        
                        store.addEventJSON(eventJSON: ["foo": value])
                        store.save(async: true)
                        
                        func getWritten() -> String? {
                            return try? String(contentsOf: url, encoding: .utf8)
                        }
                        
                        expect(getWritten()).toEventually(contain(value))
                    }
                }
                
                context("with an event dictionary") {
                    it("writes the dictionary") {
                        let store = ConversationFileStore(config: ASAPP.config, user: ASAPP.user)
                        let eventDict = createTestEventDict()
                        
                        store.addEventJSON(eventJSON: eventDict)
                        store.save(async: true)
                        
                        func getWritten() -> String? {
                            return try? String(contentsOf: url, encoding: .utf8)
                        }
                        
                        let time = String(Int(eventDict["CreatedTime"] as! Double))
                        expect(getWritten()).toEventually(contain(time))
                    }
                }
            }
            
            context(".addEventJSONString(eventJSONString:)") {
                context("with nil") {
                    it("does nothing") {
                        let store = ConversationFileStore(config: ASAPP.config, user: ASAPP.user)
                        store.addEventJSONString(eventJSONString: nil)
                        store.save(async: true)
                        
                        func getWritten() -> String? {
                            return try? String(contentsOf: url, encoding: .utf8)
                        }
                        
                        expect(getWritten()).toEventually(equal("{\n\n}"))
                    }
                }
                
                context("with a string not describing an event dictionary") {
                    it("writes the string") {
                        let store = ConversationFileStore(config: ASAPP.config, user: ASAPP.user)
                        let value = "absolute garbage!"
                        
                        store.addEventJSONString(eventJSONString: value)
                        store.save(async: true)
                        
                        func getWritten() -> String? {
                            return try? String(contentsOf: url, encoding: .utf8)
                        }
                        
                        expect(getWritten()).toEventually(equal(value))
                    }
                }
                
                context("with a string describing event dictionary") {
                    it("writes the string") {
                        let store = ConversationFileStore(config: ASAPP.config, user: ASAPP.user)
                        let eventDict = createTestEventDict()
                        var eventDictString: String?
                        if let data = try? JSONSerialization.data(withJSONObject: eventDict, options: .prettyPrinted) {
                            eventDictString = String(data: data, encoding: .utf8)
                        }
                        
                        store.addEventJSONString(eventJSONString: eventDictString)
                        store.save(async: true)
                        
                        func getWritten() -> String? {
                            return try? String(contentsOf: url, encoding: .utf8)
                        }
                        
                        expect(getWritten()).toEventually(equal(eventDictString))
                    }
                }
            }
            
            context(".replaceEventsWithJSONArray(eventsJSONArray:)") {
                context("with an empty array") {
                    it("does nothing") {
                        let store = ConversationFileStore(config: ASAPP.config, user: ASAPP.user)
                        let eventDict1 = createTestEventDict()
                        let eventDict2 = createTestEventDict()
                        let event1 = Event.fromJSON(eventDict1)!
                        let event2 = Event.fromJSON(eventDict2)!
                        
                        store.addEventJSON(eventJSON: eventDict1)
                        store.addEventJSON(eventJSON: eventDict2)
                        store.save(async: true)
                       
                        expect(store.getSavedEvents()).toEventually(haveCount(2))
                        expect(store.getSavedEvents()).toEventually(containElementSatisfying({ event -> Bool in
                            event.eventDate == event1.eventDate
                        }))
                        expect(store.getSavedEvents()).toEventually(containElementSatisfying({ event -> Bool in
                            event.eventDate == event2.eventDate
                        }))
                        
                        store.replaceEventsWithJSONArray(eventsJSONArray: [])
                        store.save(async: true)
                        
                        expect(store.getSavedEvents()).toEventually(haveCount(2))
                        expect(store.getSavedEvents()).toEventually(containElementSatisfying({ event -> Bool in
                            event.eventDate == event1.eventDate
                        }))
                        expect(store.getSavedEvents()).toEventually(containElementSatisfying({ event -> Bool in
                            event.eventDate == event2.eventDate
                        }))
                    }
                }
                context("with an array describing one event") {
                    it("replaces saved events") {
                        let store = ConversationFileStore(config: ASAPP.config, user: ASAPP.user)
                        let eventDict1 = createTestEventDict()
                        let eventDict2 = createTestEventDict()
                        let eventDict3 = createTestEventDict()
                        let event1 = Event.fromJSON(eventDict1)!
                        let event2 = Event.fromJSON(eventDict2)!
                        let event3 = Event.fromJSON(eventDict3)!
                        
                        store.addEventJSON(eventJSON: eventDict1)
                        store.addEventJSON(eventJSON: eventDict2)
                        store.save(async: true)
                        
                        expect(store.getSavedEvents()).toEventually(haveCount(2))
                        expect(store.getSavedEvents()).toEventually(containElementSatisfying({ event -> Bool in
                            event.eventDate == event1.eventDate
                        }))
                        
                        expect(store.getSavedEvents()).toEventually(containElementSatisfying({ event -> Bool in
                            event.eventDate == event2.eventDate
                        }))
                        
                        store.replaceEventsWithJSONArray(eventsJSONArray: [eventDict3])
                        store.save(async: true)
                        
                        expect(store.getSavedEvents()).toEventually(haveCount(1))
                        expect(store.getSavedEvents()).toEventually(containElementSatisfying({ event -> Bool in
                            event.eventDate == event3.eventDate
                        }))
                    }
                }
            }
            
            context(".save(async:)") {
                context("without needing to write") {
                    it("does nothing") {
                        let store = ConversationFileStore(config: ASAPP.config, user: ASAPP.user)
                        store.save(async: true)
                        
                        expect(store.getSavedEvents()).toEventually(haveCount(0))
                    }
                }
                
                context("without needing to write, synchronously") {
                    it("does nothing") {
                        let store = ConversationFileStore(config: ASAPP.config, user: ASAPP.user)
                        store.save(async: false)
                        
                        expect(store.getSavedEvents()).to(haveCount(0))
                    }
                }
                
                context("with needing to write") {
                    let store = ConversationFileStore(config: ASAPP.config, user: ASAPP.user)
                    let eventDict1 = createTestEventDict()
                    let event1 = Event.fromJSON(eventDict1)!
                    store.addEventJSON(eventJSON: eventDict1)
                    store.save(async: true)
                    
                    expect(store.getSavedEvents()).toEventually(haveCount(1))
                    expect(store.getSavedEvents()).toEventually(containElementSatisfying({ event -> Bool in
                        event.eventDate == event1.eventDate
                    }))
                }
            }
        }
    }
}
