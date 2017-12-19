//
//  IconViewSpec.swift
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

class IconViewSpec: QuickSpec {
    override func spec() {
        describe("IconView") {
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
                        "icon": "xThick"
                    ]
                }
                
                it("has a valid snapshot") {
                    let iconItem = IconItem(style: style, content: content)
                    let iconView = IconView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                    iconView.component = iconItem
                    expect(iconView).to(haveValidSnapshot())
                }
            }
        }
    }
}
