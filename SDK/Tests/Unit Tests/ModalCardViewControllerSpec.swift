//
//  ModalCardViewControllerSpec.swift
//  Tests
//
//  Created by Shehryar Hussain on 12/28/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class ModalCardViewControllerSpec: QuickSpec {
    override func spec() {
        // basically just check some states
        describe("ModalCardViewController") {
        
            let viewController = ModalCardViewController()
            let blankView = UIView()
            
            context("Content view is blank") {
                beforeEach {
                    
                    viewController.contentView = blankView
                    viewController.viewDidLoad()
                    viewController.updateFrames()
                    let _ = viewController.view
                }
                
                it("Should have a content view") {
                    expect(viewController.contentView).toNot(beNil())
                    expect(viewController.errorView).toNot(beNil())
                    expect(viewController.contentScrollView).toNot(beNil())
                    expect(viewController.controlsView).toNot(beNil())
                }
                
                it("Should show success view") {
                    viewController.showSuccessView()
                    expect(viewController.isShowingSuccessView).to(beTrue())
                }
                
                it("Should hide success view") {
                    viewController.hideSuccessView()
                    expect(viewController.isShowingSuccessView).to(beFalse())
                }
            }
        }
    }
}
