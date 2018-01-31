//
//  InvalidInputsSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/27/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class InvalidInputsSpec: QuickSpec {
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
            
            beforeEach {
                ASAPP.strings = ASAPPStrings()
                ASAPP.styles = ASAPPStyles()
            }
            
            context("marked invalid with no specific error messages") {
                it("has a valid snapshot") {
                    let dict = TestUtil.dictForFile(named: "change-pin-form-proper-padding")
                    let container = ComponentViewContainer.from(dict)
                    let viewController = ComponentViewController()
                    viewController.componentViewContainer = container
                    viewController.markInvalidInputs([
                        "newPin": "",
                        "confirmNewPin": ""
                    ])
                    expect(viewController.view).to(haveValidSnapshot())
                }
            }
            
            context("marked invalid, one with a specific error message and one without") {
                it("has a valid snapshot") {
                    let dict = TestUtil.dictForFile(named: "change-pin-form-proper-padding")
                    let container = ComponentViewContainer.from(dict)
                    let viewController = ComponentViewController()
                    viewController.componentViewContainer = container
                    viewController.markInvalidInputs([
                        "newPin": "Please enter a valid 4-digit PIN",
                        "confirmNewPin": ""
                    ])
                    expect(viewController.view).to(haveValidSnapshot())
                }
            }
            
            context("marked invalid, both with specific error messages") {
                it("has a valid snapshot") {
                    let dict = TestUtil.dictForFile(named: "change-pin-form-proper-padding")
                    let container = ComponentViewContainer.from(dict)
                    let viewController = ComponentViewController()
                    viewController.componentViewContainer = container
                    viewController.markInvalidInputs([
                        "newPin": "Please enter a valid 4-digit PIN",
                        "confirmNewPin": "Please confirm your new PIN"
                    ])
                    expect(viewController.view).to(haveValidSnapshot())
                }
            }
            
            context("marked invalid, both with long, specific error messages") {
                it("has a valid snapshot") {
                    let dict = TestUtil.dictForFile(named: "change-pin-form-proper-padding")
                    let container = ComponentViewContainer.from(dict)
                    let viewController = ComponentViewController()
                    viewController.componentViewContainer = container
                    viewController.markInvalidInputs([
                        "newPin": "Please enter a valid 4-digit PIN lorem ipsum dolor sit amet consectetuer esset",
                        "confirmNewPin": "Please confirm your new PIN lorem ipsum dolor sit amet consectetuer esset"
                    ])
                    expect(viewController.view).to(haveValidSnapshot())
                }
            }
        }
    }
}
