//
//  ComponentLayoutEngineSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 11/28/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ComponentLayoutEngineSpec: QuickSpec {
    let stableImageURL = "https://s3.amazonaws.com/asapp-chat-sdk-historical-releases/fixtures/stable-image.jpg"
    
    override func spec() {
        describe("a vertical stackview layout") {
            let timeout: TimeInterval = 5
            let metadata = EventMetadata(
                isReply: true,
                isAutomatedMessage: true,
                eventId: 0,
                eventType: .srsResponse,
                issueId: 1,
                sendTime: Date())
            
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
            
            context("containing a horizontal stackview with two differently-sized buttons with gravity: fill") {
                it("has a valid snapshot") {
                    let dict = TestUtil.dictForFile(named: "gravity-fill-test")
                    let container = ComponentViewContainer.from(dict)
                    let viewController = ComponentViewController()
                    viewController.componentViewContainer = container
                    expect(viewController.view).to(haveValidSnapshot())
                }
            }
            
            context("containing a single label with a weight of 1") {
                it("has a valid snapshot") {
                    let dict = TestUtil.dictForFile(named: "chat-ended-only-child-weight")
                    let cell = ChatComponentViewMessageCell(style: .default, reuseIdentifier: "cell")
                    cell.message = ChatMessage.fromJSON(dict, with: metadata)
                    cell.sizeToFit()
                    expect(cell).to(haveValidSnapshot())
                }
            }
            
            context("containing two examples of a checkbox with a label") {
                it("has a valid snapshot") {
                    let dict = TestUtil.dictForFile(named: "checkbox-with-label")
                    let container = ComponentViewContainer.from(dict)
                    let viewController = ComponentViewController()
                    viewController.componentViewContainer = container
                    expect(viewController.view).to(haveValidSnapshot())
                }
            }
            
            context("inside a horizontal stackview and with a defined width and containing an image with no size") {
                it("has a valid snapshot") {
                    let dict = TestUtil.dictForFile(named: "carousel-with-images")
                    let cell = ChatCarouselMessageCell(style: .default, reuseIdentifier: "cell")
                    cell.update(ChatMessage.fromJSON(dict, with: metadata), showTransientButtons: false)
                    cell.sizeToFit()
                    expect(cell).to(haveValidSnapshot())
                }
            }
        }
    }
}
