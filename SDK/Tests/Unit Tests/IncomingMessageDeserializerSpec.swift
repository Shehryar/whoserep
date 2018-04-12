//
//  IncomingMessageDeserializerSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 11/6/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import Foundation

import Quick
import Nimble
@testable import ASAPP

class IncomingMessageDeserializerSpec: QuickSpec {
    override func spec() {
        describe("IncomingMessageDeserializer") {
            describe(".deserialize(_:)") {
                context("with a string argument of an unknown format") {
                    it("creates an IncomingMessage with a nil type") {
                        let message = "Strange Format"
                        let result = IncomingMessageDeserializer().deserialize(message)
                        expect(result.debugError).to(beNil())
                        expect(result.type).to(beNil())
                        expect(result.requestId).to(beNil())
                        expect(result.bodyString).to(beNil())
                        expect(result.body).to(beNil())
                        expect(result.fullMessage as? String).to(equal(message))
                    }
                }
                
                context("with a string representing a response") {
                    it("creates an IncomingMessage with type response") {
                        let id = 9000
                        let body = "{\"foo\": \"bar\"}"
                        let message = "Response|\(id)|\(body)"
                        let result = IncomingMessageDeserializer().deserialize(message)
                        expect(result.debugError).to(beNil())
                        expect(result.type).to(equal(.response))
                        expect(result.requestId).to(equal(id))
                        expect(result.bodyString).to(equal(body))
                        expect(result.body!["foo"] as? String).to(equal("bar"))
                        expect(result.fullMessage as? String).to(equal(message))
                    }
                }
                
                context("with a string representing a response containing |s") {
                    it("creates an IncomingMessage with type response") {
                        let id = 9000
                        let body = "{\"fo|o\": \"b|ar\"}"
                        let message = "Response|\(id)|\(body)"
                        let result = IncomingMessageDeserializer().deserialize(message)
                        expect(result.debugError).to(beNil())
                        expect(result.type).to(equal(.response))
                        expect(result.requestId).to(equal(id))
                        expect(result.bodyString).to(equal(body))
                        expect(result.body!["fo|o"] as? String).to(equal("b|ar"))
                        expect(result.fullMessage as? String).to(equal(message))
                    }
                }
                
                context("with a string representing an event") {
                    it("creates an IncomingMessage with type event") {
                        let body = "{\"foo\": \"bar\"}"
                        let message = "Event|\(body)"
                        let result = IncomingMessageDeserializer().deserialize(message)
                        expect(result.debugError).to(beNil())
                        expect(result.type).to(equal(.event))
                        expect(result.requestId).to(beNil())
                        expect(result.bodyString).to(equal(body))
                        expect(result.body!["foo"] as? String).to(equal("bar"))
                        expect(result.fullMessage as? String).to(equal(message))
                    }
                }
                
                context("with a string representing a response error") {
                    it("creates an IncomingMessage with type responseError") {
                        let id = 9001
                        let body = "{\"foo\": \"bar\"}"
                        let message = "ResponseError|\(id)|\(body)"
                        let result = IncomingMessageDeserializer().deserialize(message)
                        expect(result.debugError).to(equal(body))
                        expect(result.type).to(equal(.responseError))
                        expect(result.requestId).to(equal(id))
                        expect(result.bodyString).to(equal(body))
                        expect(result.body!["foo"] as? String).to(equal("bar"))
                        expect(result.fullMessage as? String).to(equal(message))
                    }
                }
            }
            
            describe(".parseEvents()") {
                context("with a responseError message") {
                    it("creates a ParsedEvents object with an error message") {
                        let message = "ResponseError|0|foo"
                        let incomingMessage = IncomingMessageDeserializer().deserialize(message)
                        let result = incomingMessage.parseEvents()
                        expect(result.errorMessage).to(equal("foo"))
                        expect(result.events).to(beNil())
                        expect(result.eventsJSONArray).to(beNil())
                    }
                }
                
                context("with a response message with no events") {
                    it("creates a ParsedEvents object with an error message") {
                        let message = "Response|1|foo"
                        let incomingMessage = IncomingMessageDeserializer().deserialize(message)
                        let result = incomingMessage.parseEvents()
                        expect(result.errorMessage).to(contain("No results"))
                        expect(result.events).to(beNil())
                        expect(result.eventsJSONArray).to(beNil())
                    }
                }
                
                context("with a response message with 2 valid events out of 5") {
                    it("creates a ParsedEvents object with 2 events") {
                        let message = TestUtil.stringForFile(named: "event-list")
                        let incomingMessage = IncomingMessageDeserializer().deserialize(message!)
                        let result = incomingMessage.parseEvents()
                        expect(result.errorMessage).to(beNil())
                        expect(result.events?.count).to(equal(2))
                        expect(result.eventsJSONArray?.count).to(equal(2))
                    }
                }
            }
        }
    }
}
