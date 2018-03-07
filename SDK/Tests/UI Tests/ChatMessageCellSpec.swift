//
//  ChatMessageCellSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 12/27/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ChatMessageCellSpec: QuickSpec {
    lazy var metadata: EventMetadata = {
        return EventMetadata(
            isReply: true,
            isAutomatedMessage: true,
            eventId: 0,
            eventType: .textMessage,
            issueId: 1,
            sendTime: Date(timeIntervalSince1970: 327511937))
    }()
    
    lazy var metadataNonReply: EventMetadata = {
        return EventMetadata(
            isReply: false,
            isAutomatedMessage: true,
            eventId: 0,
            eventType: .textMessage,
            issueId: 1,
            sendTime: Date(timeIntervalSince1970: 327511937))
    }()
    
    override func spec() {
        describe("ChatMessageCell") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
            }
            
            context("as a reply") {
                let dict = [
                    "formatVersion": 1,
                    "text": "Text"
                ] as [String: Any]
                var view: ChatMessageCell!
                
                beforeEach {
                    TestUtil.createStyle()
                    view = ChatMessageCell(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
                    view.message = ChatMessage.fromJSON(dict, with: self.metadata)
                }
                
                context("with a message list position of none") {
                    it("has a valid snapshot") {
                        view.messagePosition = .none
                        view.sizeToFit()
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of none and the time label visible") {
                    it("has a valid snapshot") {
                        view.messagePosition = .none
                        view.isTimeLabelVisible = true
                        view.sizeToFit()
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of firstOfMany") {
                    it("has a valid snapshot") {
                        view.messagePosition = .firstOfMany
                        view.sizeToFit()
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of firstOfMany and the time label visible") {
                    it("has a valid snapshot") {
                        view.messagePosition = .firstOfMany
                        view.isTimeLabelVisible = true
                        view.sizeToFit()
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of middleOfMany") {
                    it("has a valid snapshot") {
                        view.messagePosition = .middleOfMany
                        view.sizeToFit()
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of middleOfMany and the time label visible") {
                    it("has a valid snapshot") {
                        view.messagePosition = .middleOfMany
                        view.isTimeLabelVisible = true
                        view.sizeToFit()
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of lastOfMany") {
                    it("has a valid snapshot") {
                        view.messagePosition = .lastOfMany
                        view.sizeToFit()
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of lastOfMany and the time label visible") {
                    it("has a valid snapshot") {
                        view.messagePosition = .lastOfMany
                        view.isTimeLabelVisible = true
                        view.sizeToFit()
                        expect(view).to(haveValidSnapshot())
                    }
                }
            }
            
            context("as a non-reply") {
                let dict = [
                    "formatVersion": 1,
                    "text": "Text"
                ] as [String: Any]
                var view: ChatMessageCell!
                
                beforeEach {
                    TestUtil.createStyle()
                    view = ChatMessageCell(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
                    view.message = ChatMessage.fromJSON(dict, with: self.metadataNonReply)
                }
                
                context("with a message list position of none") {
                    it("has a valid snapshot") {
                        view.messagePosition = .none
                        view.sizeToFit()
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of none and the time label visible") {
                    it("has a valid snapshot") {
                        view.messagePosition = .none
                        view.isTimeLabelVisible = true
                        view.sizeToFit()
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of firstOfMany") {
                    it("has a valid snapshot") {
                        view.messagePosition = .firstOfMany
                        view.sizeToFit()
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of firstOfMany and the time label visible") {
                    it("has a valid snapshot") {
                        view.messagePosition = .firstOfMany
                        view.isTimeLabelVisible = true
                        view.sizeToFit()
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of middleOfMany") {
                    it("has a valid snapshot") {
                        view.messagePosition = .middleOfMany
                        view.sizeToFit()
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of middleOfMany and the time label visible") {
                    it("has a valid snapshot") {
                        view.messagePosition = .middleOfMany
                        view.isTimeLabelVisible = true
                        view.sizeToFit()
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of lastOfMany") {
                    it("has a valid snapshot") {
                        view.messagePosition = .lastOfMany
                        view.sizeToFit()
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of lastOfMany and the time label visible") {
                    it("has a valid snapshot") {
                        view.messagePosition = .lastOfMany
                        view.isTimeLabelVisible = true
                        view.sizeToFit()
                        expect(view).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
