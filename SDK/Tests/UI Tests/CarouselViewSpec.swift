//
//  CarouselViewSpec.swift
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

class CarouselViewSpec: QuickSpec {
    override func spec() {
        describe("CarouselView") {
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
                
                context("with three items") {
                    beforeEach {
                        content = [
                            "items": [
                                ["type": "label", "content": ["text": "A"]],
                                ["type": "label", "content": ["text": "B"]],
                                ["type": "label", "content": ["text": "C"]]
                            ]
                        ]
                    }
                    
                    it("has a valid snapshot") {
                        let carouselItem = CarouselViewItem(style: style, content: content)
                        let carouselView = CarouselView(frame: CGRect(x: 0, y: 0, width: 250, height: 100))
                        carouselView.component = carouselItem
                        expect(carouselView).to(haveValidSnapshot())
                    }
                }
                
                context("with a page control") {
                    beforeEach {
                        content = [
                            "items": [
                                ["type": "label", "content": ["text": "A"]],
                                ["type": "label", "content": ["text": "B"]],
                                ["type": "label", "content": ["text": "C"]]
                            ],
                            "visibleItemCount": CGFloat(1.5),
                            "pageControl": [
                                "type": "pageControl"
                            ],
                            "pagingEnabled": true
                        ]
                    }
                    
                    it("has a valid snapshot") {
                        let carouselItem = CarouselViewItem(style: style, content: content)
                        let carouselView = CarouselView(frame: CGRect(x: 0, y: 0, width: 250, height: 100))
                        carouselView.component = carouselItem
                        expect(carouselView).to(haveValidSnapshot())
                    }
                }
                
                context("with a page control and all items visible") {
                    beforeEach {
                        content = [
                            "items": [
                                ["type": "label", "content": ["text": "A"]],
                                ["type": "label", "content": ["text": "B"]],
                                ["type": "label", "content": ["text": "C"]]
                            ],
                            "visibleItemCount": CGFloat(3),
                            "pageControl": [
                                "type": "pageControl"
                            ],
                            "pagingEnabled": true
                        ]
                    }
                    
                    it("has a valid snapshot") {
                        let carouselItem = CarouselViewItem(style: style, content: content)
                        let carouselView = CarouselView(frame: CGRect(x: 0, y: 0, width: 250, height: 100))
                        carouselView.component = carouselItem
                        expect(carouselView).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
