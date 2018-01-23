//
//  SocketRequestSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 1/17/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class SocketRequestSpec: QuickSpec {
    override func spec() {
        describe("SocketRequest") {
            describe(".init(...)") {
                context("with all arguments") {
                    it("creates a correct SocketRequest instance") {
                        let data = "gamma".data(using: .utf8)
                        let request = SocketRequest(requestId: 1, path: "foo", params: ["bar": "baz"], context: ["alpha": "beta"], requestData: data)
                        expect(request.requestId).to(equal(1))
                        expect(request.requestUUID).toNot(beEmpty())
                        expect(request.path).to(equal("foo"))
                        expect(request.params?["RequestId"] as? String).to(equal(request.requestUUID))
                        expect(request.params?["bar"] as? String).to(equal("baz"))
                        expect(request.context as? [String: String]).to(equal(["alpha": "beta"]))
                        expect(request.requestData).to(equal(data))
                    }
                }
            }
            
            describe(".containsSensitiveData") {
                context("with a path not containing CreditCard") {
                    it("returns false") {
                        let request = SocketRequest(requestId: 0, path: "foo", params: nil, context: nil, requestData: nil)
                        expect(request.containsSensitiveData).to(equal(false))
                    }
                }
                
                context("with a path containing CreditCard") {
                    it("returns false") {
                        let request = SocketRequest(requestId: 0, path: "/prefix/CreditCard/suffix", params: nil, context: nil, requestData: nil)
                        expect(request.containsSensitiveData).to(equal(true))
                    }
                }
            }
            
            describe(".getParametersCleanedOfSensitiveData()") {
                context("with params that include Number and CVV") {
                    it("replaces the values with placeholders") {
                        let request = SocketRequest(requestId: 0, path: "/prefix/CreditCard/suffix", params: ["Number": "foo", "CVV": "bar"], context: nil, requestData: nil)
                        let result = request.getParametersCleanedOfSensitiveData()
                        expect(result["Number"] as? String).to(equal("xxxx"))
                        expect(result["CVV"] as? String).to(equal("xxx"))
                    }
                }
            }
            
            describe(".getLoggableDescription()") {
                context("with no params or context") {
                    it("returns a correct string") {
                        let request = SocketRequest(requestId: 0, path: "foo", params: nil, context: nil, requestData: nil)
                        let result = request.getLoggableDescription()
                        expect(result).to(contain("foo|0|{\n\n}|{", "RequestId"))
                    }
                }
                
                context("with params and context") {
                    it("returns a correct string") {
                        let request = SocketRequest(requestId: 0, path: "CreditCard", params: ["Number": "foo", "CVV": "bar"], context: ["alpha": "beta"], requestData: nil)
                        let result = request.getLoggableDescription()
                        expect(result).to(contain("CreditCard|0|{\n  \"alpha\" : \"beta\"\n}|{", "RequestId", "\"Number\" : \"xxxx\"", "\"CVV\" : \"xxx\""))
                    }
                }
            }
        }
    }
}
