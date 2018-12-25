//
//  ConversationManagerSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 10/30/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class ConversationManagerSpec: QuickSpec {
    func createSession(from dict: [String: Any]) -> Session? {
        let decoder = JSONDecoder()
        
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
            var session = try? decoder.decode(Session.self, from: data) else {
                return nil
        }
        
        session.fullInfo = data
        
        return session
    }
    
    func createTestSession() -> Session {
        let dict = [
            "authenticated_time": 327511937000000,
            "customer_primary_identifier": "foo",
            "customer_id": 9000,
            "customer_guid": "deadbeef",
            "company_id": 42,
            "session_token": "deadbeef",
            "session_id": "dead-beef"
        ] as [String: Any]
        
        return createSession(from: dict)!
    }
    
    override func spec() {
        describe("ConversationManager") {
            let config = ASAPPConfig(appId: "test", apiHostName: "example.com", clientSecret: "deadbeef")
            let user = ASAPPUser(userIdentifier: "foo", requestContextProvider: { _ -> [String: Any] in return [:] })
            let mockHTTPClient = MockHTTPClient()
            let mockSecureStorage = MockSecureStorage()
            let mockSocketConnection = MockSocketConnection(config: config, user: user)
            
            context(".init(...)") {
                it("initializes an instance correctly") {
                    let conversationManager = ConversationManager(config: config, user: user, userLoginAction: nil, httpClient: mockHTTPClient, secureStorage: mockSecureStorage, socketConnection: mockSocketConnection)
                    expect(mockHTTPClient.calledConfig).to(beTrue())
                    expect(mockSocketConnection.delegate).to(beAKindOf(ConversationManager.self))
                    expect(mockSocketConnection.delegate as? ConversationManager).to(equal(conversationManager))
                }
            }
            
            context(".isConnected(retryConnectionIfNeeded:)") {
                let conversationManager = ConversationManager(config: config, user: user, userLoginAction: nil, httpClient: mockHTTPClient, secureStorage: mockSecureStorage, socketConnection: mockSocketConnection)
                
                beforeEach {
                    mockSocketConnection.clean()
                }
                
                context("default") {
                    it("returns false when not connected") {
                        let result1 = conversationManager.isConnected()
                        expect(result1).to(beFalse())
                        expect(mockSocketConnection.calledConnect).to(beFalse())
                    }
                    
                    it("returns true when connected") {
                        mockSocketConnection.isConnected = true
                        let result2 = conversationManager.isConnected()
                        expect(result2).to(beTrue())
                        expect(mockSocketConnection.calledConnect).to(beFalse())
                    }
                }
                
                context("retry") {
                    it("connects and returns true when not already connected") {
                        let result1 = conversationManager.isConnected(retryConnectionIfNeeded: true)
                        expect(result1).to(beTrue())
                        expect(mockSocketConnection.calledConnect).to(beTrue())
                    }
                    
                    it("does not try to connect and returns true when already connected") {
                        mockSocketConnection.isConnected = true
                        let result2 = conversationManager.isConnected(retryConnectionIfNeeded: true)
                        expect(result2).to(beTrue())
                        expect(mockSocketConnection.calledConnect).to(beFalse())
                    }
                }
            }
            
            context(".enterConversation()") {
                let conversationManager = ConversationManager(config: config, user: user, userLoginAction: nil, httpClient: mockHTTPClient, secureStorage: mockSecureStorage, socketConnection: mockSocketConnection)
                
                beforeEach {
                    mockSocketConnection.clean()
                }
                
                context("on success") {
                    it("tries to connect the socket") {
                        mockHTTPClient.nextResult = .success(self.createTestSession())
                        conversationManager.enterConversation(shouldRetry: false)
                        expect(mockSocketConnection.calledConnect).to(beTrue())
                    }
                }
                
                context("on .invalid authError") {
                    it("does not connect the socket and reports a connection status change") {
                        let mockDelegate = MockConversationManagerDelegate()
                        conversationManager.delegate = mockDelegate
                        mockHTTPClient.nextResult = .failure(.invalid)
                        conversationManager.enterConversation(shouldRetry: false)
                        expect(mockHTTPClient.calledAuthenticate).to(beTrue())
                        expect(mockSocketConnection.calledConnect).to(beFalse())
                        
                        waitUntil { done in
                            expect(mockDelegate.calledDidChangeConnectionStatus).to(beTrue())
                            let invalid = ConnectionResult.couldNotAuthenticate(authError: .invalid)
                            expect(mockDelegate.lastConnectionStatus).to(equal(invalid))
                            done()
                        }
                    }
                }
                
                context("on .tokenExpired authError") {
                    it("does not connect the socket and reports a connection status change") {
                        let mockDelegate = MockConversationManagerDelegate()
                        conversationManager.delegate = mockDelegate
                        mockHTTPClient.nextResult = .failure(.tokenExpired)
                        conversationManager.enterConversation(shouldRetry: false)
                        expect(mockHTTPClient.calledAuthenticate).to(beTrue())
                        expect(mockSocketConnection.calledConnect).to(beFalse())
                        
                        waitUntil { done in
                            expect(mockDelegate.calledDidChangeConnectionStatus).to(beTrue())
                            let tokenExpired = ConnectionResult.couldNotAuthenticate(authError: .tokenExpired)
                            expect(mockDelegate.lastConnectionStatus).to(equal(tokenExpired))
                            done()
                        }
                    }
                }
            }
            
            context(".exitConversation()") {
                let conversationManager = ConversationManager(config: config, user: user, userLoginAction: nil, httpClient: mockHTTPClient, secureStorage: mockSecureStorage, socketConnection: mockSocketConnection)
                
                beforeEach {
                    mockSocketConnection.clean()
                }
                
                it("disconnects the socket") {
                    mockSocketConnection.isConnected = true
                    expect(conversationManager.isConnected).to(beTrue())
                    expect(mockSocketConnection.isConnected).to(beTrue())
                    
                    conversationManager.exitConversation()
                    expect(mockSocketConnection.calledDisconnect).to(beTrue())
                    expect(mockSocketConnection.isConnected).to(beFalse())
                    expect(conversationManager.isConnected).to(beFalse())
                }
            }
        }
    }
}
