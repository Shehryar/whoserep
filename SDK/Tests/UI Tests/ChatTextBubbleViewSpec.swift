//
//  ChatTextBubbleViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 12/26/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ChatTextBubbleViewSpec: QuickSpec {
    override func spec() {
        describe("ChatTextBubbleView") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
            }
            
            context("as a reply") {
                let metadata = EventMetadata(
                    isReply: true,
                    isAutomatedMessage: true,
                    eventId: 0,
                    eventType: .textMessage,
                    issueId: 1,
                    sendTime: Date())
                let dict = [
                    "formatVersion": 1,
                    "text": "Text"
                ] as [String: Any]
                
                beforeEach {
                    TestUtil.createStyle()
                }
                
                context("with a message list position of none") {
                    it("has a valid snapshot") {
                        let view = ChatTextBubbleView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
                        view.message = ChatMessage.fromJSON(dict, with: metadata)
                        view.messagePosition = MessageListPosition.none
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of firstOfMany") {
                    it("has a valid snapshot") {
                        let view = ChatTextBubbleView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
                        view.message = ChatMessage.fromJSON(dict, with: metadata)
                        view.messagePosition = MessageListPosition.firstOfMany
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of middleOfMany") {
                    it("has a valid snapshot") {
                        let view = ChatTextBubbleView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
                        view.message = ChatMessage.fromJSON(dict, with: metadata)
                        view.messagePosition = MessageListPosition.middleOfMany
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of lastOfMany") {
                    it("has a valid snapshot") {
                        let view = ChatTextBubbleView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
                        view.message = ChatMessage.fromJSON(dict, with: metadata)
                        view.messagePosition = MessageListPosition.lastOfMany
                        expect(view).to(haveValidSnapshot())
                    }
                }
            }
            
            context("as a non-reply") {
                let metadata = EventMetadata(
                    isReply: false,
                    isAutomatedMessage: false,
                    eventId: 0,
                    eventType: .textMessage,
                    issueId: 1,
                    sendTime: Date())
                let dict = [
                    "formatVersion": 1,
                    "text": "Text"
                ] as [String: Any]
                
                beforeEach {
                    TestUtil.createStyle()
                }
                
                context("with a message list position of none") {
                    it("has a valid snapshot") {
                        let view = ChatTextBubbleView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
                        view.message = ChatMessage.fromJSON(dict, with: metadata)
                        view.messagePosition = MessageListPosition.none
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of firstOfMany") {
                    it("has a valid snapshot") {
                        let view = ChatTextBubbleView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
                        view.message = ChatMessage.fromJSON(dict, with: metadata)
                        view.messagePosition = MessageListPosition.firstOfMany
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of middleOfMany") {
                    it("has a valid snapshot") {
                        let view = ChatTextBubbleView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
                        view.message = ChatMessage.fromJSON(dict, with: metadata)
                        view.messagePosition = MessageListPosition.middleOfMany
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of lastOfMany") {
                    it("has a valid snapshot") {
                        let view = ChatTextBubbleView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
                        view.message = ChatMessage.fromJSON(dict, with: metadata)
                        view.messagePosition = MessageListPosition.lastOfMany
                        expect(view).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
