//
//  EventSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 12/22/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class EventSpec: QuickSpec {
    override func spec() {
        describe("Event") {
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
            
            describe(".init(...)") {
                context("with all the arguments") {
                    it("creates an instance") {
                        let event = Event(eventId: 0, parentEventLogSeq: nil, eventType: .newRep, ephemeralType: .none, eventTime: 1, issueId: 2, companyId: 3, customerId: 4, repId: 5, eventFlags: 6, eventJSON: [:])
                        expect(event.chatMessage).to(beNil())
                        expect(event.typingStatus).to(beNil())
                        expect(event.switchToSRSClassification).to(beNil())
                        expect(event.eventLogSeq).to(equal(0))
                        expect(event.parentEventLogSeq).to(beNil())
                        expect(event.eventType).to(equal(EventType.newRep))
                        expect(event.ephemeralType).to(equal(EphemeralEventType.none))
                        expect(event.eventTime).to(equal(1))
                        expect(event.issueId).to(equal(2))
                        expect(event.companyId).to(equal(3))
                        expect(event.customerId).to(equal(4))
                        expect(event.repId).to(equal(5))
                        expect(event.eventFlags).to(equal(6))
                        expect(event.isCustomerEvent).to(equal(false))
                        expect(event.isReply).to(equal(true))
                        let date = Date(timeIntervalSince1970: 1)
                        expect(event.eventDate).to(equal(date))
                        expect(event.sendTimeString).to(equal(date.formattedStringMostRecent()))
                        expect(event.isAutomatedMessage).to(equal(false))
                    }
                }
            }
            
            describe(".makeMetadata()") {
                context("with no parentEventLogSeq") {
                    it("creates a correct EventMetadata instance") {
                        let event = Event(eventId: 0, parentEventLogSeq: nil, eventType: .newRep, ephemeralType: .none, eventTime: 1, issueId: 2, companyId: 3, customerId: 4, repId: 5, eventFlags: 1, eventJSON: [:])
                        let metadata = event.makeMetadata()
                        expect(event.isCustomerEvent).to(equal(true))
                        expect(metadata.isReply).to(equal(false))
                        expect(metadata.isAutomatedMessage).to(equal(false))
                        expect(metadata.eventId).to(equal(0))
                        expect(metadata.issueId).to(equal(2))
                        expect(metadata.sendTime).to(equal(Date(timeIntervalSince1970: 1)))
                        expect(metadata.classification).to(beNil())
                    }
                }
            }
            
            describe(".fromJSON(_:)") {
                context("with an invalid dict") {
                    it("returns nil") {
                        let event = Event.fromJSON([:])
                        expect(event).to(beNil())
                    }
                }
                
                context("with one required key missing") {
                    it("returns nil") {
                        let time = Date().timeIntervalSince1970
                        var dict = createTestEventDict(time: time)
                        dict.removeValue(forKey: "RepId")
                        let event = Event.fromJSON(dict)
                        expect(event).to(beNil())
                    }
                }
                
                context("with a valid event dictionary") {
                    it("returns a correct Event instance") {
                        let time = Date().timeIntervalSince1970
                        let dict = createTestEventDict(time: time)
                        let event = Event.fromJSON(dict)!
                        
                        expect(event.chatMessage).to(beNil())
                        expect(event.typingStatus).to(beNil())
                        expect(event.switchToSRSClassification).to(beNil())
                        expect(event.eventLogSeq).to(equal(0))
                        expect(event.parentEventLogSeq).to(beNil())
                        expect(event.eventType).to(equal(EventType.conversationEnd))
                        expect(event.ephemeralType).to(equal(EphemeralEventType.none))
                        expect(event.eventTime).to(equal(time / 1000000))
                        expect(event.issueId).to(equal(2))
                        expect(event.companyId).to(equal(3))
                        expect(event.customerId).to(equal(4))
                        expect(event.repId).to(equal(5))
                        expect(event.eventFlags).to(equal(6))
                        expect(event.isCustomerEvent).to(equal(false))
                        expect(event.isReply).to(equal(true))
                        let date = Date(timeIntervalSince1970: time / 1000000)
                        expect(event.eventDate).to(equal(date))
                        expect(event.sendTimeString).to(equal(date.formattedStringMostRecent()))
                        expect(event.isAutomatedMessage).to(equal(false))
                    }
                }
                
                context("with a dictionary describing a typing status but with an invalid EventJSON") {
                    it("returns an Event instance with a nil typingStatus") {
                        var dict = createTestEventDict()
                        dict[Event.JSONKey.eventType.rawValue] = EventType.conversationEnd.rawValue
                        dict[Event.JSONKey.ephemeralType.rawValue] = EphemeralEventType.typingStatus.rawValue
                        dict[Event.JSONKey.eventJSON.rawValue] = "{\"invalid\": true}"
                        let event = Event.fromJSON(dict)!
                        expect(event.typingStatus).to(beNil())
                    }
                }
                
                context("with a dictionary describing a typing status") {
                    it("returns an Event instance witha true typingStatus") {
                        var dict = createTestEventDict()
                        dict[Event.JSONKey.eventType.rawValue] = EventType.conversationEnd.rawValue
                        dict[Event.JSONKey.ephemeralType.rawValue] = EphemeralEventType.typingStatus.rawValue
                        dict[Event.JSONKey.eventJSON.rawValue] = "{\"\(Event.JSONKey.isTyping.rawValue)\": true}"
                        let event = Event.fromJSON(dict)!
                        expect(event.typingStatus).to(equal(true))
                        expect(event.switchToSRSClassification).to(beNil())
                        expect(event.chatMessage).to(beNil())
                    }
                }
                
                context("with a dictionary describing switching from chat to SRS") {
                    it("returns an Event instance with a switchToSRSClassification") {
                        var dict = createTestEventDict()
                        dict[Event.JSONKey.eventType.rawValue] = EventType.switchChatToSRS.rawValue
                        dict[Event.JSONKey.ephemeralType.rawValue] = EphemeralEventType.none.rawValue
                        dict[Event.JSONKey.eventJSON.rawValue] = "{\"\(Event.JSONKey.intent.rawValue)\": \"foo\"}"
                        let event = Event.fromJSON(dict)!
                        expect(event.typingStatus).to(beNil())
                        expect(event.switchToSRSClassification).to(equal("foo"))
                        expect(event.chatMessage).to(beNil())
                    }
                }
                
                context("with a dictionary describing a chat message") {
                    it("returns an Event instance with a chatMessage with text") {
                        let time = Date().timeIntervalSince1970
                        var dict = createTestEventDict(time: time)
                        dict[Event.JSONKey.eventType.rawValue] = EventType.textMessage.rawValue
                        dict[Event.JSONKey.ephemeralType.rawValue] = EphemeralEventType.none.rawValue
                        dict[Event.JSONKey.eventJSON.rawValue] = "{\"\(Event.JSONKey.text.rawValue)\": \"foo\"}"
                        let event = Event.fromJSON(dict)!
                        expect(event.typingStatus).to(beNil())
                        expect(event.switchToSRSClassification).to(beNil())
                        expect(event.chatMessage?.text).to(equal("foo"))
                        expect(event.chatMessage?.attachment).to(beNil())
                        expect(event.chatMessage?.quickReplies).to(beNil())
                        
                        let metadata = event.chatMessage!.metadata
                        expect(metadata.isReply).to(equal(true))
                        expect(metadata.isAutomatedMessage).to(equal(false))
                        expect(metadata.eventId).to(equal(0))
                        expect(metadata.issueId).to(equal(2))
                        expect(metadata.sendTime).to(equal(Date(timeIntervalSince1970: time / 1000000)))
                        expect(metadata.classification).to(beNil())
                    }
                }
                
                context("with a dictionary describing an invalid picture message") {
                    it("returns an Event instance without an image attachment") {
                        let time = Date().timeIntervalSince1970
                        var dict = createTestEventDict(time: time)
                        dict[Event.JSONKey.eventType.rawValue] = EventType.pictureMessage.rawValue
                        dict[Event.JSONKey.ephemeralType.rawValue] = EphemeralEventType.none.rawValue
                        dict[Event.JSONKey.eventJSON.rawValue] = "{\"\(Event.JSONKey.fileBucket.rawValue)\": \"foo\", \"\(Event.JSONKey.fileSecret.rawValue)\": \"foo\", \"\(Event.JSONKey.mimeType.rawValue)\": \"foo\", \"\(Event.JSONKey.picWidth.rawValue)\": 1}"
                        let event = Event.fromJSON(dict)!
                        expect(event.typingStatus).to(beNil())
                        expect(event.switchToSRSClassification).to(beNil())
                        expect(event.chatMessage).to(beNil())
                    }
                }
                
                context("with a dictionary describing a picture message with an invalid image URL") {
                    it("returns an Event instance without an image attachment") {
                        let time = Date().timeIntervalSince1970
                        var dict = createTestEventDict(time: time)
                        dict[Event.JSONKey.eventType.rawValue] = EventType.pictureMessage.rawValue
                        dict[Event.JSONKey.ephemeralType.rawValue] = EphemeralEventType.none.rawValue
                        dict[Event.JSONKey.eventJSON.rawValue] = "{\"\(Event.JSONKey.fileBucket.rawValue)\": \"foo\", \"\(Event.JSONKey.fileSecret.rawValue)\": \"foo\", \"\(Event.JSONKey.mimeType.rawValue)\": \"foo/ \", \"\(Event.JSONKey.picWidth.rawValue)\": 1, \"\(Event.JSONKey.picHeight.rawValue)\": 1}"
                        let event = Event.fromJSON(dict)!
                        expect(event.typingStatus).to(beNil())
                        expect(event.switchToSRSClassification).to(beNil())
                        expect(event.chatMessage).to(beNil())
                    }
                }
                
                context("with a dictionary describing a picture message") {
                    it("returns an Event instance with an image attachment") {
                        let time = Date().timeIntervalSince1970
                        var dict = createTestEventDict(time: time)
                        dict[Event.JSONKey.eventType.rawValue] = EventType.pictureMessage.rawValue
                        dict[Event.JSONKey.ephemeralType.rawValue] = EphemeralEventType.none.rawValue
                        dict[Event.JSONKey.eventJSON.rawValue] = "{\"\(Event.JSONKey.fileBucket.rawValue)\": \"foo\", \"\(Event.JSONKey.fileSecret.rawValue)\": \"foo\", \"\(Event.JSONKey.mimeType.rawValue)\": \"foo/\", \"\(Event.JSONKey.picWidth.rawValue)\": 1, \"\(Event.JSONKey.picHeight.rawValue)\": 1}"
                        let event = Event.fromJSON(dict)!
                        expect(event.typingStatus).to(beNil())
                        expect(event.switchToSRSClassification).to(beNil())
                        expect(event.chatMessage?.text).to(beNil())
                        expect(event.chatMessage?.attachment).to(beAKindOf(ChatMessageAttachment.self))
                        expect(event.chatMessage?.quickReplies).to(beNil())
                        
                        let metadata = event.chatMessage!.metadata
                        expect(metadata.isReply).to(equal(true))
                        expect(metadata.isAutomatedMessage).to(equal(false))
                        expect(metadata.eventId).to(equal(0))
                        expect(metadata.issueId).to(equal(2))
                        expect(metadata.sendTime).to(equal(Date(timeIntervalSince1970: time / 1000000)))
                        expect(metadata.classification).to(beNil())
                    }
                }
                
                context("with a dictionary describing a conversationEnd message") {
                    it("returns a correct Event instance") {
                        let time = Date().timeIntervalSince1970
                        var dict = createTestEventDict(time: time)
                        dict[Event.JSONKey.eventType.rawValue] = EventType.conversationEnd.rawValue
                        dict[Event.JSONKey.ephemeralType.rawValue] = EphemeralEventType.none.rawValue
                        dict[Event.JSONKey.eventJSON.rawValue] = "{\"\(ChatMessage.JSONKey.clientMessage.rawValue)\": {\"\(ChatMessage.JSONKey.text.rawValue)\": \"foo\"}}"
                        let event = Event.fromJSON(dict)!
                        expect(event.typingStatus).to(beNil())
                        expect(event.switchToSRSClassification).to(beNil())
                        expect(event.chatMessage?.text).to(equal("foo"))
                        expect(event.chatMessage?.attachment).to(beNil())
                        expect(event.chatMessage?.quickReplies).to(beNil())
                        
                        let metadata = event.chatMessage!.metadata
                        expect(metadata.isReply).to(equal(true))
                        expect(metadata.isAutomatedMessage).to(equal(false))
                        expect(metadata.eventId).to(equal(0))
                        expect(metadata.issueId).to(equal(2))
                        expect(metadata.sendTime).to(equal(Date(timeIntervalSince1970: time / 1000000)))
                        expect(metadata.classification).to(beNil())
                    }
                }
            }
        }
    }
}
