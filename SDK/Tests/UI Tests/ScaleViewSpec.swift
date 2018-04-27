//
//  ScaleViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 4/23/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ScaleViewSpec: QuickSpec {
    override func spec() {
        describe("ScaleView") {
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
                
                context("horizontal") {
                    it("has a valid snapshot") {
                        let scaleItem = ScaleItem(style: style)
                        let scale = ScaleView(frame: CGRect(x: 0, y: 0, width: 282, height: 80))
                        scale.component = scaleItem
                        let size = scale.sizeThatFits(CGSize(width: 282, height: CGFloat.greatestFiniteMagnitude))
                        scale.frame = CGRect(x: 0, y: 0, width: scale.frame.width, height: size.height)
                        expect(scale).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
