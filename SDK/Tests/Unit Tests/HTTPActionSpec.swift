//
//  HTTPActionSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 1/12/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class HTTPActionSpec: QuickSpec {
    override func spec() {
        describe("HTTPAction") {
            describe(".init(content:)") {
                context("with an argument that is not a stringly-keyed dictionary") {
                    it("returns nil") {
                        let action1 = HTTPAction(content: "foo")
                        expect(action1).to(beNil())
                        
                        let action2 = HTTPAction(content: nil)
                        expect(action2).to(beNil())
                    }
                }
                
                context("with a dictionary lacking a valid url") {
                    it("returns nil") {
                        let action1 = HTTPAction(content: [HTTPAction.JSONKey.method.rawValue: HTTPMethod.GET.rawValue])
                        expect(action1).to(beNil())
                        
                        let action2 = HTTPAction(content: [
                            HTTPAction.JSONKey.method.rawValue: HTTPMethod.GET.rawValue,
                            HTTPAction.JSONKey.url.rawValue: ""
                        ])
                        expect(action2).to(beNil())
                    }
                }
                
                context("with a dictionary lacking a valid method") {
                    it("returns nil") {
                        let action1 = HTTPAction(content: [HTTPAction.JSONKey.url.rawValue: "http://example.com/"])
                        expect(action1).to(beNil())
                        
                        let action2 = HTTPAction(content: [
                            HTTPAction.JSONKey.method.rawValue: "",
                            HTTPAction.JSONKey.url.rawValue: "http://example.com/"
                        ])
                        expect(action2).to(beNil())
                    }
                }
                
                context("with a dictionary with a valid url and method") {
                    it("creates a correct HTTPAction instance") {
                        let urlString = "http://example.com/"
                        let action = HTTPAction(content: [
                            HTTPAction.JSONKey.method.rawValue: HTTPMethod.GET.rawValue,
                            HTTPAction.JSONKey.url.rawValue: urlString
                        ])
                        expect(action).toNot(beNil())
                        expect(action?.method).to(equal(.GET))
                        expect(action?.url).to(equal(URL(string: urlString)))
                        expect(action?.onResponseAction).to(beNil())
                    }
                }
                
                context("with a dictionary with a valid url and method and an action") {
                    it("creates a correct HTTPAction instance") {
                        let urlString = "http://example.com/"
                        let action = HTTPAction(content: [
                            HTTPAction.JSONKey.method.rawValue: HTTPMethod.GET.rawValue,
                            HTTPAction.JSONKey.url.rawValue: urlString,
                            HTTPAction.JSONKey.onResponseAction.rawValue: [
                                "type": "finish"
                            ]
                        ])
                        expect(action).toNot(beNil())
                        expect(action?.method).to(equal(.GET))
                        expect(action?.url).to(equal(URL(string: urlString)))
                        expect(action?.onResponseAction).to(beAKindOf(FinishAction.self))
                    }
                }
            }
        }
    }
}
