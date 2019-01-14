//
//  UserLoginActionSpec.swift
//  Tests
//
//  Created by Shehryar Hussain on 12/31/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import ASAPP

class UserLoginActionSpec: QuickSpec {
    override func spec() {
        describe("UserLoginActionSpec") {

            context("Valid UserLoginAction") {
                var userLoginAction: UserLoginAction?
                var secondLoginAction: UserLoginAction?
                beforeEach {
                    let dict = [
                        "authenticated_time": 327511937000000,
                        "customer_primary_identifier": "foo",
                        "customer_id": 9000,
                        "customer_guid": "deadbeef",
                        "company_id": 42,
                        "session_token": "deadbeef",
                        "session_id": "dead-beef"
                        ] as [String: Any]
                    
                    guard let session = TestUtil.createSession(from: dict) else {
                        return fail()
                    }
                    let actionDict = [
                        "data": ["fake-data": "more-fake-data"],
                        "metadata": ["fake-data": "fake-fake"]
                    ]
                    let nextAction = Action(content: actionDict)
                    userLoginAction = UserLoginAction(session: session, nextAction: nextAction)
                    secondLoginAction = UserLoginAction(content: actionDict, performImmediately: false)
                }
                
                it("Should be a valid user login action") {
                    expect(userLoginAction).toNot(beNil())
                    expect(secondLoginAction).toNot(beNil())
                    
                }
            }
            
            context("Invalid UserLoginAction") {
                var userLoginAction: UserLoginAction?
                beforeEach {
                    userLoginAction = UserLoginAction(content: nil, performImmediately: false)
                }
                
                it("Should be a vlid deeplink action") {
                    expect(userLoginAction).to(beNil())
                }
            }
        }
    }
}
