//
//  ChatPictureMessageCellSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 11/9/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ChatPictureMessageCellSpec: QuickSpec {
    let stableImageURL = "https://s3.amazonaws.com/asapp-chat-sdk-historical-releases/fixtures/stable-image.jpg"
    
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
        describe("ChatPictureMessageCell") {
            let timeout: TimeInterval = 5
            let image = ChatMessageImage(url: URL(string: self.stableImageURL)!, width: 100, height: 100)
            let attachment = ChatMessageAttachment(content: image)
            
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
                TestUtil.createStyle()
                
                let dummy = UIImageView(frame: CGRect(x: 0, y: 0, width: 260, height: 260))
                waitUntil(timeout: timeout) { done in
                    dummy.sd_setImage(with: URL(string: self.stableImageURL)!) { _, _, _, _ in
                        done()
                    }
                }
            }
            
            context("as a reply") {
                var cell: ChatPictureMessageCell!
                
                beforeEach {
                    cell = ChatPictureMessageCell(frame: CGRect(x: 0, y: 0, width: 320, height: 0))
                    cell.message = ChatMessage(text: "Test", attachment: attachment, buttons: nil, quickReplies: nil, metadata: self.metadata)
                }
                
                context("with a message list position of none") {
                    it("has a valid snapshot") {
                        cell.messagePosition = .none
                        cell.sizeToFit()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of none and the time label visible") {
                    it("has a valid snapshot") {
                        cell.messagePosition = .none
                        cell.isTimeLabelVisible = true
                        cell.sizeToFit()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of firstOfMany") {
                    it("has a valid snapshot") {
                        cell.messagePosition = .firstOfMany
                        cell.sizeToFit()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of firstOfMany and the time label visible") {
                    it("has a valid snapshot") {
                        cell.messagePosition = .firstOfMany
                        cell.isTimeLabelVisible = true
                        cell.sizeToFit()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of middleOfMany") {
                    it("has a valid snapshot") {
                        cell.messagePosition = .middleOfMany
                        cell.sizeToFit()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of middleOfMany and the time label visible") {
                    it("has a valid snapshot") {
                        cell.messagePosition = .middleOfMany
                        cell.isTimeLabelVisible = true
                        cell.sizeToFit()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of lastOfMany") {
                    it("has a valid snapshot") {
                        cell.messagePosition = .lastOfMany
                        cell.sizeToFit()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of lastOfMany and the time label visible") {
                    it("has a valid snapshot") {
                        cell.messagePosition = .lastOfMany
                        cell.isTimeLabelVisible = true
                        cell.sizeToFit()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
            }
            
            context("as a non-reply") {
                var cell: ChatPictureMessageCell!
                
                beforeEach {
                    cell = ChatPictureMessageCell(frame: CGRect(x: 0, y: 0, width: 320, height: 0))
                    cell.message = ChatMessage(text: "Test", attachment: attachment, buttons: nil, quickReplies: nil, metadata: self.metadataNonReply)
                }
                
                context("with a message list position of none") {
                    it("has a valid snapshot") {
                        cell.messagePosition = .none
                        cell.sizeToFit()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of none and the time label visible") {
                    it("has a valid snapshot") {
                        cell.messagePosition = .none
                        cell.isTimeLabelVisible = true
                        cell.sizeToFit()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of firstOfMany") {
                    it("has a valid snapshot") {
                        cell.messagePosition = .firstOfMany
                        cell.sizeToFit()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of firstOfMany and the time label visible") {
                    it("has a valid snapshot") {
                        cell.messagePosition = .firstOfMany
                        cell.isTimeLabelVisible = true
                        cell.sizeToFit()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of middleOfMany") {
                    it("has a valid snapshot") {
                        cell.messagePosition = .middleOfMany
                        cell.sizeToFit()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of middleOfMany and the time label visible") {
                    it("has a valid snapshot") {
                        cell.messagePosition = .middleOfMany
                        cell.isTimeLabelVisible = true
                        cell.sizeToFit()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of lastOfMany") {
                    it("has a valid snapshot") {
                        cell.messagePosition = .lastOfMany
                        cell.sizeToFit()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a message list position of lastOfMany and the time label visible") {
                    it("has a valid snapshot") {
                        cell.messagePosition = .lastOfMany
                        cell.isTimeLabelVisible = true
                        cell.sizeToFit()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
