//
//  DropdownViewSpec.swift
//  Tests
//
//  Created by Hans Hyttinen on 12/13/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class DropdownViewSpec: QuickSpec {
    override func spec() {
        describe("DropdownView") {            
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
                
                beforeEach {
                    style = TestUtil.createStyle()
                }
                
                context("with a placeholder") {
                    it("has a valid snapshot") {
                        let content: [String: Any] = [
                            "placeholder": "CHOOSE AN OPTION",
                            "options": [
                                ["text": "A", "value": "A"],
                                ["text": "B", "value": "B"]
                            ]
                        ]
                        let dropdownItem = DropdownItem(style: style, content: content)
                        let dropdownView = DropdownView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        dropdownView.component = dropdownItem
                        expect(dropdownView).to(haveValidSnapshot())
                    }
                }
                
                context("without a placeholder") {
                    it("has a valid snapshot") {
                        let content: [String: Any] = [
                            "options": [
                                ["text": "A", "value": "A"],
                                ["text": "B", "value": "B"]
                            ]
                        ]
                        let dropdownItem = DropdownItem(style: style, content: content)
                        let dropdownView = DropdownView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        dropdownView.component = dropdownItem
                        expect(dropdownView).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
