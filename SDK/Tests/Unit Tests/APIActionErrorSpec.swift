//
//  APIActionErrorSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 1/16/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class APIActionErrorSpec: QuickSpec {
    override func spec() {
        describe("APIActionError") {
            describe(".init(_:)") {
                context("with an argument that is not a stringly-keyed dictionary") {
                    it("returns nil") {
                        let error = APIActionError(nil)
                        expect(error).to(beNil())
                    }
                }
                
                context("with a dictionary describing all properties") {
                    it("creates a correct APIActionError instance") {
                        let error = APIActionError([
                            APIActionError.JSONKey.code.rawValue: 42,
                            APIActionError.JSONKey.userMessage.rawValue: "foo",
                            APIActionError.JSONKey.debugMessage.rawValue: "bar",
                            APIActionError.JSONKey.invalidInputs.rawValue: ["baz": "9001"]
                        ])
                        expect(error?.code).to(equal(42))
                        expect(error?.userMessage).to(equal("foo"))
                        expect(error?.debugMessage).to(equal("bar"))
                        expect(error?.invalidInputs).to(equal(["baz": "9001"]))
                    }
                }
            }
        }
    }
}
