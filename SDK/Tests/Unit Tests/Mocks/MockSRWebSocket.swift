//
//  MockSRWebSocket.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 1/3/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

@testable import ASAPP

class MockSRWebSocket: SRWebSocket {
    private(set) static var calledOpen = false
    private(set) static var calledClose = false
    private(set) static var calledSend = false
    private(set) static var lastSentData: Any?
    static var nextReadyState: SRReadyState?
    static var nextReceivedMessage: Any?
    
    override func open() {
        MockSRWebSocket.calledOpen = true
        MockSRWebSocket.nextReadyState = .OPEN
        delegate?.webSocketDidOpen?(self)
    }
    
    override func close() {
        MockSRWebSocket.calledClose = true
        MockSRWebSocket.nextReadyState = .CLOSED
        delegate?.webSocket?(self, didCloseWithCode: 0, reason: "", wasClean: true)
    }
    
    override func send(_ data: Any!) {
        MockSRWebSocket.calledSend = true
        MockSRWebSocket.lastSentData = data
        
        if let message = MockSRWebSocket.nextReceivedMessage {
            MockSRWebSocket.nextReceivedMessage = nil
            delegate?.webSocket(self, didReceiveMessage: message)
        }
    }
    
    override var readyState: SRReadyState {
        return MockSRWebSocket.nextReadyState ?? super.readyState
    }
    
    static func clean() {
        MockSRWebSocket.calledOpen = false
        MockSRWebSocket.calledClose = false
        MockSRWebSocket.calledSend = false
        MockSRWebSocket.lastSentData = nil
        MockSRWebSocket.nextReadyState = nil
        MockSRWebSocket.nextReceivedMessage = nil
    }
}
