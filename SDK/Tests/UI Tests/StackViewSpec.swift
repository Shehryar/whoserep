//
//  StackViewSpec.swift
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

class StackViewSpec: QuickSpec {
    override func spec() {
        describe("StackView") {
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
                var counter = 0
                
                beforeEach {
                    style = TestUtil.createStyle()
                }
                
                func createLabel() -> [String: Any] {
                    counter += 1
                    return [
                        "type": "label",
                        "content": ["text": "\(counter)"],
                        "style": ["weight": 1, "backgroundColor": "#eeeeee"]
                    ]
                }
                
                func testStackView(_ content: [String: Any]) -> UIView {
                    let stackViewItem = StackViewItem(style: style, content: content)
                    let (width, height) = (content["orientation"] as? String == "vertical") ? (100, 400) : (400, 100)
                    let stackView = StackView(frame: CGRect(x: 0, y: 0, width: width, height: height))
                    stackView.component = stackViewItem
                    return stackView
                }
                
                context("horizontal") {
                    it("has a valid snapshot") {
                        var items: [[String: Any]] = []
                        for _ in 0..<10 {
                            items.append(createLabel())
                        }
                        content = ["orientation": "horizontal", "items": items]
                        expect(testStackView(content)).to(haveValidSnapshot())
                    }
                }
                
                context("vertical") {
                    it("has a valid snapshot") {
                        var items: [[String: Any]] = []
                        for _ in 0..<10 {
                            items.append(createLabel())
                        }
                        content = ["orientation": "vertical", "items": items]
                        expect(testStackView(content)).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
