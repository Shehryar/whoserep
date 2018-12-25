//
//  MockSocketConnection.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 10/29/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

@testable import ASAPP

class MockSocketConnection: SocketConnectionProtocol {
    private(set) var calledConnect = false
    private(set) var calledDisconnect = false
    
    weak var delegate: SocketConnectionDelegate?
    var isConnected = false
    
    required init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction? = nil, savedSessionManager: SavedSessionManagerProtocol = SavedSessionManager.shared, webSocketClass: ASAPPSRWebSocket.Type = ASAPPSRWebSocket.self, httpClient: HTTPClientProtocol = HTTPClient.shared) {
        
    }
    
    func connect(shouldRetry: Bool, retries: Int = 0) {
        calledConnect = true
        isConnected = true
    }
    
    func disconnect() {
        calledDisconnect = true
        isConnected = false
    }
    
    func cleanCalls() {
        calledConnect = false
        calledDisconnect = false
    }
    
    func clean() {
        cleanCalls()
        delegate = nil
        isConnected = false
    }
}
