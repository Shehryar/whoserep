//
//  MockOutgoingMessageSerializer.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 1/2/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

@testable import ASAPP

class MockOutgoingMessageSerializer: OutgoingMessageSerializerProtocol {
    private(set) var calledCreateRequest = false
    private(set) var calledCreateRequestWithData = false
    private(set) var calledCreateRequestString = false
    private(set) var calledCreateAuthRequest = false
    var nextSocketRequestFromPath: SocketRequest?
    var nextSocketRequestFromData: SocketRequest?
    var nextRequestString: String?
    var nextAuthRequest: OutgoingMessageSerializer.AuthRequest?
    
    var session: Session?
    
    var userLoginAction: UserLoginAction?
    
    var issueId: Int = 0
    
    func createRequest(withPath: String, params: [String: Any]?, context: [String: Any]?) -> SocketRequest {
        calledCreateRequest = true
        return nextSocketRequestFromPath ?? SocketRequest(requestId: 0, path: "", params: nil, context: nil, requestData: nil)
    }
    
    func createRequestWithData(_ data: Data) -> SocketRequest {
        calledCreateRequestWithData = true
        return nextSocketRequestFromData ?? SocketRequest(requestId: 0, path: "", params: nil, context: nil, requestData: data)
    }
    
    func createRequestString(withRequest: SocketRequest) -> String {
        calledCreateRequestString = true
        return nextRequestString ?? ""
    }
    
    func createAuthRequest(contextNeedsRefresh: Bool, completion: @escaping (_ authRequest: OutgoingMessageSerializer.AuthRequest) -> Void) {
        calledCreateAuthRequest = true
        completion(nextAuthRequest ?? OutgoingMessageSerializer.AuthRequest(path: "", params: [:], isSessionAuthRequest: true))
    }
    
    func clean() {
        calledCreateAuthRequest = false
        calledCreateRequestWithData = false
        calledCreateRequest = false
        calledCreateRequestString = false
        nextSocketRequestFromData = nil
        nextSocketRequestFromPath = nil
        nextAuthRequest = nil
        nextRequestString = nil
    }
}
