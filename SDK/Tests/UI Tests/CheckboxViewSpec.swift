//
//  CheckboxViewSpec.swift
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

class CheckboxViewSpec: QuickSpec {
    override func spec() {
        describe("CheckboxView") {
            var style: ComponentStyle!
            var content: [String: Any]!
            
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
            }
            
            context("containing only a Checkbox") {
                beforeEach {
                    style = TestUtil.createStyle()
                    content = [
                        "root": [
                            "type": "checkbox"
                        ]
                    ]
                }
                
                context("not checked") {
                    it("has a valid snapshot") {
                        let checkboxViewItem = CheckboxViewItem(style: style, content: content)
                        let checkboxView = CheckboxView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                        checkboxView.component = checkboxViewItem
                        expect(checkboxView).to(haveValidSnapshot())
                    }
                }
                
                context("checked") {
                    it("has a valid snapshot") {
                        let checkboxViewItem = CheckboxViewItem(isChecked: true, style: style, content: content)
                        let checkboxView = CheckboxView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                        checkboxView.component = checkboxViewItem
                        expect(checkboxView).to(haveValidSnapshot())
                    }
                }
            }
            
            context("containing a StackView with a Label and a Checkbox") {
                beforeEach {
                    style = TestUtil.createStyle()
                    content = [
                        "root": [
                            "type": "stackView",
                            "content": [
                                "orientation": "horizontal",
                                "items": [
                                    ["type": "checkbox"],
                                    [
                                        "type": "label",
                                        "content": [
                                            "text": "Checkbox"
                                        ],
                                        "style": [
                                            "marginLeft": 10
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                }
                
                context("not checked") {
                    it("has a valid snapshot") {
                        let checkboxViewItem = CheckboxViewItem(style: style, content: content)
                        let checkboxView = CheckboxView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        checkboxView.component = checkboxViewItem
                        expect(checkboxView).to(haveValidSnapshot())
                    }
                }
                
                context("checked") {
                    it("has a valid snapshot") {
                        let checkboxViewItem = CheckboxViewItem(isChecked: true, style: style, content: content)
                        let checkboxView = CheckboxView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        checkboxView.component = checkboxViewItem
                        expect(checkboxView).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
