//
//  EventMetadataSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 10/23/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class EventMetadataSpec: QuickSpec {
    override func spec() {
        describe("EventMetadata") {
            describe(".init(isReply:isAutomatedMessage:eventId:eventType:issueId:sendTime:)") {
                var sendTime: Date!
                
                beforeEach {
                    sendTime = Date()
                }
                
                context("with all the arguments") {
                    it("creates an instance") {
                        let metadata = EventMetadata(
                            isReply: true,
                            isAutomatedMessage: true,
                            eventId: 0,
                            eventType: .srsResponse,
                            issueId: 1,
                            sendTime: sendTime)
                        expect(metadata.sendTimeString).to(equal(sendTime.formattedStringMostRecent()))
                        expect(metadata.classification).to(beNil())
                    }
                }
            }
            
            describe(".updateSendTime(to:)") {
                context("with a date") {
                    it("updates the sendTime and sendTimeString properties") {
                        let sendTime = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
                        let metadata = EventMetadata(
                            isReply: true,
                            isAutomatedMessage: true,
                            eventId: 0,
                            eventType: .srsResponse,
                            issueId: 1,
                            sendTime: Date())
                        expect(metadata.sendTime).toNot(equal(sendTime))
                        expect(metadata.sendTimeString).toNot(equal(sendTime.formattedStringMostRecent()))
                        metadata.updateSendTime(to: sendTime)
                        expect(metadata.sendTime).to(equal(sendTime))
                        expect(metadata.sendTimeString).to(equal(sendTime.formattedStringMostRecent()))
                    }
                }
            }
            
            describe(".updateSendTime(toMatchMessage:)") {
                context("with a chat message") {
                    it("updates the sendTime and sendTimeString properties") {
                        let metadata = EventMetadata(
                            isReply: true,
                            isAutomatedMessage: true,
                            eventId: 0,
                            eventType: .srsResponse,
                            issueId: 1,
                            sendTime: Date())
                        let metadata2 = EventMetadata(
                            isReply: true,
                            isAutomatedMessage: true,
                            eventId: 0,
                            eventType: .srsResponse,
                            issueId: 1,
                            sendTime: Calendar.current.date(byAdding: .day, value: -2, to: Date())!)
                        let message = ChatMessage(text: "foo", notification: nil, attachment: ChatMessageAttachment(content: ""), buttons: nil, quickReplies: nil, metadata: metadata2)!
                        expect(metadata.sendTime).toNot(equal(message.metadata.sendTime))
                        metadata.updateSendTime(toMatchMessage: message)
                        expect(metadata.sendTime).to(equal(message.metadata.sendTime))
                    }
                }
            }
        }
    }
}
