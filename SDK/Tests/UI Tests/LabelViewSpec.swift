//
//  LabelViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/23/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class LabelViewSpec: QuickSpec {
    override func spec() {
        describe("LabelView") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.createStyle()
            }
            
            context("on its own") {
                context("with default styles") {
                    it("has a valid snapshot") {
                        var style = ComponentStyle()
                        style.alignment = .center
                        style.backgroundColor = .gray
                        style.borderColor = .red
                        style.borderWidth = 1
                        style.color = .blue
                        style.cornerRadius = 10
                        style.fontSize = 22
                        style.letterSpacing = 0.5
                        style.margin = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                        style.padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                        let labelItem = LabelItem(text: "Test Label", style: style)
                        let labelView = LabelView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
                        labelView.component = labelItem
                        expect(labelView).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
