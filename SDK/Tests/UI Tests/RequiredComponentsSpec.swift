//
//  RequiredComponentsSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/25/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class RequiredComponentsSpec: QuickSpec {
    override func spec() {
        describe("components in a form") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
            }
            
            context("without the required flag") {
                it("has a valid snapshot") {
                    let json = TestUtil.jsonForFile(named: "change-pin-form-no-required")
                    let container = ComponentViewContainer.from(json)
                    let viewController = ComponentViewController()
                    viewController.componentViewContainer = container
                    expect(viewController.view).to(haveValidSnapshot())
                }
            }
            
            context("with the required flag") {
                it("has a valid snapshot") {
                    let json = TestUtil.jsonForFile(named: "change-pin-form")
                    let container = ComponentViewContainer.from(json)
                    let viewController = ComponentViewController()
                    viewController.componentViewContainer = container
                    expect(viewController.view).to(haveValidSnapshot())
                }
            }
            
            context("validated when left empty with the required flag") {
                it("has a valid snapshot") {
                    let json = TestUtil.jsonForFile(named: "change-pin-form")
                    let container = ComponentViewContainer.from(json)
                    let viewController = ComponentViewController()
                    viewController.componentViewContainer = container
                    viewController.validateRequiredInputs()
                    expect(viewController.view).to(haveValidSnapshot())
                }
            }
            
            context("with the required flag in a form with proper padding") {
                it("has a valid snapshot") {
                    let json = TestUtil.jsonForFile(named: "change-pin-form-proper-padding")
                    let container = ComponentViewContainer.from(json)
                    let viewController = ComponentViewController()
                    viewController.componentViewContainer = container
                    expect(viewController.view).to(haveValidSnapshot())
                }
            }
            
            context("validated when left empty with the required flag in a form with proper padding") {
                it("has a valid snapshot") {
                    let json = TestUtil.jsonForFile(named: "change-pin-form-proper-padding")
                    let container = ComponentViewContainer.from(json)
                    let viewController = ComponentViewController()
                    viewController.componentViewContainer = container
                    viewController.validateRequiredInputs()
                    expect(viewController.view).to(haveValidSnapshot())
                }
            }
        }
    }
}
