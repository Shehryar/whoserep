//
//  ChatViewControllerSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 3/7/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ChatViewControllerSpec: QuickSpec {
    override func spec() {
        describe("ChatViewController") {
            let window = UIWindow(frame: UIScreen.main.bounds)
            let config = ASAPPConfig(appId: "test", apiHostName: "test", clientSecret: "test", regionCode: "test")
            let user = ASAPPUser(userIdentifier: "testUser", requestContextProvider: { _ in
                return [:]
            })
            var nextEventId: Int = 0
            var nextEventTime: TimeInterval = 327511937
            
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
                TestUtil.createStyle()
            }
            
            func createMessageEvent(text: String, isReply: Bool = false, time: TimeInterval? = nil, quickReplies: [QuickReply]? = nil) -> Event {
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
                
                event.chatMessage = ChatMessage(text: text, attachment: nil, buttons: nil, quickReplies: quickReplies, metadata: metadata)
                
                return event
            }
            
            func createTestEventDict(time: TimeInterval? = nil, text: String? = nil) -> [String: Any] {
                let time = time ?? 327511937
                var dict = [
                    "CreatedTime": time,
                    "IssueId": 2,
                    "CompanyId": 3,
                    "CustomerId": 4,
                    "RepId": 5,
                    "EventTime": time,
                    "EventType": EventType.textMessage.rawValue,
                    "EphemeralType": EphemeralEventType.none.rawValue,
                    "EventFlags": 6,
                    "CompanyEventLogSeq": 0,
                    "CustomerEventLogSeq": 0
                ] as [String: Any]
                
                if let text = text {
                    dict[Event.JSONKey.eventJSON.rawValue] = "{\"\(Event.JSONKey.text.rawValue)\": \"\(text)\"}"
                }
                
                return dict
            }
            
            context(".init(...)") {
                context("default state") {
                    it("is initialized and loaded properly") {
                        let mockConversationManager = MockConversationManager(config: config, user: user, userLoginAction: nil)
                        let viewController = ChatViewController(config: config, user: user, segue: .push, conversationManager: mockConversationManager)
                        window.rootViewController = viewController
                        _ = viewController.view
                        
                        expect(viewController.config).to(equal(config))
                        expect(viewController.user).to(equal(user))
                        expect(mockConversationManager.calledEnterConversation).to(equal(true))
                        expect(mockConversationManager.calledExitConversation).to(equal(false))
                        expect(mockConversationManager.calledIsConnected).to(equal(false))
                        expect(mockConversationManager.calledGetCurrentQuickReplyMessage).to(equal(false))
                        expect(mockConversationManager.calledSendRequestForAPIAction).to(equal(false))
                        expect(mockConversationManager.calledSendRequestForHTTPAction).to(equal(false))
                        expect(mockConversationManager.calledSendRequestForTreewalkAction).to(equal(false))
                        expect(mockConversationManager.calledGetComponentView).to(equal(false))
                        expect(mockConversationManager.calledSendUserTypingStatus).to(equal(false))
                        expect(mockConversationManager.calledSendAskRequest).to(equal(false))
                        expect(mockConversationManager.calledSendSRSQuery).to(equal(false))
                        expect(viewController.view).to(haveValidSnapshot())
                    }
                }
                
                context("with a text message while still connecting") {
                    it("is initialized and loaded properly") {
                        let event = createMessageEvent(text: "foo", isReply: true)
                        
                        let mockConversationManager = MockConversationManager(config: config, user: user, userLoginAction: nil)
                        mockConversationManager.events = [event]
                        
                        let viewController = ChatViewController(config: config, user: user, segue: .push, conversationManager: mockConversationManager)
                        window.rootViewController = viewController
                        _ = viewController.view
                        
                        expect(viewController.config).to(equal(config))
                        expect(viewController.user).to(equal(user))
                        expect(mockConversationManager.calledEnterConversation).to(equal(true))
                        expect(mockConversationManager.calledExitConversation).to(equal(false))
                        expect(mockConversationManager.calledIsConnected).to(equal(false))
                        expect(mockConversationManager.calledGetCurrentQuickReplyMessage).to(equal(false))
                        expect(mockConversationManager.calledSendRequestForAPIAction).to(equal(false))
                        expect(mockConversationManager.calledSendRequestForHTTPAction).to(equal(false))
                        expect(mockConversationManager.calledSendRequestForTreewalkAction).to(equal(false))
                        expect(mockConversationManager.calledGetComponentView).to(equal(false))
                        expect(mockConversationManager.calledSendUserTypingStatus).to(equal(false))
                        expect(mockConversationManager.calledSendAskRequest).to(equal(false))
                        expect(mockConversationManager.calledSendSRSQuery).to(equal(false))
                        expect(viewController.view).to(haveValidSnapshot())
                    }
                }
                
                context("with a text message after connecting before being loaded") {
                    it("is initialized and loaded properly") {
                        let event = createMessageEvent(text: "foo", isReply: true)
                        
                        let mockConversationManager = MockConversationManager(config: config, user: user, userLoginAction: nil)
                        mockConversationManager.events = [event]
                        mockConversationManager.isConnected = true
                        
                        let viewController = ChatViewController(config: config, user: user, segue: .push, conversationManager: mockConversationManager)
                        window.rootViewController = viewController
                        mockConversationManager.delegate = viewController
                        mockConversationManager.delegate?.conversationManager(mockConversationManager, didChangeConnectionStatus: true)
                        _ = viewController.view
                        
                        expect(viewController.config).to(equal(config))
                        expect(viewController.user).to(equal(user))
                        expect(mockConversationManager.calledEnterConversation).to(equal(false))
                        expect(mockConversationManager.calledExitConversation).to(equal(false))
                        expect(mockConversationManager.calledIsConnected).to(equal(false))
                        expect(mockConversationManager.calledGetCurrentQuickReplyMessage).to(equal(false))
                        expect(mockConversationManager.calledSendRequestForAPIAction).to(equal(false))
                        expect(mockConversationManager.calledSendRequestForHTTPAction).to(equal(false))
                        expect(mockConversationManager.calledSendRequestForTreewalkAction).to(equal(false))
                        expect(mockConversationManager.calledGetComponentView).to(equal(false))
                        expect(mockConversationManager.calledSendUserTypingStatus).to(equal(false))
                        expect(mockConversationManager.calledSendAskRequest).to(equal(false))
                        expect(mockConversationManager.calledSendSRSQuery).to(equal(false))
                        expect(viewController.view).to(haveValidSnapshot())
                    }
                }
                
                context("with a text message and connecting after being loaded") {
                    it("is initialized and loaded properly") {
                        let event = createMessageEvent(text: "foo", isReply: true)
                        
                        let mockConversationManager = MockConversationManager(config: config, user: user, userLoginAction: nil)
                        mockConversationManager.events = [event]
                        
                        let viewController = ChatViewController(config: config, user: user, segue: .push, conversationManager: mockConversationManager)
                        window.rootViewController = viewController
                        mockConversationManager.delegate = viewController
                        _ = viewController.view
                        
                        mockConversationManager.isConnected = true
                        mockConversationManager.delegate?.conversationManager(mockConversationManager, didChangeConnectionStatus: true)
                        
                        expect(viewController.config).to(equal(config))
                        expect(viewController.user).to(equal(user))
                        expect(mockConversationManager.calledEnterConversation).to(equal(true))
                        expect(mockConversationManager.calledExitConversation).to(equal(false))
                        expect(mockConversationManager.calledIsConnected).to(equal(false))
                        expect(mockConversationManager.calledGetCurrentQuickReplyMessage).to(equal(false))
                        expect(mockConversationManager.calledSendRequestForAPIAction).to(equal(false))
                        expect(mockConversationManager.calledSendRequestForHTTPAction).to(equal(false))
                        expect(mockConversationManager.calledSendRequestForTreewalkAction).to(equal(false))
                        expect(mockConversationManager.calledGetComponentView).to(equal(false))
                        expect(mockConversationManager.calledSendUserTypingStatus).to(equal(false))
                        expect(mockConversationManager.calledSendAskRequest).to(equal(false))
                        expect(mockConversationManager.calledSendSRSQuery).to(equal(false))
                        expect(viewController.view).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
