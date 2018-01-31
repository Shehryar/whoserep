//
//  TableViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 12/26/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class TableViewSpec: QuickSpec {
    override func spec() {
        describe("TableView") {
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
                
                context("with one section") {
                    it("has a valid snapshot") {
                        content = [
                            "sections": [
                                [
                                    "header": [
                                        "type": "label",
                                        "content": [
                                            "text": "Label A"
                                        ]
                                    ],
                                    "rows": [
                                        [
                                            "type": "label",
                                            "content": [
                                                "text": "Label B"
                                            ]
                                        ],
                                        [
                                            "type": "label",
                                            "content": [
                                                "text": "Label C"
                                            ]
                                        ],
                                        [
                                            "type": "label",
                                            "content": [
                                                "text": "Label D"
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                        let tableViewItem = TableViewItem(style: style, content: content)
                        let tableView = TableView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
                        tableView.component = tableViewItem
                        expect(tableView).to(haveValidSnapshot())
                    }
                }
                
                context("with two sections") {
                    it("has a valid snapshot") {
                        content = [
                            "sections": [
                                [
                                    "header": [
                                        "type": "label",
                                        "content": [
                                            "text": "Section 1"
                                        ]
                                    ],
                                    "rows": [
                                        [
                                            "type": "label",
                                            "content": [
                                                "text": "Label A"
                                            ]
                                        ],
                                        [
                                            "type": "label",
                                            "content": [
                                                "text": "Label B"
                                            ]
                                        ],
                                        [
                                            "type": "label",
                                            "content": [
                                                "text": "Label C"
                                            ]
                                        ],
                                        [
                                            "type": "label",
                                            "content": [
                                                "text": "Label D"
                                            ]
                                        ],
                                        [
                                            "type": "label",
                                            "content": [
                                                "text": "Label E"
                                            ]
                                        ]
                                    ]
                                ],
                                [
                                    "header": [
                                        "type": "label",
                                        "content": [
                                            "text": "Section 2"
                                        ]
                                    ],
                                    "rows": [
                                        [
                                            "type": "label",
                                            "content": [
                                                "text": "Label D"
                                            ]
                                        ],
                                        [
                                            "type": "label",
                                            "content": [
                                                "text": "Label E"
                                            ]
                                        ],
                                        [
                                            "type": "label",
                                            "content": [
                                                "text": "Label F"
                                            ]
                                        ],
                                        [
                                            "type": "label",
                                            "content": [
                                                "text": "Label G"
                                            ]
                                        ],
                                        [
                                            "type": "label",
                                            "content": [
                                                "text": "Label H"
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                        let tableViewItem = TableViewItem(style: style, content: content)
                        let tableView = TableView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
                        tableView.component = tableViewItem
                        expect(tableView).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
