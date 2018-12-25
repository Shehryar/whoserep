//
//  SocketConnectionSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 12/28/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

// swiftlint:disable:next type_body_length
class SocketConnectionSpec: QuickSpec {
    override func spec() {
        func createSession(from dict: [String: Any]) -> Session? {
            let decoder = JSONDecoder()
            
            guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
                var session = try? decoder.decode(Session.self, from: data) else {
                    return nil
            }
            
            session.fullInfo = data
            
            return session
        }
        
        describe("SocketConnection") {
            context(".init(...)") {
                context("without a userLoginAction") {
                    it("creates a correct instance of SocketConnection") {
                        let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "secret", regionCode: "US")
                        let user = ASAPPUser(userIdentifier: "test-user", requestContextProvider: { _ in
                            return [:]
                        })
                        let mockSavedSessionManager = MockSavedSessionManager()
                        let connection = SocketConnection(config: config, user: user, savedSessionManager: mockSavedSessionManager)
                        
                        expect(connection.isConnected).to(equal(false))
                        expect(mockSavedSessionManager.calledClearSession).to(equal(false))
                        expect(mockSavedSessionManager.calledSave).to(equal(false))
                        expect(mockSavedSessionManager.calledGetSession).to(equal(true))
                    }
                }
                
                context("with a saved session that doesn't match the current customer") {
                    it("creates a correct instance of SocketConnection and calls clearSession") {
                        let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "secret", regionCode: "US")
                        let user = ASAPPUser(userIdentifier: "test-user", requestContextProvider: { _ in
                            return [:]
                        })
                        let mockSavedSessionManager = MockSavedSessionManager()
                        
                        let dict = [
                            "authenticated_time": 327511937000000,
                            "customer_primary_identifier": "foo",
                            "customer_id": 9000,
                            "customer_guid": "deadbeef",
                            "company_id": 42,
                            "session_token": "deadbeef",
                            "session_id": "dead-beef"
                        ] as [String: Any]
                        
                        guard let session = createSession(from: dict) else {
                            return fail()
                        }
                        
                        mockSavedSessionManager.nextSession = session
                        
                        _ = SocketConnection(config: config, user: user, savedSessionManager: mockSavedSessionManager)
                        
                        expect(mockSavedSessionManager.calledClearSession).to(equal(true))
                        expect(mockSavedSessionManager.calledSave).to(equal(false))
                        expect(mockSavedSessionManager.calledGetSession).to(equal(true))
                    }
                }
                
                context("with a saved session that matches the current customer") {
                    it("creates a correct instance of SocketConnection and sets the serializer's session") {
                        let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "secret", regionCode: "US")
                        let user = ASAPPUser(userIdentifier: "test-user", requestContextProvider: { _ in
                            return [:]
                        })
                        let mockSavedSessionManager = MockSavedSessionManager()
                        
                        let dict = [
                            "authenticated_time": 327511937000000,
                            "customer_primary_identifier": "test-user",
                            "customer_id": 9000,
                            "customer_guid": "deadbeef",
                            "company_id": 42,
                            "session_token": "deadbeef",
                            "session_id": "dead-beef"
                        ] as [String: Any]
                        
                        guard let session = createSession(from: dict) else {
                            return fail()
                        }
                        
                        mockSavedSessionManager.nextSession = session
                        
                        _ = SocketConnection(config: config, user: user, savedSessionManager: mockSavedSessionManager)
                        
                        expect(mockSavedSessionManager.calledClearSession).to(equal(false))
                        expect(mockSavedSessionManager.calledSave).to(equal(false))
                        expect(mockSavedSessionManager.calledGetSession).to(equal(true))
                    }
                }
                
                context("with a saved session that is anonymous and a user that is not anonymous") {
                    it("creates a correct instance of SocketConnection and sets the serializer's userLoginAction") {
                        let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "secret", regionCode: "US")
                        let user = ASAPPUser(userIdentifier: "test-user", requestContextProvider: { _ in
                            return [:]
                        })
                        let mockSavedSessionManager = MockSavedSessionManager()
                        
                        let dict = [
                            "authenticated_time": 327511937000000,
                            "customer_id": 9000,
                            "customer_guid": "deadbeef",
                            "company_id": 42,
                            "session_token": "deadbeef",
                            "session_id": "dead-beef"
                        ] as [String: Any]
                        
                        guard let session = createSession(from: dict) else {
                            return fail()
                        }
                        mockSavedSessionManager.nextSession = session
                        
                        _ = SocketConnection(config: config, user: user, savedSessionManager: mockSavedSessionManager)
                        
                        expect(mockSavedSessionManager.calledClearSession).to(equal(false))
                        expect(mockSavedSessionManager.calledSave).to(equal(false))
                        expect(mockSavedSessionManager.calledGetSession).to(equal(true))
                    }
                }
            }
            
            context(".connect()") {
                var connection: SocketConnection!
                let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "secret", regionCode: "US")
                let user = ASAPPUser(userIdentifier: "test-user", requestContextProvider: { _ in
                    return [:]
                })
                let mockHTTPClient = MockHTTPClient()
                
                beforeEach {
                    mockHTTPClient.clean()
                    MockSRWebSocket.clean()
                    let mockSavedSessionManager = MockSavedSessionManager()
                    connection = SocketConnection(config: config, user: user, savedSessionManager: mockSavedSessionManager, webSocketClass: MockSRWebSocket.self, httpClient: mockHTTPClient)
                }
                
                context("with an existing socket") {
                    it("does nothing") {
                        connection.connect(shouldRetry: false)
                        MockSRWebSocket.clean()
                        
                        connection.connect(shouldRetry: false)
                        
                        expect(MockSRWebSocket.calledOpen).to(equal(false))
                        expect(MockSRWebSocket.calledClose).to(equal(false))
                        expect(MockSRWebSocket.calledSend).to(equal(false))
                    }
                }
                
                context("without an existing socket") {
                    it("connects succesfully") {
                        mockHTTPClient.config(config)
                        mockHTTPClient.nextDict = [
                            "url": "foo"
                        ]
                        connection.connect(shouldRetry: false)
                        
                        expect(mockHTTPClient.calledSendRequestWithUrl).to(beTrue())
                        expect(MockSRWebSocket.calledOpen).to(beTrue())
                        expect(MockSRWebSocket.calledClose).to(equal(false))
                        expect(MockSRWebSocket.calledSend).to(equal(false))
                    }
                }
            }
        }
    }
}
