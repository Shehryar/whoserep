//
//  RadioButtonsContainerViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 11/9/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class RadioButtonsContainerViewSpec: QuickSpec {
    override func spec() {
        describe("RadioButtonsContainerView") {
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
            
            context("containing three radio buttons") {
                beforeEach {
                    style = TestUtil.createStyle()
                    content = TestUtil.dictForFile(named: "radio-buttons-container")
                }
                
                context("not selected") {
                    it("has a valid snapshot") {
                        let containerItem = RadioButtonsContainerItem(style: style, content: content)
                        let containerView = RadioButtonsContainerView(frame: .zero)
                        containerView.component = containerItem
                        let size = containerView.sizeThatFits(CGSize(width: 250, height: CGFloat.greatestFiniteMagnitude))
                        containerView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                        containerView.updateFrames()
                        expect(containerView).to(haveValidSnapshot())
                    }
                }
                
                context("second radio button selected") {
                    it("has a valid snapshot") {
                        let containerItem = RadioButtonsContainerItem(style: style, content: content)
                        let containerView = RadioButtonsContainerView(frame: .zero)
                        containerView.component = containerItem
                        let size = containerView.sizeThatFits(CGSize(width: 250, height: CGFloat.greatestFiniteMagnitude))
                        containerView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                        containerView.updateFrames()
                        
                        let second = containerView.radioButtonViews![1]
                        containerView.didTap(second)
                        
                        expect(containerView).to(haveValidSnapshot())
                    }
                }
                
                context("third radio button selected after the second") {
                    it("has a valid snapshot") {
                        let containerItem = RadioButtonsContainerItem(style: style, content: content)
                        let containerView = RadioButtonsContainerView(frame: .zero)
                        containerView.component = containerItem
                        let size = containerView.sizeThatFits(CGSize(width: 250, height: CGFloat.greatestFiniteMagnitude))
                        containerView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                        containerView.updateFrames()
                        
                        let second = containerView.radioButtonViews![1]
                        containerView.didTap(second)
                        
                        let third = containerView.radioButtonViews![2]
                        containerView.didTap(third)
                        
                        expect(containerView).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
