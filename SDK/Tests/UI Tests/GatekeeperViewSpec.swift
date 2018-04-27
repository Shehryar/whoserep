//
//  GatekeeperViewSpec.swift
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

class GatekeeperViewSpec: QuickSpec {
    override func spec() {
        describe("GatekeeperView") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
                TestUtil.createStyle()
            }
            
            context("on its own") {
                context("with contentType unauthenticated") {
                    it("has a valid snapshot") {
                        let view = GatekeeperView(contentType: .unauthenticated)
                        view.frame = CGRect(x: 0, y: 0, width: 320, height: 500)
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("with contentType notConnected") {
                    it("has a valid snapshot") {
                        let view = GatekeeperView(contentType: .notConnected)
                        view.frame = CGRect(x: 0, y: 0, width: 320, height: 500)
                        expect(view).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
