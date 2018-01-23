//
//  APIActionResponseSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 1/12/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class APIActionResponseSpec: QuickSpec {
    override func spec() {
        describe("APIActionResponse") {
            describe(".fromJSON(_:)") {
                context("with an argument that is not a stringly-keyed dictionary") {
                    it("returns nil") {
                        let response1 = APIActionResponse.fromJSON("foo")
                        expect(response1).to(beNil())
                        
                        let response2 = APIActionResponse.fromJSON(nil)
                        expect(response2).to(beNil())
                    }
                }
                
                context("with a dictionary lacking a valid type") {
                    it("returns nil") {
                        let response1 = APIActionResponse.fromJSON(["foo": true])
                        expect(response1).to(beNil())
                        
                        let response2 = APIActionResponse.fromJSON(["type": ""])
                        expect(response2).to(beNil())
                        
                        let response3 = APIActionResponse.fromJSON(["type": "foo"])
                        expect(response3).to(beNil())
                    }
                }
                
                context("with a dictionary describing a finish action") {
                    it("creates a correct APIActionResponse instance") {
                        let response1 = APIActionResponse.fromJSON([
                            "type": APIActionResponseType.finish.rawValue,
                            "content": ["type": "finish"]
                        ])
                        expect(response1?.type).to(equal(.finish))
                        expect(response1?.finishAction).to(beAKindOf(FinishAction.self))
                        expect(response1?.error).to(beNil())
                        expect(response1?.view).to(beNil())
                    }
                }
                
                context("with a dictionary describing an error") {
                    it("creates a correct APIActionResponse instance") {
                        let response1 = APIActionResponse.fromJSON([
                            "type": APIActionResponseType.error.rawValue,
                            "content": [:]
                        ])
                        expect(response1?.type).to(equal(.error))
                        expect(response1?.error).to(beAKindOf(APIActionError.self))
                        expect(response1?.finishAction).to(beNil())
                        expect(response1?.view).to(beNil())
                    }
                }
                
                context("with a dictionary describing a Component view") {
                    it("creates a correct APIActionResponse instance") {
                        let response1 = APIActionResponse.fromJSON([
                            "type": APIActionResponseType.componentView.rawValue,
                            "content": [
                                "root": [
                                    "type": "label",
                                    "content": [
                                        "text": "foo"
                                    ]
                                ]
                            ]
                        ])
                        expect(response1?.type).to(equal(.componentView))
                        expect(response1?.error).to(beNil())
                        expect(response1?.finishAction).to(beNil())
                        expect(response1?.view).to(beAKindOf(ComponentViewContainer.self))
                    }
                }
                
                context("with a dictionary describing a refresh view") {
                    it("creates a correct APIActionResponse instance") {
                        let response1 = APIActionResponse.fromJSON([
                            "type": APIActionResponseType.refreshView.rawValue,
                            "content": [
                                "root": [
                                    "type": "label",
                                    "content": [
                                        "text": "foo"
                                    ]
                                ]
                            ]
                        ])
                        expect(response1?.type).to(equal(.refreshView))
                        expect(response1?.error).to(beNil())
                        expect(response1?.finishAction).to(beNil())
                        expect(response1?.view).to(beAKindOf(ComponentViewContainer.self))
                    }
                }
            }
        }
    }
}
