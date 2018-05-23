//
//  ChatCarouselMessageCellSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 5/21/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ChatCarouselMessageCellSpec: QuickSpec {
    override func spec() {
        describe("ChatCarouselMessageCell") {
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
                
                context("with two cards of different heights") {
                    let dict = TestUtil.dictForFile(named: "carousel-uneven")
                    
                    context("with transient buttons shown") {
                        it("has a valid snapshot") {
                            let cell = ChatCarouselMessageCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
                            let message = ChatMessage.fromJSON(dict, with: metadata)
                            cell.update(message, showTransientButtons: true)
                            cell.sizeToFit()
                            expect(cell).to(haveValidSnapshot())
                        }
                    }
                    
                    context("with transient buttons hidden") {
                        it("has a valid snapshot") {
                            let cell = ChatCarouselMessageCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
                            let message = ChatMessage.fromJSON(dict, with: metadata)
                            cell.update(message, showTransientButtons: false)
                            cell.sizeToFit()
                            expect(cell).to(haveValidSnapshot())
                        }
                    }
                }
            }
        }
    }
}
