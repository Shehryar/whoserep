//
//  OutgoingMessageSerializer.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

protocol OutgoingMessageSerializerProtocol {
    var session: Session? { get set }
    var userLoginAction: UserLoginAction? { get set }
    var issueId: Int { get set }
    func createRequest(withPath path: String, params: [String: Any]?, context: [String: Any]?) -> SocketRequest
    func createRequestString(withRequest request: SocketRequest) -> String
    func createAuthRequest(contextNeedsRefresh: Bool, completion: @escaping (_ authRequest: OutgoingMessageSerializer.AuthRequest) -> Void)
}

class OutgoingMessageSerializer: OutgoingMessageSerializerProtocol {
    
    // MARK: Public Properties
    
    var issueId: Int = 0
    var userLoginAction: UserLoginAction?
    var session: Session?
    
    // MARK: Private Properties
    
    private let config: ASAPPConfig
    private let user: ASAPPUser
    private var currentRequestId = 1

    // MARK: Init 
    
    init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction? = nil) {
        self.config = config
        self.user = user
        self.userLoginAction = userLoginAction
    }
    
    private func getNextRequestId() -> Int {
        currentRequestId += 1
        return currentRequestId
    }
}

// MARK: - Public Instance Methods

extension OutgoingMessageSerializer {
    func createRequest(withPath path: String, params: [String: Any]?, context: [String: Any]?) -> SocketRequest {
        return SocketRequest(requestId: getNextRequestId(), path: path, params: params, context: context, requestData: nil)
    }
    
    func createRequestString(withRequest request: SocketRequest) -> String {
        let paramsJSONString = JSONUtil.stringify(request.params)
        let contextJSONString = JSONUtil.stringify(request.context ?? HTTPClient.shared.getContext(for: session))

        return "\(request.path)|\(request.requestId)|\(contextJSONString ?? "")|\(paramsJSONString ?? "")"
    }
    
    struct AuthRequest {
        let path: String
        let params: [String: Any]
        let isSessionAuthRequest: Bool
    }
    
    func createAuthRequest(contextNeedsRefresh: Bool, completion: @escaping (_ authRequest: AuthRequest) -> Void) {
        var path: String
        var params: [String: Any] = [
            "App": "ios-sdk",
            "CompanyMarker": config.appId,
            "RegionCode": config.regionCode
        ]
        
        var sessionInfoJson: [String: Any]?
        if let session = session {
            sessionInfoJson = session.fullInfoAsDict
        }
        
        //
        // Existing session
        //
        if let sessionInfoJson = sessionInfoJson {
            DebugLog.d(caller: self, "Authenticating with Session")
            
            path = "auth/AuthenticateWithSession"
            params["SessionInfo"] = sessionInfoJson
            
            completion(AuthRequest(path: path, params: params, isSessionAuthRequest: true))
        }
        
        //
        // New session
        //
        else {
            //
            // User Token
            //
            if !user.isAnonymous {
                DebugLog.d(caller: self, "Authenticating with Customer Identifier")
                
                path = "auth/AuthenticateWithCustomerIdentifier"
                params["IdentifierType"] = config.identifierType
                params["CustomerIdentifier"] = user.userIdentifier
                
                if let previousSession = userLoginAction?.previousSession {
                    params["MergeCustomerId"] = previousSession.customer.id
                    params["MergeCustomerGUID"] = previousSession.customer.guid
                    params["SessionId"] = previousSession.id
                }
                
                user.getContext(needsRefresh: contextNeedsRefresh) { (context, authToken) in
                    if let authToken = authToken {
                        params["Auth"] = authToken
                    }
                    
                    if let context = context {
                        params["Context"] = JSONUtil.stringify(context)
                    }
                    
                    completion(AuthRequest(path: path, params: params, isSessionAuthRequest: false))
                }
            }
            
            //
            // Anonymous User
            //
            else {
                DebugLog.d(caller: self, "Authenticating with Anonymous User")
                
                path = "auth/CreateAnonCustomerAccount"
                
                completion(AuthRequest(path: path, params: params, isSessionAuthRequest: false))
            }
        }
    }
}
