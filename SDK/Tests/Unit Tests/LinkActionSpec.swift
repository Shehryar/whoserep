//
//  LinkActionSpec.swift
//  Tests
//
//  Created by Shehryar Hussain on 1/2/19.
//  Copyright © 2019 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class LinkActionSpec: QuickSpec {
    override func spec() {
        describe("LinkActionSpec") {
            
            context("Valid LinkAction") {
                var linkAction: LinkAction?
                beforeEach {
                    let linkDict = ["link": "http://linklink.link"]
                    linkAction = LinkAction(content: linkDict)
                }
                
                it("Should be a valid linkAction") {
                    expect(linkAction).toNot(beNil())
                    expect(linkAction?.link).toNot(beNil())
                }
            }
            
            context("Invalid LinkAction") {
                var linkAction: LinkAction?
                beforeEach {
                    linkAction = LinkAction(content: nil)
                }
                
                it("Should be a valid linkAction") {
                    expect(linkAction).to(beNil())
                }
            }
        }
    }
}
