//
//  ASAPPButtonSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/19/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ASAPPButtonSpec: QuickSpec {
    override func spec() {
        describe("ASAPPButton") {
            var viewController: UIViewController!
            
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                viewController = window.rootViewController
                
                TestUtil.setUpASAPP()
            }
            
            context("on its own") {
                beforeEach {
                    ASAPP.styles = ASAPPStyles()
                }
                
                context("with default styles") {
                    it("has a valid snapshot") {
                        let button = ASAPP.createChatButton(presentingViewController: viewController)
                        expect(button).to(haveValidSnapshot())
                        expect(button).to(haveValidDynamicTypeSnapshot())
                    }
                }
                
                context("with a custom text color") {
                    it("has a valid snapshot") {
                        ASAPP.styles.colors.helpButtonText = .black
                        let button = ASAPP.createChatButton(presentingViewController: viewController)
                        expect(button).to(haveValidSnapshot())
                    }
                }
                
                context("with a custom background color") {
                    it("has a valid snapshot") {
                        ASAPP.styles.colors.helpButtonBackground = .blue
                        let button = ASAPP.createChatButton(presentingViewController: viewController)
                        expect(button).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
