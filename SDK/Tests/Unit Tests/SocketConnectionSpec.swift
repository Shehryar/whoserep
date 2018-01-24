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
        
        describe("SocketConnection") {
            context(".init(...)") {
                context("without a userLoginAction") {
                    it("creates a correct instance of SocketConnection") {
                        let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "secret", regionCode: "US")
                        let user = ASAPPUser(userIdentifier: "test-user", requestContextProvider: {
                            return [:]
                        })
                        let serializer = OutgoingMessageSerializer(config: config, user: user)
                        let mockSavedSessionManager = MockSavedSessionManager()
                        let connection = SocketConnection(config: config, user: user, outgoingMessageSerializer: serializer, savedSessionManager: mockSavedSessionManager)
                        
                        expect(connection.config).to(equal(config))
                        expect(connection.isConnected).to(equal(false))
                        expect(serializer.session).to(beNil())
                        expect(serializer.userLoginAction).to(beNil())
                        expect(mockSavedSessionManager.calledClearSession).to(equal(false))
                        expect(mockSavedSessionManager.calledSave).to(equal(false))
                        expect(mockSavedSessionManager.calledGetSession).to(equal(true))
                    }
                }
                
                context("with a saved session that doesn't match the current customer") {
                    it("creates a correct instance of SocketConnection and calls clearSession") {
                        let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "secret", regionCode: "US")
                        let user = ASAPPUser(userIdentifier: "test-user", requestContextProvider: {
                            return [:]
                        })
                        let mockSavedSessionManager = MockSavedSessionManager()
                        
                        let dict = [
                            "SessionInfo": [
                                "Customer": [
                                    "PrimaryIdentifier": "foo",
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
                        
                        guard let session = createSession(from: dict) else {
                            return fail()
                        }
                        
                        mockSavedSessionManager.nextSession = session
                        
                        let mockOutgoingMessageSerializer = MockOutgoingMessageSerializer()
                        _ = SocketConnection(config: config, user: user, outgoingMessageSerializer: mockOutgoingMessageSerializer, savedSessionManager: mockSavedSessionManager)
                        
                        expect(mockSavedSessionManager.calledClearSession).to(equal(true))
                        expect(mockSavedSessionManager.calledSave).to(equal(false))
                        expect(mockSavedSessionManager.calledGetSession).to(equal(true))
                        expect(mockOutgoingMessageSerializer.userLoginAction).to(beNil())
                        expect(mockOutgoingMessageSerializer.session).to(beNil())
                    }
                }
                
                context("with a saved session that matches the current customer") {
                    it("creates a correct instance of SocketConnection and sets the serializer's session") {
                        let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "secret", regionCode: "US")
                        let user = ASAPPUser(userIdentifier: "test-user", requestContextProvider: {
                            return [:]
                        })
                        let mockSavedSessionManager = MockSavedSessionManager()
                        
                        let dict = [
                            "SessionInfo": [
                                "Customer": [
                                    "PrimaryIdentifier": "test-user",
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
                        
                        guard let session = createSession(from: dict) else {
                            return fail()
                        }
                        
                        mockSavedSessionManager.nextSession = session
                        
                        let mockOutgoingMessageSerializer = MockOutgoingMessageSerializer()
                        _ = SocketConnection(config: config, user: user, outgoingMessageSerializer: mockOutgoingMessageSerializer, savedSessionManager: mockSavedSessionManager)
                        
                        expect(mockSavedSessionManager.calledClearSession).to(equal(false))
                        expect(mockSavedSessionManager.calledSave).to(equal(false))
                        expect(mockSavedSessionManager.calledGetSession).to(equal(true))
                        expect(mockOutgoingMessageSerializer.userLoginAction).to(beNil())
                        expect(mockOutgoingMessageSerializer.session).to(equal(session))
                    }
                }
                
                context("with a saved session that is anonymous and a user that is not anonymous") {
                    it("creates a correct instance of SocketConnection and sets the serializer's userLoginAction") {
                        let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "secret", regionCode: "US")
                        let user = ASAPPUser(userIdentifier: "test-user", requestContextProvider: {
                            return [:]
                        })
                        let mockSavedSessionManager = MockSavedSessionManager()
                        
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
                                ]
                            ]
                        ]
                        
                        guard let session = createSession(from: dict) else {
                            return fail()
                        }
                        mockSavedSessionManager.nextSession = session
                        
                        let mockOutgoingMessageSerializer = MockOutgoingMessageSerializer()
                        _ = SocketConnection(config: config, user: user, outgoingMessageSerializer: mockOutgoingMessageSerializer, savedSessionManager: mockSavedSessionManager)
                        
                        expect(mockSavedSessionManager.calledClearSession).to(equal(false))
                        expect(mockSavedSessionManager.calledSave).to(equal(false))
                        expect(mockSavedSessionManager.calledGetSession).to(equal(true))
                        expect(mockOutgoingMessageSerializer.userLoginAction).toNot(beNil())
                        expect(mockOutgoingMessageSerializer.userLoginAction?.mergeCustomerId).to(equal(session.customer.id))
                        expect(mockOutgoingMessageSerializer.userLoginAction?.mergeCustomerGUID).to(equal(session.customer.guid))
                    }
                }
            }
            
            context(".connect()") {
                var connection: SocketConnection!
                var mockOutgoingMessageSerializer: MockOutgoingMessageSerializer!
                
                beforeEach {
                    MockSRWebSocket.clean()
                    
                    let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "secret", regionCode: "US")
                    let user = ASAPPUser(userIdentifier: "test-user", requestContextProvider: {
                        return [:]
                    })
                    mockOutgoingMessageSerializer = MockOutgoingMessageSerializer()
                    let mockSavedSessionManager = MockSavedSessionManager()
                    connection = SocketConnection(config: config, user: user, outgoingMessageSerializer: mockOutgoingMessageSerializer, savedSessionManager: mockSavedSessionManager, webSocketClass: MockSRWebSocket.self)
                }
                
                context("without an existing socket") {
                    it("opens a socket and tries to authenticate") {
                        connection.connect()
                        
                        expect(MockSRWebSocket.calledOpen).to(equal(true))
                        expect(MockSRWebSocket.calledClose).to(equal(false))
                        expect(MockSRWebSocket.calledSend).to(equal(true))
                        expect(mockOutgoingMessageSerializer.calledCreateAuthRequest).to(equal(true))
                    }
                }
                
                context("with an existing socket") {
                    it("does nothing") {
                        connection.connect()
                        MockSRWebSocket.clean()
                        
                        connection.connect()
                        
                        expect(MockSRWebSocket.calledOpen).to(equal(false))
                        expect(MockSRWebSocket.calledClose).to(equal(false))
                        expect(MockSRWebSocket.calledSend).to(equal(false))
                    }
                }
            }
            
            context(".connectIfNeeded(afterDelay:)") {
                var connection: SocketConnection!
                var mockOutgoingMessageSerializer: MockOutgoingMessageSerializer!
                
                beforeEach {
                    MockSRWebSocket.clean()
                    
                    let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "secret", regionCode: "US")
                    let user = ASAPPUser(userIdentifier: "test-user", requestContextProvider: {
                        return [:]
                    })
                    mockOutgoingMessageSerializer = MockOutgoingMessageSerializer()
                    let mockSavedSessionManager = MockSavedSessionManager()
                    connection = SocketConnection(config: config, user: user, outgoingMessageSerializer: mockOutgoingMessageSerializer, savedSessionManager: mockSavedSessionManager, webSocketClass: MockSRWebSocket.self)
                }
                
                context("with a non-zero delay") {
                    it("opens a socket and tries to authenticate") {
                        connection.connectIfNeeded(afterDelay: 1)
                        
                        expect(MockSRWebSocket.calledOpen).toEventually(equal(true))
                        expect(MockSRWebSocket.calledClose).to(equal(false))
                        expect(MockSRWebSocket.calledSend).to(equal(true))
                        expect(mockOutgoingMessageSerializer.calledCreateAuthRequest).to(equal(true))
                    }
                }
                
                context("with no delay") {
                    it("opens a socket") {
                        connection.connectIfNeeded(afterDelay: 0)
                        
                        expect(MockSRWebSocket.calledOpen).to(equal(true))
                        expect(MockSRWebSocket.calledClose).to(equal(false))
                        expect(MockSRWebSocket.calledSend).to(equal(true))
                        expect(mockOutgoingMessageSerializer.calledCreateAuthRequest).to(equal(true))
                    }
                }
            }
            
            context(".disconnect()") {
                it("closes the socket") {
                    MockSRWebSocket.clean()
                    
                    let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "secret", regionCode: "US")
                    let user = ASAPPUser(userIdentifier: "test-user", requestContextProvider: {
                        return [:]
                    })
                    let serializer = OutgoingMessageSerializer(config: config, user: user)
                    let mockSavedSessionManager = MockSavedSessionManager()
                    let connection = SocketConnection(config: config, user: user, outgoingMessageSerializer: serializer, savedSessionManager: mockSavedSessionManager, webSocketClass: MockSRWebSocket.self)
                    
                    connection.connect()
                    MockSRWebSocket.clean()
                    
                    connection.disconnect()
                    
                    expect(MockSRWebSocket.calledOpen).to(equal(false))
                    expect(MockSRWebSocket.calledClose).to(equal(true))
                    expect(MockSRWebSocket.calledSend).to(equal(false))
                }
            }
            
            context(".sendRequest(...)") {
                var connection: SocketConnection!
                var mockOutgoingMessageSerializer: MockOutgoingMessageSerializer!
                
                beforeEach {
                    MockSRWebSocket.clean()
                    
                    let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "secret", regionCode: "US")
                    let user = ASAPPUser(userIdentifier: "test-user", requestContextProvider: {
                        return [:]
                    })
                    mockOutgoingMessageSerializer = MockOutgoingMessageSerializer()
                    let mockSavedSessionManager = MockSavedSessionManager()
                    connection = SocketConnection(config: config, user: user, outgoingMessageSerializer: mockOutgoingMessageSerializer, savedSessionManager: mockSavedSessionManager, webSocketClass: MockSRWebSocket.self)
                }
                
                context("without an existing connection") {
                    it("opens a socket and tries to authenticate") {
                        MockSRWebSocket.nextReceivedMessage = """
                        Response|0|{"SessionInfo":{"Customer":{"CustomerId":3830001,"PrimaryIdentifier":"test_customer_1"},"Company":{"CompanyId":40001},"SessionAuth":{"SessionTime":1515112274532741,"SessionSecret":"deadbeef"}}}
                        """
                        connection.sendRequest(withPath: "foo", params: nil)
                        
                        expect(mockOutgoingMessageSerializer.calledCreateRequest).to(equal(true))
                        expect(mockOutgoingMessageSerializer.calledCreateRequestString).to(equal(true))
                        expect(mockOutgoingMessageSerializer.calledCreateRequestWithData).to(equal(false))
                        expect(mockOutgoingMessageSerializer.calledCreateAuthRequest).to(equal(true))
                        expect(MockSRWebSocket.calledOpen).to(equal(true))
                        expect(MockSRWebSocket.calledClose).to(equal(false))
                    }
                }
                
                context("with an existing connection") {
                    it("sends a request") {
                        var calledRequestHandler = false
                        
                        connection.connect()
                        MockSRWebSocket.clean()
                        
                        MockSRWebSocket.nextReceivedMessage = """
                        Response|0|{"SessionInfo":{"Customer":{"CustomerId":3830001,"PrimaryIdentifier":"test_customer_1"},"Company":{"CompanyId":40001},"SessionAuth":{"SessionTime":1515112274532741,"SessionSecret":"deadbeef"}}}
                        """
                        MockSRWebSocket.nextReadyState = .OPEN
                        connection.authenticate { (_, _) in
                            MockSRWebSocket.clean()
                            MockSRWebSocket.nextReadyState = .OPEN
                            MockSRWebSocket.nextReceivedMessage = """
                            Response|0|{}
                            """
                            mockOutgoingMessageSerializer.clean()
                            connection.sendRequest(withPath: "foo", params: nil) { (_, _, _) in
                                calledRequestHandler = true
                                expect(mockOutgoingMessageSerializer.calledCreateRequestString).to(equal(true))
                                expect(mockOutgoingMessageSerializer.calledCreateRequest).to(equal(true))
                                expect(mockOutgoingMessageSerializer.calledCreateRequestWithData).to(equal(false))
                                expect(mockOutgoingMessageSerializer.calledCreateAuthRequest).to(equal(false))
                                expect(MockSRWebSocket.calledSend).to(equal(true))
                                expect(MockSRWebSocket.calledOpen).to(equal(false))
                                expect(MockSRWebSocket.calledClose).to(equal(false))
                                expect(MockSRWebSocket.lastSentData as? String).to(equal(""))
                            }
                        }
                        
                        expect(calledRequestHandler).toEventually(equal(true))
                    }
                }
            }
            
            context(".sendRequestWithData(...)") {
                var connection: SocketConnection!
                var mockOutgoingMessageSerializer: MockOutgoingMessageSerializer!
                
                beforeEach {
                    MockSRWebSocket.clean()
                    
                    let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "secret", regionCode: "US")
                    let user = ASAPPUser(userIdentifier: "test-user", requestContextProvider: {
                        return [:]
                    })
                    mockOutgoingMessageSerializer = MockOutgoingMessageSerializer()
                    let mockSavedSessionManager = MockSavedSessionManager()
                    connection = SocketConnection(config: config, user: user, outgoingMessageSerializer: mockOutgoingMessageSerializer, savedSessionManager: mockSavedSessionManager, webSocketClass: MockSRWebSocket.self)
                }
                
                context("with an existing connection") {
                    it("sends a request") {
                        var calledRequestHandler = false
                        
                        connection.connect()
                        MockSRWebSocket.clean()
                        
                        MockSRWebSocket.nextReceivedMessage = """
                        Response|0|{"SessionInfo":{"Customer":{"CustomerId":3830001,"PrimaryIdentifier":"test_customer_1"},"Company":{"CompanyId":40001},"SessionAuth":{"SessionTime":1515112274532741,"SessionSecret":"deadbeef"}}}
                        """
                        MockSRWebSocket.nextReadyState = .OPEN
                        connection.authenticate { (_, _) in
                            MockSRWebSocket.clean()
                            MockSRWebSocket.nextReadyState = .OPEN
                            MockSRWebSocket.nextReceivedMessage = """
                            Response|0|{}
                            """
                            mockOutgoingMessageSerializer.clean()
                            let data = "foo".data(using: .utf8)!
                            connection.sendRequestWithData(data) { (_, _, _) in
                                calledRequestHandler = true
                                expect(mockOutgoingMessageSerializer.calledCreateRequestString).to(equal(false))
                                expect(mockOutgoingMessageSerializer.calledCreateRequest).to(equal(false))
                                expect(mockOutgoingMessageSerializer.calledCreateRequestWithData).to(equal(true))
                                expect(mockOutgoingMessageSerializer.calledCreateAuthRequest).to(equal(false))
                                expect(MockSRWebSocket.calledSend).to(equal(true))
                                expect(MockSRWebSocket.calledOpen).to(equal(false))
                                expect(MockSRWebSocket.calledClose).to(equal(false))
                                expect(MockSRWebSocket.lastSentData as? Data).to(equal(data))
                            }
                        }
                        
                        expect(calledRequestHandler).toEventually(equal(true))
                    }
                }
            }
            
            context(".authenticate(attempts:_:)") {
                var connection: SocketConnection!
                var mockOutgoingMessageSerializer: MockOutgoingMessageSerializer!
                var mockSavedSessionManager: MockSavedSessionManager!
                
                beforeEach {
                    MockSRWebSocket.clean()
                    
                    let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "secret", regionCode: "US")
                    let user = ASAPPUser(userIdentifier: "test-user", requestContextProvider: {
                        return [:]
                    })
                    mockOutgoingMessageSerializer = MockOutgoingMessageSerializer()
                    mockSavedSessionManager = MockSavedSessionManager()
                    connection = SocketConnection(config: config, user: user, outgoingMessageSerializer: mockOutgoingMessageSerializer, savedSessionManager: mockSavedSessionManager, webSocketClass: MockSRWebSocket.self)
                }
                
                context("with an invalid session response after already being authenticated") {
                    it("clears the saved session and sets the serializer's session to nil") {
                        var calledRequestHandler = false
                        
                        connection.connect()
                        MockSRWebSocket.clean()
                        
                        MockSRWebSocket.nextReceivedMessage = """
                        Response|0|{"SessionInfo":{"Customer":{"CustomerId":3830001,"PrimaryIdentifier":"test_customer_1"},"Company":{"CompanyId":40001},"SessionAuth":{"SessionTime":1515112274532741,"SessionSecret":"deadbeef"}}}
                        """
                        MockSRWebSocket.nextReadyState = .OPEN
                        connection.authenticate { (_, _) in
                            MockSRWebSocket.clean()
                            
                            MockSRWebSocket.nextReceivedMessage = """
                            Response|0|{}
                            """
                            MockSRWebSocket.nextReadyState = .OPEN
                            connection.authenticate(attempts: 1) { (_, _) in
                                calledRequestHandler = true
                                expect(mockSavedSessionManager.calledClearSession).to(equal(true))
                                expect(mockOutgoingMessageSerializer.calledCreateRequestString).to(equal(true))
                                expect(mockOutgoingMessageSerializer.calledCreateRequest).to(equal(true))
                                expect(mockOutgoingMessageSerializer.calledCreateRequestWithData).to(equal(false))
                                expect(mockOutgoingMessageSerializer.calledCreateAuthRequest).to(equal(true))
                                expect(mockOutgoingMessageSerializer.session).to(beNil())
                                expect(MockSRWebSocket.calledSend).to(equal(true))
                                expect(MockSRWebSocket.calledOpen).to(equal(false))
                                expect(MockSRWebSocket.calledClose).to(equal(false))
                                expect(MockSRWebSocket.lastSentData as? Data).to(beNil())
                            }
                        }
                        
                        expect(calledRequestHandler).toEventually(equal(true))
                    }
                }
            }
        }
    }
}
