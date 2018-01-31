//
//  ChatMessagesTimeHeaderViewSpec.swift
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

class ChatMessagesTimeHeaderViewSpec: QuickSpec {
    override func spec() {
        describe("ChatMessagesTimeHeaderView") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
            }
            
            context("on its own") {
                beforeEach {
                    TestUtil.createStyle()
                }
                
                it("has a valid snapshot") {
                    let view = ChatMessagesTimeHeaderView(frame: CGRect(x: 0, y: 0, width: 350, height: 50))
                    view.time = Date(timeIntervalSince1970: 327511937)
                    view.sizeToFit()
                    expect(view).to(haveValidSnapshot())
                }
            }
        }
    }
}
