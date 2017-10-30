//
//  EventTypeSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 10/23/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class EventTypeSpec: QuickSpec {
    override func spec() {
        describe("EventType") {
            describe(".getLiveChatStatus(from:)") {
                context("with a live chat event among others") {
                    it("returns true") {
                        func createEvent() -> Event {
                            return Event(eventId: Int(arc4random_uniform(UInt32.max)), parentEventLogSeq: nil, eventType: .srsEcho, ephemeralType: .none, eventTime: Date().timeIntervalSince1970, issueId: 1, companyId: 1, customerId: 1, repId: 1, eventFlags: 0, eventJSON: nil)
                        }
                        
                        var events: [Event] = []
                        for _ in 0..<100 {
                            events.append(createEvent())
                        }
                        
                        expect(EventType.getLiveChatStatus(from: events)).to(equal(false))
                        
                        let switchEvent = Event(eventId: Int(arc4random_uniform(UInt32.max)), parentEventLogSeq: nil, eventType: .switchSRSToChat, ephemeralType: .none, eventTime: Date().timeIntervalSince1970, issueId: 1, companyId: 1, customerId: 1, repId: 1, eventFlags: 0, eventJSON: nil)
                        events.insert(switchEvent, at: 50)
                        
                        expect(EventType.getLiveChatStatus(from: events)).to(equal(true))
                    }
                }
            }
        }
    }
}
