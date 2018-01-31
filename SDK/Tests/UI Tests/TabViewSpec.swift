//
//  TabViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 12/25/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class TabViewSpec: QuickSpec {
    override func spec() {
        describe("TabView") {
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
                
                context("with one tab") {
                    it("has a valid snapshot") {
                        content = [
                            "pages": [
                                [
                                    "title": "A",
                                    "root": [
                                        "type": "label",
                                        "content": [
                                            "text": "Label A"
                                        ]
                                    ]
                                ]
                            ]
                        ]
                        let tabViewItem = TabViewItem(style: style, content: content)
                        let tabView = TabView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
                        tabView.component = tabViewItem
                        expect(tabView).to(haveValidSnapshot())
                    }
                }
                
                context("with two tabs") {
                    it("has a valid snapshot") {
                        content = [
                            "pages": [
                                [
                                    "title": "A",
                                    "root": [
                                        "type": "label",
                                        "content": [
                                            "text": "Label A"
                                        ]
                                    ]
                                ],
                                [
                                    "title": "B",
                                    "root": [
                                        "type": "label",
                                        "content": [
                                            "text": "Label B"
                                        ]
                                    ]
                                ]
                            ]
                        ]
                        let tabViewItem = TabViewItem(style: style, content: content)
                        let tabView = TabView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
                        tabView.component = tabViewItem
                        expect(tabView).to(haveValidSnapshot())
                    }
                }
                
                context("with three tabs") {
                    var tabView: TabView!
                    
                    beforeEach {
                        content = [
                            "pages": [
                                [
                                    "title": "A",
                                    "root": [
                                        "type": "label",
                                        "content": [
                                            "text": "Label A"
                                        ]
                                    ]
                                ],
                                [
                                    "title": "B",
                                    "root": [
                                        "type": "label",
                                        "content": [
                                            "text": "Label B"
                                        ]
                                    ]
                                ],
                                [
                                    "title": "C",
                                    "root": [
                                        "type": "label",
                                        "content": [
                                            "text": "Label C"
                                        ]
                                    ]
                                ]
                            ]
                        ]
                        let tabViewItem = TabViewItem(style: style, content: content)
                        tabView = TabView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
                        tabView.component = tabViewItem
                    }
                    
                    it("has a valid snapshot") {
                        expect(tabView).to(haveValidSnapshot())
                    }
                    
                    context("with the second tab selected") {
                        it("has a valid snapshot") {
                            tabView.setVisiblePageIndex(1)
                            expect(tabView).to(haveValidSnapshot())
                        }
                    }
                }
            }
        }
    }
}
