//
//  ChatSimpleStoreSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 4/12/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class ChatSimpleStoreSpec: QuickSpec {
    override func spec() {
        describe("ChatSimpleStore") {
            beforeSuite {
                TestUtil.setUpASAPP()
            }
            
            context(".getSRSOriginalSearchQuery()") {
                context("with nothing stored") {
                    it("returns nil") {
                        let mockUserDefaults = MockUserDefaults()
                        let store = ChatSimpleStore(config: ASAPP.config, user: ASAPP.user, userDefaults: mockUserDefaults)
                        let result = store.getSRSOriginalSearchQuery()
                        
                        expect(result).to(beNil())
                        expect(mockUserDefaults.calledObject).to(equal(true))
                        expect(mockUserDefaults.calledSet).to(equal(false))
                        expect(mockUserDefaults.calledRemoveObject).to(equal(false))
                    }
                }
                
                context("with a String having been stored") {
                    it("returns the String that was stored") {
                        let mockUserDefaults = MockUserDefaults()
                        let store = ChatSimpleStore(config: ASAPP.config, user: ASAPP.user, userDefaults: mockUserDefaults)
                        let foo = "deadbeef"
                        mockUserDefaults.nextObject = foo
                        let result = store.getSRSOriginalSearchQuery()
                        
                        expect(result).to(equal(foo))
                        expect(mockUserDefaults.calledObject).to(equal(true))
                        expect(mockUserDefaults.calledSet).to(equal(false))
                        expect(mockUserDefaults.calledRemoveObject).to(equal(false))
                    }
                }
            }
            
            context(".updateSRSOriginalSearchQuery(query:)") {
                context("with a String to be stored") {
                    it("stores the String") {
                        let mockUserDefaults = MockUserDefaults()
                        let store = ChatSimpleStore(config: ASAPP.config, user: ASAPP.user, userDefaults: mockUserDefaults)
                        let foo = "deadbeef"
                        store.updateSRSOriginalSearchQuery(query: foo)
                        
                        expect(mockUserDefaults.calledObject).to(equal(false))
                        expect(mockUserDefaults.calledSet).to(equal(true))
                        expect(mockUserDefaults.calledRemoveObject).to(equal(false))
                        
                        let result = store.getSRSOriginalSearchQuery()
                        expect(result).to(equal(foo))
                    }
                }
                
                context("with nil") {
                    it("removes a previous object") {
                        let mockUserDefaults = MockUserDefaults()
                        let store = ChatSimpleStore(config: ASAPP.config, user: ASAPP.user, userDefaults: mockUserDefaults)
                        let foo = "deadbeef"
                        store.updateSRSOriginalSearchQuery(query: foo)
                        
                        let result = store.getSRSOriginalSearchQuery()
                        expect(result).to(equal(foo))
                        
                        mockUserDefaults.cleanCalls()
                        store.updateSRSOriginalSearchQuery(query: nil)
                        
                        expect(mockUserDefaults.calledObject).to(equal(false))
                        expect(mockUserDefaults.calledSet).to(equal(false))
                        expect(mockUserDefaults.calledRemoveObject).to(equal(true))
                        
                        let result2 = store.getSRSOriginalSearchQuery()
                        expect(result2).to(beNil())
                    }
                }
            }
        }
    }
}
