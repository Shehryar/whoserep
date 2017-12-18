//
//  ProgressBarViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 12/15/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ProgressBarViewSpec: QuickSpec {
    override func spec() {
        describe("ProgressBarView") {
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
                
                func testBar(_ content: [String: Any]) -> UIView {
                    let progressBarItem = ProgressBarItem(style: style, content: content)
                    let progressBarView = ProgressBarView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
                    progressBarView.component = progressBarItem
                    return progressBarView
                }
                
                context("empty") {
                    it("has a valid snapshot") {
                        content = ["fillPercentage": CGFloat(0)]
                        expect(testBar(content)).to(haveValidSnapshot())
                    }
                }
                
                context("halfway") {
                    it("has a valid snapshot") {
                        content = ["fillPercentage": CGFloat(0.5)]
                        expect(testBar(content)).to(haveValidSnapshot())
                    }
                }
                
                context("full") {
                    it("has a valid snapshot") {
                        content = ["fillPercentage": CGFloat(1)]
                        expect(testBar(content)).to(haveValidSnapshot())
                    }
                }
                
                context("halfway with custom colors") {
                    it("has a valid snapshot") {
                        content = [
                            "fillPercentage": CGFloat(0.5),
                            "trackColor": "#cccccc",
                            "trackFillColor": "#009900"
                        ]
                        expect(testBar(content)).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
