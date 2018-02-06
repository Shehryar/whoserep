//
//  RestartConfirmationActionSheetSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 2/5/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class RestartConfirmationActionSheetSpec: QuickSpec {
    override func spec() {
        describe("RestartConfirmationActionSheet") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
            }
            
            context("on its own") {
                beforeEach {
                    ASAPP.styles = ASAPPStyles()
                }
                
                context("with default styles") {
                    it("has a valid snapshot") {
                        let actionSheet = RestartConfirmationActionSheet()
                        actionSheet.frame = CGRect(x: 0, y: 0, width: 320, height: 600)
                        expect(actionSheet).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
