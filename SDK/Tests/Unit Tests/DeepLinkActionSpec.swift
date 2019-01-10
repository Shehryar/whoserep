//
//  DeepLinkActionSpec.swift
//  Tests
//
//  Created by Shehryar Hussain on 12/31/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class DeeplinkActionSpec: QuickSpec {
    override func spec() {
        describe("DeepLinkActionSpec") {
            
            context("Valid Deeplink") {
                let deeplinkDict = ["name": "asapp://"]
                var deeplink: DeepLinkAction?
                beforeEach {
                    deeplink = DeepLinkAction(content: deeplinkDict, performImmediately: true)
                }
                
                it("Should be a valid deeplink action") {
                    expect(deeplink).toNot(beNil())
                    expect(deeplink?.name).to(equal("asapp://"))
                }
            }
            
            context("Invalid Deeplink") {
                let deeplinkDict = ["badName": "asapp://"]
                var deeplink: DeepLinkAction?
                beforeEach {
                    deeplink = DeepLinkAction(content: deeplinkDict, performImmediately: true)
                }
                
                it("Should be an invalid deeplink action") {
                    expect(deeplink).to(beNil())
                    expect(deeplink?.name).to(beNil())
                }
            }
        }
    }
}
