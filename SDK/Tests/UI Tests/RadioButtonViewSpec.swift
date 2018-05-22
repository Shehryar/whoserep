//
//  RadioButtonViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 5/14/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class RadioButtonViewSpec: QuickSpec {
    override func spec() {
        describe("RadioButtonView") {
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
            
            context("containing only a RadioButton") {
                beforeEach {
                    style = TestUtil.createStyle()
                    content = [
                        "root": [
                            "type": "radioButton",
                            "gravity": "middle"
                        ]
                    ]
                }
                
                context("not selected") {
                    it("has a valid snapshot") {
                        let radioButtonViewItem = RadioButtonViewItem(style: style, content: content)
                        let radioButtonView = RadioButtonView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                        radioButtonView.component = radioButtonViewItem
                        expect(radioButtonView).to(haveValidSnapshot())
                    }
                }
                
                context("selected") {
                    it("has a valid snapshot") {
                        let radioButtonViewItem = RadioButtonViewItem(style: style, content: content)
                        let radioButtonView = RadioButtonView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                        radioButtonView.component = radioButtonViewItem
                        radioButtonView.isSelected = true
                        expect(radioButtonView).to(haveValidSnapshot())
                    }
                }
            }
            
            context("containing a StackView with a Label and a RadioButton") {
                beforeEach {
                    style = TestUtil.createStyle()
                    content = [
                        "root": [
                            "type": "stackView",
                            "content": [
                                "orientation": "horizontal",
                                "items": [
                                    [
                                        "type": "radioButton",
                                        "content": [],
                                        "style": [
                                            "gravity": "middle"
                                        ]
                                    ],
                                    [
                                        "type": "label",
                                        "content": [
                                            "text": "Radio Button"
                                        ],
                                        "style": [
                                            "marginLeft": 10
                                        ]
                                    ]
                                ]
                            ],
                            "style": [
                                "gravity": "middle"
                            ]
                        ]
                    ]
                }
                
                context("not checked") {
                    it("has a valid snapshot") {
                        let radioButtonViewItem = RadioButtonViewItem(style: style, content: content)
                        let radioButtonView = RadioButtonView(frame: .zero)
                        radioButtonView.component = radioButtonViewItem
                        let size = radioButtonView.sizeThatFits(CGSize(width: 250, height: CGFloat.greatestFiniteMagnitude))
                        radioButtonView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                        radioButtonView.updateFrames()
                        expect(radioButtonView).to(haveValidSnapshot())
                    }
                }
                
                context("checked") {
                    it("has a valid snapshot") {
                        let radioButtonViewItem = RadioButtonViewItem(style: style, content: content)
                        let radioButtonView = RadioButtonView(frame: .zero)
                        radioButtonView.component = radioButtonViewItem
                        let size = radioButtonView.sizeThatFits(CGSize(width: 250, height: CGFloat.greatestFiniteMagnitude))
                        radioButtonView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                        radioButtonView.updateFrames()
                        radioButtonView.isSelected = true
                        expect(radioButtonView).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
