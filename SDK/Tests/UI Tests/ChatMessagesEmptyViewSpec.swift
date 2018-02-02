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
            
            context("by itself") {
                it("has a valid snapshot") {
                    let view = ChatMessagesEmptyView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
                    expect(view).to(haveValidSnapshot())
                }
            }
        }
    }
}
