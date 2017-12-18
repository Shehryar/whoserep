//
//  SeparatorViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 12/18/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class SeparatorViewSpec: QuickSpec {
    override func spec() {
        describe("SeparatorView") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
            }
            
            context("on its own") {
                var style: ComponentStyle!
                var content: [String: Any]!
                
                beforeEach {
                    style = TestUtil.createStyle()
                }
                
                func testSeparator(_ content: [String: Any]) -> UIView {
                    let separatorItem = SeparatorItem(style: style, content: content)
                    let separatorView = SeparatorView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
                    separatorView.component = separatorItem
                    return separatorView
                }
                
                context("horizontal") {
                    it("has a valid snapshot") {
                        content = ["separatorStyle": "horizontal"]
                        expect(testSeparator(content)).to(haveValidSnapshot())
                    }
                }
                
                context("vertical") {
                    it("has a valid snapshot") {
                        content = ["separatorStyle": "vertical"]
                        expect(testSeparator(content)).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
