//
//  ChatTypingIndicatorCellSpec.swift
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

class ChatTypingIndicatorCellSpec: QuickSpec {
    override func spec() {
        describe("ChatTypingIndicatorCell") {
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
                    let cell = ChatTypingIndicatorCell(style: .default, reuseIdentifier: "cell")
                    cell.sizeToFit()
                    expect(cell).to(haveValidSnapshot())
                }
            }
        }
    }
}
