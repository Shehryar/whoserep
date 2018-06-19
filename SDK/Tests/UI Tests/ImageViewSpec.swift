//
//  ImageViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 5/16/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ImageViewSpec: QuickSpec {
    override func spec() {
        describe("ImageView") {
            let timeout: TimeInterval = 2
            
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
                TestUtil.createStyle()
            }
            
            context("a test layout with many images") {
                it("has a valid snapshot") {
                    TestUtil.createStyle()
                    let dict = TestUtil.dictForFile(named: "image-layout")
                    let container = ComponentViewContainer.from(dict)
                    let viewController = ComponentViewController()
                    viewController.componentViewContainer = container
                    waitUntil(timeout: timeout) { done in
                        Dispatcher.delay(.seconds(timeout - 0.1)) {
                            expect(viewController.view).to(haveValidSnapshot())
                            done()
                        }
                    }
                }
            }
            
            context("a test layout with one image among other components") {
                it("has a valid snapshot") {
                    let dict = TestUtil.dictForFile(named: "feedback-form-image")
                    let container = ComponentViewContainer.from(dict)
                    let viewController = ComponentViewController()
                    viewController.componentViewContainer = container
                    waitUntil(timeout: timeout) { done in
                        Dispatcher.delay(.seconds(timeout - 0.1)) {
                            expect(viewController.view).to(haveValidSnapshot())
                            done()
                        }
                    }
                }
            }
        }
    }
}
