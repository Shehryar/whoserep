//
//  SliderViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/16/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class SliderViewSpec: QuickSpec {
    override func spec() {
        describe("SliderView") {
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
                
                func getView(with style: ComponentStyle, showLabel: Bool) -> SliderView {
                    let labelContent = showLabel ? ["label": ["type": "label", "content": ["text": ""]]] : [:]
                    let sliderItem = SliderItem(style: style, content: labelContent)
                    let slider = SliderView(frame: CGRect(x: 0, y: 0, width: 375, height: CGFloat.greatestFiniteMagnitude))
                    slider.component = sliderItem
                    let size = slider.sizeThatFits(slider.frame.size)
                    slider.frame = CGRect(x: 0, y: 0, width: slider.frame.width, height: size.height)
                    return slider
                }
                
                beforeEach {
                    style = TestUtil.createStyle()
                }
                
                context("left alignment") {
                    it("has a valid snapshot") {
                        style.alignment = .left
                        let scale = getView(with: style, showLabel: false)
                        expect(scale).to(haveValidSnapshot())
                    }
                }
                
                context("fill alignment") {
                    it("has a valid snapshot") {
                        style.alignment = .fill
                        let scale = getView(with: style, showLabel: true)
                        expect(scale).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
