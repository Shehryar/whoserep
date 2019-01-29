//
//  NavBarButtonItemSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/23/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class NavBarButtonItemSpec: QuickSpec {
    override func spec() {
        describe("NavBarButtonItem") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
            }
            
            var toolbar: UIToolbar!
            
            beforeEach {
                toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 64))
                toolbar.backgroundColor = .gray
                ASAPP.strings = ASAPPStrings()
                TestUtil.createStyle()
            }
            
            context("in the chat view on the left with a title and with default styles") {
                it("has a valid snapshot") {
                    let button = NavBarButtonItem(location: .chat, side: .left)
                    button.configTitle("Button Title")
                    toolbar.items = [button]
                    expect(toolbar).to(haveValidSnapshot())
                }
            }
            
            context("in the chat view on the right with a title and with default styles") {
                it("has a valid snapshot") {
                    let button = NavBarButtonItem(location: .chat, side: .right)
                    button.configTitle("Button Title")
                    toolbar.items = [button]
                    expect(toolbar).to(haveValidSnapshot())
                }
            }
        }
    }
}