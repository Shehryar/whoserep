//
//  ComponentLayoutEngineSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 11/28/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ComponentLayoutEngineSpec: QuickSpec {
    override func spec() {
        describe("a vertical stackview layout") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
            }
            
            context("containing a horizontal stackview with two differently-sized buttons with gravity: fill") {
                it("has a valid snapshot") {
                    let dict = TestUtil.dictForFile(named: "gravity-fill-test")
                    let container = ComponentViewContainer.from(dict)
                    let viewController = ComponentViewController()
                    viewController.componentViewContainer = container
                    expect(viewController.view).to(haveValidSnapshot())
                }
            }
        }
    }
}