//
//  PartnerEventSpec.swift
//  Tests
//
//  Created by Shehryar Hussain on 1/2/19.
//  Copyright © 2019 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class PartnerEventSpec: QuickSpec {
    override func spec() {
        describe("PartnerEventSpec") {
            
            context("Valid Partner Event") {
                var partnerEvent: PartnerEvent?
                beforeEach {
                    let eventDict: [String: Any] = [
                        "type": "name",
                        "data": ["test": "test"]
                    ]
                    partnerEvent = PartnerEvent.fromDict(eventDict)
                }
                
                it("Should be a valid PartnerEvent") {
                    expect(partnerEvent).toNot(beNil())
                }
            }
            
            context("Invalid Partner Event") {
                var partnerEvent: PartnerEvent?
                beforeEach {
                    let eventDict: [String: Any] = [
                        "type": 11,
                        "data": ["test": "test"]
                    ]
                    partnerEvent = PartnerEvent.fromDict(eventDict)
                }
                
                it("Should be an invalid PartnerEvent") {
                    expect(partnerEvent).to(beNil())
                }
            }
        }
    }
}
