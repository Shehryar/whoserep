//
//  ChatComponentViewMessageCellSpec.swift
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

class ChatComponentViewMessageCellSpec: QuickSpec {
    override func spec() {
        describe("ChatComponentViewMessageCell") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
            }
            
            context("on its own") {
                var metadata: EventMetadata!
                
                beforeEach {
                    TestUtil.createStyle()
                    
                    metadata = EventMetadata(
                        isReply: true,
                        isAutomatedMessage: true,
                        eventId: 0,
                        eventType: .srsResponse,
                        issueId: 1,
                        sendTime: Date())
                }
                
                context("with a simple component view attachment") {
                    it("has a valid snapshot") {
                        let dict = [
                            "formatVersion": 1,
                            "text": "Text",
                            "attachment": [
                                "type": "componentView",
                                "content": [
                                    "formatVersion": 1,
                                    "title": "View",
                                    "root": [
                                        "type": "label",
                                        "content": [
                                            "text": "Hello, world"
                                        ],
                                        "style": [
                                            "padding": "20 20"
                                        ]
                                    ]
                                ]
                            ]
                        ] as [String: Any]
                        
                        let cell = ChatComponentViewMessageCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
                        cell.message = ChatMessage.fromJSON(dict, with: metadata)
                        cell.sizeToFit()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
