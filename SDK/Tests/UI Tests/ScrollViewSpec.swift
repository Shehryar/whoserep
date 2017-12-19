//
//  ScrollViewSpec.swift
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

class ScrollViewSpec: QuickSpec {
    override func spec() {
        describe("ScrollView") {
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
                
                func createButton() -> [String: Any] {
                    counter += 1
                    return [
                        "type": "button",
                        "content": [
                            "title": "\(counter)",
                            "action": [
                                "type": "api",
                                "content": [
                                    "requestPath": "foo"
                                ]
                            ]
                        ],
                        "style": [
                            "weight": 0,
                            "width": "100",
                            "height": "100"
                        ]
                    ]
                }
                
                func testScrollView(_ content: [String: Any]) -> UIView {
                    let isVertical = content["orientation"] as? String == "vertical"
                    let (width, height) = isVertical ? (100, 200) : (200, 100)
                    let scrollViewItem = ScrollViewItem(style: style, content: [
                        "root": [
                            "type": "stackView",
                            "content": content,
                            "style": [
                                "width": isVertical ? width : width * 2,
                                "height": isVertical ? height * 2 : height
                            ]
                        ]
                    ])
                    let scrollView = ScrollView(frame: CGRect(x: 0, y: 0, width: width, height: height))
                    scrollView.component = scrollViewItem
                    return scrollView
                }
                
                context("horizontal") {
                    it("has a valid snapshot") {
                        var items: [[String: Any]] = []
                        for _ in 0..<10 {
                            items.append(createButton())
                        }
                        content = ["orientation": "horizontal", "items": items]
                        expect(testScrollView(content)).to(haveValidSnapshot())
                    }
                }
                
                context("vertical") {
                    it("has a valid snapshot") {
                        var items: [[String: Any]] = []
                        for _ in 0..<10 {
                            items.append(createButton())
                        }
                        content = ["orientation": "vertical", "items": items]
                        expect(testScrollView(content)).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
