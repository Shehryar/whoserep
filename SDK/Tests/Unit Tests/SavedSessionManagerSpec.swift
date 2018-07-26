//
//  SavedSessionManagerSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 3/7/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class SavedSessionManagerSpec: QuickSpec {
    override func spec() {
        var sessionCounter = 0
        
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
        
        func createTestSession() -> Session {
            let dict = [
                "SessionInfo": [
                    "Customer": [
                        "PrimaryIdentifier": "foo\(sessionCounter)",
                        "CustomerId": 9000,
                        "CustomerGUID": "deadbeef"
                    ],
                    "Company": [
                        "CompanyId": 42
                    ],
                    "SessionAuth": [
                        "SessionTime": 1234567890,
                        "SessionSecret": "secretsecret"
                    ]
                ]
            ]
            
            sessionCounter += 1
            
            return createSession(from: dict)!
        }
        
        describe("SavedSessionManager") {
            context(".save(session:)") {
                context("with everything as expected") {
                    it("saves the session properly") {
                        let mockStorage = MockSecureCodableStorage()
                        let savedSessionManager = SavedSessionManager(secureStorage: mockStorage)
                        let session = createTestSession()
                        
                        savedSessionManager.save(session: session)
                        
                        expect(mockStorage.calledStore).to(equal(true))
                        expect(mockStorage.calledRetrieve).to(equal(false))
                        expect(mockStorage.calledRemove).to(equal(false))
                    }
                }
                
                context("with a nil session") {
                    it("removes the existing session") {
                        let mockStorage = MockSecureCodableStorage()
                        let savedSessionManager = SavedSessionManager(secureStorage: mockStorage)
                        let session = createTestSession()
                        
                        savedSessionManager.save(session: session)
                        mockStorage.cleanCalls()
                        savedSessionManager.save(session: nil)
                        
                        expect(mockStorage.calledStore).to(equal(false))
                        expect(mockStorage.calledRetrieve).to(equal(false))
                        expect(mockStorage.calledRemove).to(equal(true))
                    }
                }
                
                context("with a nil session and an existing session that cannot be removed") {
                    it("tries to remove the existing session") {
                        let mockStorage = MockSecureCodableStorage()
                        let savedSessionManager = SavedSessionManager(secureStorage: mockStorage)
                        let session = createTestSession()
                        
                        savedSessionManager.save(session: session)
                        mockStorage.cleanCalls()
                        mockStorage.nextRemoveShouldThrow = true
                        savedSessionManager.save(session: nil)
                        
                        expect(mockStorage.calledStore).to(equal(false))
                        expect(mockStorage.calledRetrieve).to(equal(false))
                        expect(mockStorage.calledRemove).to(equal(true))
                    }
                }
                
                context("with a session that lacks a primary identifier") {
                    it("saves the session properly") {
                        let mockStorage = MockSecureCodableStorage()
                        let savedSessionManager = SavedSessionManager(secureStorage: mockStorage)
                        let session = createSession(from: [
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
                                ]
                            ]
                        ])
                        
                        savedSessionManager.save(session: session)
                        
                        expect(mockStorage.calledStore).to(equal(true))
                        expect(mockStorage.calledRetrieve).to(equal(false))
                        expect(mockStorage.calledRemove).to(equal(false))
                    }
                }
                
                context("with a session that cannot be stored") {
                    it("tries to store the session") {
                        let mockStorage = MockSecureCodableStorage()
                        let savedSessionManager = SavedSessionManager(secureStorage: mockStorage)
                        let session = createTestSession()
                        
                        mockStorage.nextStoreShouldThrow = true
                        savedSessionManager.save(session: session)
                        
                        expect(mockStorage.calledStore).to(equal(true))
                        expect(mockStorage.calledRetrieve).to(equal(false))
                        expect(mockStorage.calledRemove).to(equal(false))
                    }
                }
            }
            
            context(".clearSession()") {
                it("removes the existing session") {
                    let mockStorage = MockSecureCodableStorage()
                    let savedSessionManager = SavedSessionManager(secureStorage: mockStorage)
                    let session = createTestSession()
                    
                    savedSessionManager.save(session: session)
                    mockStorage.cleanCalls()
                    savedSessionManager.clearSession()
                    
                    expect(mockStorage.calledStore).to(equal(false))
                    expect(mockStorage.calledRetrieve).to(equal(false))
                    expect(mockStorage.calledRemove).to(equal(true))
                }
            }
            
            context(".getSession()") {
                context("with everything as expected") {
                    it("it retrieves the session properly") {
                        let mockStorage = MockSecureCodableStorage()
                        let savedSessionManager = SavedSessionManager(secureStorage: mockStorage)
                        let session = createTestSession()
                        
                        savedSessionManager.save(session: session)
                        mockStorage.cleanCalls()
                        let retrieved = savedSessionManager.getSession()
                        
                        expect(retrieved).to(equal(session))
                        expect(mockStorage.calledStore).to(equal(false))
                        expect(mockStorage.calledRetrieve).to(equal(true))
                        expect(mockStorage.calledRemove).to(equal(false))
                    }
                }
                
                context("with a session that lacks a primary identifier") {
                    it("retrieves the session properly") {
                        let mockStorage = MockSecureCodableStorage()
                        let savedSessionManager = SavedSessionManager(secureStorage: mockStorage)
                        let session = createSession(from: [
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
                                ]
                            ]
                        ])
                        
                        savedSessionManager.save(session: session)
                        mockStorage.cleanCalls()
                        let retrieved = savedSessionManager.getSession()
                        
                        expect(retrieved).to(equal(session))
                        expect(mockStorage.calledStore).to(equal(false))
                        expect(mockStorage.calledRetrieve).to(equal(true))
                        expect(mockStorage.calledRemove).to(equal(false))
                    }
                }
                
                context("without an existing session") {
                    it("returns nil") {
                        let mockStorage = MockSecureCodableStorage()
                        let savedSessionManager = SavedSessionManager(secureStorage: mockStorage)
                        
                        let retrieved = savedSessionManager.getSession()
                        
                        expect(retrieved).to(beNil())
                        expect(mockStorage.calledStore).to(equal(false))
                        expect(mockStorage.calledRetrieve).to(equal(true))
                        expect(mockStorage.calledRemove).to(equal(false))
                    }
                }
                
                context("with a session that cannot be read") {
                    it("returns nil") {
                        let mockStorage = MockSecureCodableStorage()
                        let savedSessionManager = SavedSessionManager(secureStorage: mockStorage)
                        let session = createTestSession()
                        
                        savedSessionManager.save(session: session)
                        mockStorage.cleanCalls()
                        mockStorage.nextRetrieveShouldThrow = true
                        
                        let retrieved = savedSessionManager.getSession()
                        
                        expect(retrieved).to(beNil())
                        expect(mockStorage.calledStore).to(equal(false))
                        expect(mockStorage.calledRetrieve).to(equal(true))
                        expect(mockStorage.calledRemove).to(equal(false))
                    }
                }
            }
        }
    }
}
