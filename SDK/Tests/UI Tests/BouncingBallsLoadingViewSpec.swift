//
//  BouncingBallsLoadingViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 12/25/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class BouncingBallsLoadingViewSpec: QuickSpec {
    override func spec() {
        describe("BouncingBallsLoadingView") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
                TestUtil.createStyle()
            }
            
            context("default styles") {
                it("has a valid snapshot") {
                    let view = BouncingBallsLoadingView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                    view.sizeToFit()
                    expect(view).to(haveValidSnapshot())
                }
            }
            
            context("red tint color") {
                it("has a valid snapshot") {
                    let view = BouncingBallsLoadingView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                    view.tintColor = .red
                    view.sizeToFit()
                    expect(view).to(haveValidSnapshot())
                }
            }
            
            context("zero contentInset") {
                it("has a valid snapshot") {
                    let view = BouncingBallsLoadingView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                    view.contentInset = .zero
                    view.sizeToFit()
                    expect(view).to(haveValidSnapshot())
                }
            }
            
            context("having begun animating") {
                it("has a valid snapshot") {
                    let view = BouncingBallsLoadingView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                    view.sizeToFit()
                    view.beginAnimating()
                    expect(view).to(haveValidSnapshot())
                    expect(view.animating).to(beTrue())
                }
            }
            
            context("having ended animating") {
                it("has a valid snapshot") {
                    let view = BouncingBallsLoadingView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                    view.sizeToFit()
                    view.beginAnimating()
                    view.endAnimating()
                    expect(view).to(haveValidSnapshot())
                    expect(view.animating).to(beFalse())
                }
            }
        }
    }
}
