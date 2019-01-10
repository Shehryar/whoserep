//
//  ComponentNavigationControllerSpec.swift
//  Tests
//
//  Created by Shehryar Hussain on 12/31/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class ComponentNavigationControllerSpec: QuickSpec {
    override func spec() {
        describe("ComponentNavigationControllerSpec") {
            let blankViewController = UIViewController()
            let navigationController = TestableComponentNavigationController(rootViewController: blankViewController)
            
            context("Uses custom presentation") {
                beforeEach {
                    navigationController.displayStyle = .inset
                }
                
                it("uses custom presentation values") {
                    expect(navigationController.presentationAnimator).toNot(beNil())
                    expect(navigationController.isNavigationBarHidden).to(beTrue())
                    expect(navigationController.modalPresentationStyle).to(equal(.custom))
                }
            }
            
            context("Uses custom presentation") {
                beforeEach {
                    navigationController.displayStyle = .full
                }
                
                it("uses custom presentation values") {
                    expect(navigationController.presentationAnimator).toNot(beNil())
                    expect(navigationController.isNavigationBarHidden).to(beFalse())
                    expect(navigationController.modalPresentationStyle).to(equal(.fullScreen))
                }
            }
            
            context("Calls the correct functions") {
                beforeEach {
                    navigationController.willUpdateFrames()
                    navigationController.updateFrames()
                    navigationController.didUpdateFrames()
                }
                
                it("Should have called the drawing functions") {
                    expect(navigationController.willUpdateFramesCalled).to(beTrue())
                    expect(navigationController.updateFramesCalled).to(beTrue())
                    expect(navigationController.didUpdateFramesCalled).to(beTrue())
                }
            }
        }
    }
}

class TestableComponentNavigationController: ComponentNavigationController {
    
    var updateFramesCalled = false
    var didUpdateFramesCalled = false
    var willUpdateFramesCalled = false
    var didCallUpdateKeyboardHeight = false
    
    override func updateFrames() {
        super.updateFrames()
        updateFramesCalled = true
    }
    
    override func didUpdateFrames() {
        super.didUpdateFrames()
        didUpdateFramesCalled = true
    }
    
    override func willUpdateFrames() {
        super.willUpdateFrames()
        willUpdateFramesCalled = true
    }
}
