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
    let stableImageURL = "https://s3.amazonaws.com/asapp-chat-sdk-historical-releases/fixtures/stable-image.jpg"
    
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
                
                let dummy = UIImageView(frame: CGRect(x: 0, y: 0, width: 260, height: 260))
                waitUntil(timeout: timeout) { done in
                    dummy.sd_setImage(with: URL(string: self.stableImageURL)!) { _, _, _, _ in
                        done()
                    }
                }
            }
            
            context("a test layout with many images") {
                it("has a valid snapshot") {
                    TestUtil.createStyle()
                    let dict = TestUtil.dictForFile(named: "image-layout")
                    let container = ComponentViewContainer.from(dict)
                    let viewController = ComponentViewController()
                    viewController.componentViewContainer = container
                    viewController.updateFrames()
                    let scrollView = viewController.rootView as! ScrollView
                    expect(scrollView.contentView!.view).to(haveValidSnapshot())
                }
            }

            context("a test layout with one image among other components") {
                it("has a valid snapshot") {
                    let dict = TestUtil.dictForFile(named: "feedback-form-image")
                    let container = ComponentViewContainer.from(dict)
                    let viewController = ComponentViewController()
                    viewController.componentViewContainer = container
                    expect(viewController.view).to(haveValidSnapshot())
                }
            }
            
            context("a test layout with one image without a size in a stack view with a width") {
                it("has a valid snapshot") {
                    let dict = TestUtil.dictForFile(named: "image-no-size")
                    let container = ComponentViewContainer.from(dict)
                    let viewController = ComponentViewController()
                    viewController.componentViewContainer = container
                    expect(viewController.view).to(haveValidSnapshot())
                }
            }
        }
    }
}
