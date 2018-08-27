//
//  ButtonViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 11/13/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ButtonViewSpec: QuickSpec {
    override func spec() {
        describe("ButtonView") {
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
                    
                    content = [
                        "title": "Button",
                        "action": [
                            "type": "api",
                            "content": [
                                "requestPath": "foo"
                            ]
                        ]
                    ]
                }
                
                context("with primaryButtonRoundingStyle set to .radius(0)") {
                    it("has a valid snapshot") {
                        ASAPP.styles.primaryButtonRoundingStyle = .radius(0)
                        let buttonItem = ButtonItem(style: style, content: content)
                        let buttonView = ButtonView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        buttonView.component = buttonItem
                        expect(buttonView).to(haveValidSnapshot())
                    }
                }
                
                context("with primaryButtonRoundingStyle set to .pill") {
                    it("has a valid snapshot") {
                        ASAPP.styles.primaryButtonRoundingStyle = .pill
                        let buttonItem = ButtonItem(style: style, content: content)
                        let buttonView = ButtonView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        buttonView.component = buttonItem
                        expect(buttonView).to(haveValidSnapshot())
                    }
                }
                
                context("with primaryButtonRoundingStyle set to .radius(6)") {
                    it("has a valid snapshot") {
                        ASAPP.styles.primaryButtonRoundingStyle = .radius(12)
                        let buttonItem = ButtonItem(style: style, content: content)
                        let buttonView = ButtonView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        buttonView.component = buttonItem
                        expect(buttonView).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
