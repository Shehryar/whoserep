//
//  ASAPPSpec.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class ASAPPSpec: QuickSpec {
    override func spec() {
        describe("ASAPP") {
            describe(".canHandleNotification(with:)") {
                var userInfo: [AnyHashable: Any]!
                
                context("when the FromASAPP key's value is true") {
                    it("returns true") {
                        userInfo = ["FromASAPP": true]
                        expect(ASAPP.canHandleNotification(with: userInfo)).to(beTrue())
                    }
                }
                
                context("when the FromASAPP key's value is false") {
                    it("returns true") {
                        userInfo = ["FromASAPP": false]
                        expect(ASAPP.canHandleNotification(with: userInfo)).to(beTrue())
                    }
                }
                
                context("when the FromASAPP key's value is a dictionary") {
                    it("returns true") {
                        userInfo = ["FromASAPP": ["data": "someData"]]
                        expect(ASAPP.canHandleNotification(with: userInfo)).to(beTrue())
                    }
                }
                
                context("when there is an aps key but no FromASAPP key") {
                    it("returns false") {
                        userInfo = ["aps": []]
                        expect(ASAPP.canHandleNotification(with: userInfo)).to(beFalse())
                    }
                }
                
                context("when there is a FromASAPP key but no aps key") {
                    it("returns true") {
                        userInfo = ["FromASAPP": ["data": "someData"]]
                        expect(ASAPP.canHandleNotification(with: userInfo)).to(beTrue())
                    }
                }
                
                context("when there is no FromASAPP key") {
                    it("returns false") {
                        userInfo = ["data": "someData"]
                        expect(ASAPP.canHandleNotification(with: userInfo)).to(beFalse())
                    }
                }
                
                context("when userInfo is nil") {
                    it("returns false") {
                        expect(ASAPP.canHandleNotification(with: nil)).to(beFalse())
                    }
                }
            }
        }
    }
}
