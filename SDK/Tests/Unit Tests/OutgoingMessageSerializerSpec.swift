//
//  OutgoingMessageSerializerSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 10/30/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class OutgoingMessageSerializerSpec: QuickSpec {
    override func spec() {
        func createSession(from dict: [String: Any]) -> Session? {
            let decoder = JSONDecoder()
            
            guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
                let string = String(data: data, encoding: .utf8) else {
                    return nil
            }
            
            decoder.userInfo[Session.rawBodyKey] = string
            
            guard let stringData = string.data(using: .utf8),
                let session = try? decoder.decode(Session.self, from: stringData) else {
                    return nil
            }
            
            return session
        }
        
        describe("OutgoingMessageSerializer") {
            describe(".createAuthRequest()") {
                context("with a config with the default region code") {
                    var config: ASAPPConfig!
                    
                    beforeEach {
                        config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "test")
                        ASAPP.initialize(with: config)
                        ASAPP.user = ASAPPUser(userIdentifier: "test", requestContextProvider: { _ in
                            return [:]
                        })
                    }
                    
                    it("creates an auth request with the default region code") {
                        let serializer = OutgoingMessageSerializer(config: config, user: ASAPP.user)
                        
                        waitUntil { done in
                            serializer.createAuthRequest(contextNeedsRefresh: false) { authRequest in
                                expect(authRequest.params["RegionCode"] as? String).to(equal("US"))
                                done()
                            }
                        }
                    }
                }
                
                context("with a config with a custom region code") {
                    var config: ASAPPConfig!
                    
                    beforeEach {
                        config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "test", regionCode: "AUS")
                        ASAPP.initialize(with: config)
                        ASAPP.user = ASAPPUser(userIdentifier: "test", requestContextProvider: { _ in
                            return [:]
                        })
                    }
                    
                    it("creates an auth request with the custom region code") {
                        let serializer = OutgoingMessageSerializer(config: config, user: ASAPP.user)
                        
                        waitUntil { done in
                            serializer.createAuthRequest(contextNeedsRefresh: false) { authRequest in
                                expect(authRequest.params["RegionCode"] as? String).to(equal("AUS"))
                                done()
                            }
                        }
                    }
                }
                
                context("without session info and with an anonymous user") {
                    var config: ASAPPConfig!
                    
                    beforeEach {
                        config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "test")
                        ASAPP.initialize(with: config)
                        ASAPP.user = ASAPPUser(userIdentifier: nil, requestContextProvider: { _ in
                            return [:]
                        })
                    }
                    
                    it("creates an auth request for an anonymous user") {
                        let serializer = OutgoingMessageSerializer(config: config, user: ASAPP.user)
                        
                        waitUntil { done in
                            serializer.createAuthRequest(contextNeedsRefresh: false) { authRequest in
                                expect(authRequest.path).to(equal("auth/CreateAnonCustomerAccount"))
                                expect(authRequest.isSessionAuthRequest).to(beFalse())
                                done()
                            }
                        }
                    }
                }
                
                context("without session info and with a non-anonymous user") {
                    var config: ASAPPConfig!
                    
                    beforeEach {
                        config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "test")
                        ASAPP.initialize(with: config)
                        ASAPP.user = ASAPPUser(userIdentifier: "test", requestContextProvider: { _ in
                            return [:]
                        })
                    }
                    
                    it("creates an auth request with a customer identifier") {
                        let serializer = OutgoingMessageSerializer(config: config, user: ASAPP.user)
                        
                        waitUntil { done in
                            serializer.createAuthRequest(contextNeedsRefresh: false) { authRequest in
                                expect(authRequest.path).to(equal("auth/AuthenticateWithCustomerIdentifier"))
                                expect(authRequest.isSessionAuthRequest).to(beFalse())
                                done()
                            }
                        }
                    }
                }
                
                context("with session info and with an anonymous user") {
                    var serializer: OutgoingMessageSerializer!
                    
                    beforeEach {
                        let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "test")
                        ASAPP.initialize(with: config)
                        ASAPP.user = ASAPPUser(userIdentifier: nil, requestContextProvider: { _ in
                            return [:]
                        })
                        
                        serializer = OutgoingMessageSerializer(config: config, user: ASAPP.user)
                        
                        let dict = [
                            "SessionInfo": [
                                "Customer": [
                                    "CustomerId": 9000,
                                    "CustomerGUID": "deadbeef"
                                ],
                                "Company": [
                                    "CompanyId": 42
                                ],
                                "SessionAuth": [
                                    "SessionTime": 1234567890,
                                    "SessionSecret": "secretsecret"
                                ],
                                "SessionId": "dead-beef"
                            ]
                        ]
                        
                        guard let session = createSession(from: dict) else {
                            return fail()
                        }
                        
                        serializer.session = session
                    }
                    
                    it("creates an auth request with an existing session") {
                        waitUntil { done in
                            serializer.createAuthRequest(contextNeedsRefresh: false) { authRequest in
                                expect(authRequest.path).to(equal("auth/AuthenticateWithSession"))
                                expect(authRequest.isSessionAuthRequest).to(beTrue())
                                done()
                            }
                        }
                    }
                }
                
                context("with session info and with a non-anonymous user") {
                    var serializer: OutgoingMessageSerializer!
                    
                    beforeEach {
                        let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "test")
                        ASAPP.initialize(with: config)
                        ASAPP.user = ASAPPUser(userIdentifier: "test", requestContextProvider: { _ in
                            return [:]
                        })
                        
                        serializer = OutgoingMessageSerializer(config: config, user: ASAPP.user)
                        
                        let dict = [
                            "SessionInfo": [
                                "Customer": [
                                    "PrimaryIdentifier": "test",
                                    "CustomerId": 9000,
                                    "CustomerGUID": "deadbeef"
                                ],
                                "Company": [
                                    "CompanyId": 42
                                ],
                                "SessionAuth": [
                                    "SessionTime": 1234567890,
                                    "SessionSecret": "secretsecret"
                                ],
                                "SessionId": "dead-beef"
                            ]
                        ]
                        
                        guard let session = createSession(from: dict) else {
                            return fail()
                        }
                        
                        serializer.session = session
                    }
                    
                    it("creates an auth request with an existing session") {
                        waitUntil { done in
                            serializer.createAuthRequest(contextNeedsRefresh: false) { authRequest in
                                expect(authRequest.path).to(equal("auth/AuthenticateWithSession"))
                                expect(authRequest.isSessionAuthRequest).to(beTrue())
                                done()
                            }
                        }
                    }
                }
            }
        }
    }
}
