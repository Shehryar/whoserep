//
//  QuickRepliesListViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/16/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class QuickRepliesListViewSpec: QuickSpec {
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
        describe("QuickRepliesListView") {
            var style: ComponentStyle!
            
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
                style = TestUtil.createStyle()
            }
            
            context("on its own") {
                func getMessage() -> ChatMessage {
                    return ChatMessage(text: "", attachment: nil, buttons: nil, quickReplies: [
                        QuickReply(title: "First", action: Action(content: "1")!, icon: nil, isTransient: false),
                        QuickReply(title: "Lorem ipsum dolor sit amet consectetuer esset", action: Action(content: "2")!, icon: nil, isTransient: false),
                        QuickReply(title: "Lorem ipsum dolor sit amet consectetuer esset adipiscing elit", action: Action(content: "3")!, icon: nil, isTransient: false),
                        QuickReply(title: "Fourth", action: Action(content: "4")!, icon: nil, isTransient: false)
                    ], metadata: metadata)!
                }
                
                context("with default styles") {
                    it("has a valid snapshot") {
                        let view = QuickRepliesListView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
                        view.update(for: getMessage(), shouldAnimateUp: false, animated: false)
                        expect(view).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
