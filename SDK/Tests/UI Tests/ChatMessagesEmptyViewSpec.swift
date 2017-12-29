//
//  ChatMessagesEmptyViewSpec.swift
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

class ChatMessagesEmptyViewSpec: QuickSpec {
    override func spec() {
        describe("ChatMessagesEmptyView") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
            }
            
            beforeEach {
                TestUtil.createStyle()
            }
            
            context("with a short title and message") {
                it("has a valid snapshot") {
                    let view = ChatMessagesEmptyView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
                    view.title = "Title"
                    view.message = "Message"
                    expect(view).to(haveValidSnapshot())
                }
            }
            
            context("with a long title and message") {
                it("has a valid snapshot") {
                    let view = ChatMessagesEmptyView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
                    view.title = "Qui dolorem ipsum, quia dolor sit amet"
                    view.message = "Consectetur adipisci velit, sed quia non numquam eius modi tempora incidunt"
                    expect(view).to(haveValidSnapshot())
                }
            }
        }
    }
}
