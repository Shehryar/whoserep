//
//  ChatPictureViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/18/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ChatPictureViewSpec: QuickSpec {
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
    
    override func spec() {
        describe("ChatPictureView") {
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
            }
            
            context("on its own") {
                it("has a valid snapshot") {
                    let view = ChatPictureView(frame: .zero)
                    view.message = ChatMessage(text: "Test", attachment: attachment, buttons: nil, quickReplies: nil, metadata: self.metadata)
                    let size = view.sizeThatFits(CGSize(width: 150, height: CGFloat.greatestFiniteMagnitude))
                    view.frame = CGRect(origin: .zero, size: size)
                    
                    waitUntil(timeout: timeout) { done in
                        Dispatcher.delay(.seconds(timeout - 0.1)) {
                            expect(view).to(haveValidSnapshot())
                            done()
                        }
                    }
                }
            }
            
            context("without loading the image") {
                it("has a valid snapshot") {
                    let view = ChatPictureView(frame: .zero)
                    view.disableImageLoading = true
                    view.message = ChatMessage(text: "Test", attachment: attachment, buttons: nil, quickReplies: nil, metadata: self.metadata)
                    let size = view.sizeThatFits(CGSize(width: 150, height: CGFloat.greatestFiniteMagnitude))
                    view.frame = CGRect(origin: .zero, size: size)
                    
                    waitUntil(timeout: timeout) { done in
                        Dispatcher.delay(.seconds(timeout - 0.1)) {
                            expect(view).to(haveValidSnapshot())
                            done()
                        }
                    }
                }
            }
            
            context("with message buttons") {
                it("has a valid snapshot") {
                    let view = ChatPictureView(frame: .zero)
                    let messageButtons = [
                        QuickReply(title: "First", action: Action(content: "1")!, icon: nil, isTransient: false),
                        QuickReply(title: "Second", action: Action(content: "1")!, icon: nil, isTransient: false),
                        QuickReply(title: "Third", action: WebPageAction(content: ["url": "http://asapp.com"])!, icon: nil, isTransient: true)
                    ]
                    view.message = ChatMessage(text: "Test", attachment: attachment, buttons: messageButtons, quickReplies: nil, metadata: self.metadata)
                    view.messageButtonsView = MessageButtonsView(messageButtons: messageButtons)
                    let size = view.sizeThatFits(CGSize(width: 150, height: CGFloat.greatestFiniteMagnitude))
                    view.frame = CGRect(origin: .zero, size: size)
                    
                    waitUntil(timeout: timeout) { done in
                        Dispatcher.delay(.seconds(timeout - 0.1)) {
                            expect(view).to(haveValidSnapshot())
                            done()
                        }
                    }
                }
            }
        }
    }
}
