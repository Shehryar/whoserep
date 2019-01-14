//
//  NavCloseBarButtonItemSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 12/24/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class NavCloseBarButtonItemSpec: QuickSpec {
    override func spec() {
        describe("NavCloseBarButtonItem") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
                TestUtil.createStyle()
                ASAPP.strings = ASAPPStrings()
            }
            
            var toolbar: UIToolbar!
            
            beforeEach {
                toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 64))
                toolbar.backgroundColor = .gray
            }
            
            context("with a push segue") {
                context("in the chat view on the left with a title") {
                    it("has a valid snapshot") {
                        let button = NavCloseBarButtonItem(location: .chat, side: .left)
                            .configSegue(.push)
                        toolbar.items = [button]
                        expect(toolbar).to(haveValidSnapshot())
                    }
                }
                
                context("in the chat view on the right with a title") {
                    it("has a valid snapshot") {
                        let button = NavCloseBarButtonItem(location: .chat, side: .right)
                            .configSegue(.push)
                        toolbar.items = [button]
                        expect(toolbar).to(haveValidSnapshot())
                    }
                }
            }
            
            context("with a present segue") {
                context("in the chat view on the left with a title") {
                    it("has a valid snapshot") {
                        let button = NavCloseBarButtonItem(location: .chat, side: .left)
                            .configSegue(.present)
                        toolbar.items = [button]
                        expect(toolbar).to(haveValidSnapshot())
                    }
                }
                
                context("in the chat view on the right with a title") {
                    it("has a valid snapshot") {
                        let button = NavCloseBarButtonItem(location: .chat, side: .right)
                            .configSegue(.present)
                        toolbar.items = [button]
                        expect(toolbar).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
