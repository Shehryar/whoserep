//
//  MockHTTPClient.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 10/30/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

@testable import ASAPP

class MockHTTPClient: HTTPClientProtocol {
    private(set) var calledConfig = false
    private(set) var calledAuthenticate = false
    private(set) var calledSendRequestWithUrl = false
    private(set) var calledSendRequestWithUrlReceivingData = false
    private(set) var calledSendRequestWithPath = false
    private(set) var calledSendRequestWithPathReceivingData = false
    
    var nextResult: Result<Session, AuthError>?
    var nextDict: [String: Any]?
    var nextData: Data?
    var nextError: Error?
    
    var session: Session?
    var baseUrl: URL?
    
    func config(_ config: ASAPPConfig) {
        calledConfig = true
        baseUrl = URL(string: "https://\(config.apiHostName)/api/http/v1/")
    }
    
    func sendRequest(method: HTTPMethod, url: URL, headers: [String: String]?, params: [String: Any], completion: @escaping DictCompletionHandler) {
        calledSendRequestWithUrl = true
        
        completion(nextDict, HTTPURLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil), nextError)
        nextDict = nil
        nextError = nil
    }
    
    // swiftlint:disable:next function_parameter_count
    func sendRequest(method: HTTPMethod, url: URL, headers: [String: String]?, params: [String: Any], data: Data?, completion: @escaping DataCompletionHandler) {
        calledSendRequestWithUrlReceivingData = true
        
        completion(nextData, HTTPURLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil), nextError)
        nextData = nil
        nextError = nil
    }
    
    func sendRequest(method: HTTPMethod, path: String, headers: [String: String]? = nil, params: [String: Any] = [:], completion: @escaping DictCompletionHandler) {
        calledSendRequestWithPath = true
        
        completion(nextDict, HTTPURLResponse(url: baseUrl!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil), nextError)
        nextDict = nil
        nextError = nil
    }
    
    func sendRequest(method: HTTPMethod, path: String, headers: [String: String]? = nil, params: [String: Any] = [:], completion: @escaping DataCompletionHandler) {
        calledSendRequestWithPathReceivingData = true
        
        completion(nextData, HTTPURLResponse(url: baseUrl!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil), nextError)
        nextData = nil
        nextError = nil
    }
    
    func authenticate(as user: ASAPPUser, contextNeedsRefresh: Bool, shouldRetry: Bool, retries: Int, completion: @escaping AuthenticationHandler) {
        calledAuthenticate = true
        
        if let nextResult = nextResult {
            completion(nextResult)
        }
        nextResult = nil
    }
    
    func authenticate(as user: ASAPPUser, contextNeedsRefresh: Bool, completion: @escaping AuthenticationHandler) {
        authenticate(as: user, contextNeedsRefresh: contextNeedsRefresh, shouldRetry: true, retries: 0, completion: completion)
    }
    
    func cleanCalls() {
        calledConfig = false
        calledAuthenticate = false
        calledSendRequestWithUrl = false
        calledSendRequestWithUrlReceivingData = false
        calledSendRequestWithPath = false
        calledSendRequestWithPathReceivingData = false
    }
    
    func clean() {
        cleanCalls()
        nextResult = nil
        nextData = nil
        nextDict = nil
        nextError = nil
    }
}
