//
//  SessionManagerSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 10/20/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class SessionManagerSpec: QuickSpec {
    override func spec() {
        describe("SessionManager") {
            describe(".init(config:user:)") {
                context("with a config and a user") {
                    it("creates a SessionManager") {
                        let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "testing")
                        let milliseconds = Int((Date.timeIntervalSinceReferenceDate * 1000).rounded())
                        let user = ASAPPUser(userIdentifier: "test-user-\(milliseconds)", requestContextProvider: {
                            return [:]
                        }, userLoginHandler: { _ in })
                        let manager = SessionManager(config: config, user: user)
                        expect(manager.config).to(equal(config))
                        expect(manager.user).to(equal(user))
                        expect(manager.deviceIdentifier).toNot(beEmpty())
                        expect(manager.previousEventSequence()).to(equal(0))
                    }
                }
            }
            
            describe(".previousEventSequence()") {
                var manager: SessionManager!
                beforeEach {
                    let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "testing")
                    let milliseconds = Int((Date.timeIntervalSinceReferenceDate * 1000).rounded())
                    let user = ASAPPUser(userIdentifier: "test-user-\(milliseconds)", requestContextProvider: {
                        return [:]
                    }, userLoginHandler: { _ in })
                    manager = SessionManager(config: config, user: user)
                }
                
                context("without the sequence having been incremented") {
                    it("returns 0") {
                        expect(manager.previousEventSequence()).to(equal(0))
                    }
                }
                
                context("with the sequence having been incremented twice") {
                    it("returns 2") {
                        _ = manager.getNextEventSequence()
                        _ = manager.previousEventSequence()
                        _ = manager.getNextEventSequence()
                        expect(manager.previousEventSequence()).to(equal(2))
                    }
                }
            }
            
            describe(".getNextEventSequence()") {
                var manager: SessionManager!
                beforeEach {
                    let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "testing")
                    let milliseconds = Int((Date.timeIntervalSinceReferenceDate * 1000).rounded())
                    let user = ASAPPUser(userIdentifier: "test-user-\(milliseconds)", requestContextProvider: {
                        return [:]
                    }, userLoginHandler: { _ in })
                    manager = SessionManager(config: config, user: user)
                }
                
                context("being called multiple times") {
                    it("returns the incremented number") {
                        expect(manager.getNextEventSequence()).to(equal(1))
                        _ = manager.previousEventSequence()
                        expect(manager.getNextEventSequence()).to(equal(2))
                        _ = manager.previousEventSequence()
                        expect(manager.getNextEventSequence()).to(equal(3))
                        _ = manager.previousEventSequence()
                        
                        for _ in 0..<100 {
                            _ = manager.getNextEventSequence()
                        }
                        
                        expect(manager.getNextEventSequence()).to(equal(104))
                    }
                }
            }
        }
    }
}
