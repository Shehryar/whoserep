//
//  AppOpenResponseSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 10/20/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class AppOpenResponseSpec: QuickSpec {
    override func spec() {
        describe("AppOpenResponse") {
            describe(".fromJSON(_:)") {
                context("without valid JSON") {
                    it("returns nil") {
                        let response = AppOpenResponse.fromJSON([nil])
                        expect(response).to(beNil())
                    }
                }
                
                context("with valid JSON") {
                    let greeting = "Hello"
                    let inputPlaceholder = "Type here..."
                    let message = "Here are your options"
                    let predictionActions = [
                        "Option 1",
                        "Option 2",
                        "Option 3"
                    ]
                    let predictionActions2 = [
                        "Option 4"
                    ]
                    let actions = [
                        "Generic Action 1",
                        "Generic Action 2"
                    ]
                    
                    context("describing prediction actions and a message") {
                        it("returns an AppOpenResponse with a customizedMessage and customizedActions") {
                            let dict: [String: Any] = [
                                "greeting": greeting,
                                "input_placeholder": inputPlaceholder,
                                "predictions": [
                                    [
                                        "prediction_display_text": message,
                                        "prediction_actions": predictionActions
                                    ]
                                ],
                                "actions": actions
                            ]
                            let response = AppOpenResponse.fromJSON(dict)
                            expect(response).toNot(beNil())
                            expect(response!.greeting).to(equal(greeting))
                            expect(response!.inputPlaceholder).to(equal(inputPlaceholder))
                            expect(response!.customizedMessage).to(equal(message))
                            expect(response!.customizedActions).to(equal(predictionActions))
                            expect(response!.genericActions).to(equal(actions))
                        }
                    }
                    
                    context("describing prediction actions without a message") {
                        it("returns an AppOpenResponse with genericActions starting with the prediction actions") {
                            let dict: [String: Any] = [
                                "greeting": greeting,
                                "input_placeholder": inputPlaceholder,
                                "predictions": [
                                    [:],
                                    [
                                        "prediction_actions": predictionActions2
                                    ]
                                ],
                                "actions": actions
                            ]
                            let response = AppOpenResponse.fromJSON(dict)
                            expect(response).toNot(beNil())
                            expect(response!.greeting).to(equal(greeting))
                            expect(response!.inputPlaceholder).to(equal(inputPlaceholder))
                            expect(response!.customizedMessage).to(beNil())
                            expect(response!.customizedActions).to(beNil())
                            expect(response!.genericActions).to(equal(predictionActions2 + actions))
                        }
                    }
                    
                    context("describing every kind of prediction action") {
                        it("returns an AppOpenResponse with customizedActions and genericActions starting with the message-less prediction actions") {
                            let dict: [String: Any] = [
                                "greeting": greeting,
                                "input_placeholder": inputPlaceholder,
                                "predictions": [
                                    [
                                        "prediction_display_text": message,
                                        "prediction_actions": predictionActions
                                    ],
                                    [
                                        "prediction_actions": predictionActions2
                                    ]
                                ],
                                "actions": actions
                            ]
                            let response = AppOpenResponse.fromJSON(dict)
                            expect(response).toNot(beNil())
                            expect(response!.greeting).to(equal(greeting))
                            expect(response!.inputPlaceholder).to(equal(inputPlaceholder))
                            expect(response!.customizedMessage).to(equal(message))
                            expect(response!.customizedActions).to(equal(predictionActions))
                            expect(response!.genericActions).to(equal(predictionActions2 + actions))
                        }
                    }
                }
            }
        }
    }
}
