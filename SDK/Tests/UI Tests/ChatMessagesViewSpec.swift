//
//  ChatMessagesViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 12/28/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ChatMessagesViewSpec: QuickSpec {
    override func spec() {
        describe("ChatMessagesView") {
            var nextEventId: Int = 0
            var nextEventTime: TimeInterval = 327511937
            
            func createMessageEvent(text: String, isReply: Bool = false, time: TimeInterval? = nil) -> Event {
                let eventTime: TimeInterval
                if let time = time {
                    eventTime = time
                    nextEventTime = time + 10
                } else {
                    eventTime = nextEventTime
                    nextEventTime += 10
                }
                
                let eventId = nextEventId
                nextEventId += 1
                
                let event = Event(
                    eventId: eventId,
                    parentEventLogSeq: nil,
                    eventType: .textMessage,
                    ephemeralType: .none,
                    eventTime: eventTime,
                    issueId: 0,
                    companyId: 0,
                    customerId: 0,
                    repId: 0,
                    eventFlags: isReply ? 0 : 1,
                    eventJSON: [:])
                
                let metadata = EventMetadata(
                    isReply: isReply,
                    isAutomatedMessage: false,
                    eventId: eventId,
                    eventType: .textMessage,
                    issueId: 0,
                    sendTime: Date(timeIntervalSince1970: eventTime))
                
                event.chatMessage = ChatMessage(text: text, notification: nil, attachment: nil, buttons: nil, quickReplies: nil, metadata: metadata)
                
                return event
            }
            
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
            }
            
            context("on its own") {
                var view: ChatMessagesView!
                
                beforeEach {
                    TestUtil.createStyle()
                    view = ChatMessagesView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
                    nextEventId = 0
                    nextEventTime = 327511937
                }
                
                context("with no messages") {
                    it("has a valid snapshot") {
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a few text messages") {
                    it("has a valid snapshot") {
                        var events: [Event] = []
                        for i in 0..<5 {
                            events.append(createMessageEvent(text: "Message \(i)"))
                        }
                        view.reloadWithEvents(events)
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with many text messages") {
                    it("has a valid snapshot") {
                        var events: [Event] = []
                        for i in 0..<25 {
                            events.append(createMessageEvent(text: "Message \(i)"))
                        }
                        view.reloadWithEvents(events)
                        waitUntil { done in
                            expect(view).to(haveValidSnapshot())
                            done()
                        }
                    }
                }
                
                context("with many replies") {
                    it("has a valid snapshot") {
                        var events: [Event] = []
                        for i in 0..<25 {
                            events.append(createMessageEvent(text: "Message \(i)", isReply: true))
                        }
                        view.reloadWithEvents(events)
                        waitUntil { done in
                            expect(view).to(haveValidSnapshot())
                            done()
                        }
                    }
                }
                
                context("with alternating messages and replies") {
                    it("has a valid snapshot") {
                        var events: [Event] = []
                        for i in 0..<25 {
                            events.append(createMessageEvent(text: "Message \(i)", isReply: i % 2 == 0))
                        }
                        view.reloadWithEvents(events)
                        waitUntil { done in
                            expect(view).to(haveValidSnapshot())
                            done()
                        }
                    }
                }
                
                context("with one message's timestamp toggled to be visible") {
                    it("has a valid snapshot") {
                        var events: [Event] = []
                        for i in 0..<25 {
                            events.append(createMessageEvent(text: "Message \(i)", isReply: i % 2 == 0))
                        }
                        view.reloadWithEvents(events)
                        waitUntil { done in
                            view.toggleTimeStampForMessage(at: IndexPath(row: 20, section: 0))
                            expect(view).to(haveValidSnapshot())
                            done()
                        }
                    }
                }
                
                context("with multiple timestamps toggled to be visible") {
                    it("has a valid snapshot") {
                        var events: [Event] = []
                        for i in 0..<25 {
                            events.append(createMessageEvent(text: "Message \(i)", isReply: i % 2 == 0))
                        }
                        view.reloadWithEvents(events)
                        waitUntil { done in
                            view.toggleTimeStampForMessage(at: IndexPath(row: 20, section: 0))
                            view.toggleTimeStampForMessage(at: IndexPath(row: 22, section: 0))
                            view.toggleTimeStampForMessage(at: IndexPath(row: 23, section: 0))
                            expect(view).to(haveValidSnapshot())
                            done()
                        }
                    }
                }
                
                context("with the typing indicator visible") {
                    it("has a valid snapshot") {
                        var events: [Event] = []
                        for i in 0..<25 {
                            events.append(createMessageEvent(text: "Message \(i)", isReply: i % 2 == 0))
                        }
                        view.reloadWithEvents(events)
                        view.updateTypingStatus(true)
                        waitUntil { done in
                            expect(view).to(haveValidSnapshot())
                            done()
                        }
                    }
                }
                
                context("with custom top and bottom content insets") {
                    it("has a valid snapshot") {
                        var events: [Event] = []
                        for i in 0..<25 {
                            events.append(createMessageEvent(text: "Message \(i)", isReply: i % 2 == 0))
                        }
                        view.contentInsetTop = 80
                        view.contentInsetBottom = 80
                        view.reloadWithEvents(events)
                        waitUntil { done in
                            expect(view).to(haveValidSnapshot())
                            done()
                        }
                    }
                }
            }
        }
    }
}
