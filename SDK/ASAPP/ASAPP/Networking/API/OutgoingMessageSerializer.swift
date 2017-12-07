//
//  OutgoingMessageSerializer.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class OutgoingMessageSerializer: NSObject {
    
    // MARK: Public Properties
    
    let config: ASAPPConfig
    let user: ASAPPUser
    
    var issueId: Int = 0
    var targetCustomerToken: String?
    var userLoginAction: UserLoginAction?
    var session: Session? {
        didSet {
            if oldValue != session {
                PushNotificationsManager.session = session
            }
        }
    }
    
    // MARK: Private Properties
    
    private var currentRequestId = 1

    // MARK: Init 
    
    init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction? = nil) {
        self.config = config
        self.user = user
        self.userLoginAction = userLoginAction
        super.init()
    }
}

// MARK: - Public Instance Methods

extension OutgoingMessageSerializer {
    
    func createRequest(withPath path: String, params: [String: Any]?, context: [String: Any]?) -> SocketRequest {
        return SocketRequest(requestId: getNextRequestId(), path: path, params: params, context: context, requestData: nil)
    }
    
    func createRequestWithData(_ data: Data) -> SocketRequest {
        return SocketRequest(requestId: getNextRequestId(), path: "", params: nil, context: nil, requestData: data)
    }
    
    func createRequestString(withRequest request: SocketRequest) -> String {
        let paramsJSONString = JSONUtil.stringify(request.params)
        let contextJSONString = JSONUtil.stringify(request.context ?? contextForRequest(withPath: request.path))

        return "\(request.path)|\(request.requestId)|\(contextJSONString ?? "")|\(paramsJSONString ?? "")"
    }
    
    struct AuthRequest {
        let path: String
        let params: [String: Any]
        let isSessionAuthRequest: Bool
    }
    
    func createAuthRequest() -> AuthRequest {
        var path: String
        var params: [String: Any] = [
            "App": "ios-sdk",
            "CompanyMarker": config.appId,
            "RegionCode": config.regionCode
        ]
        var isSessionAuthRequest = false
        
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
            isSessionAuthRequest = true
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
                
                if let userLoginAction = userLoginAction {
                    params["MergeCustomerId"] = userLoginAction.mergeCustomerId
                    params["MergeCustomerGUID"] = userLoginAction.mergeCustomerGUID
                }
            }
            
            //
            // Anonymous User
            //
            else {
                DebugLog.d(caller: self, "Authenticating with Anonymous User")
                
                path = "auth/CreateAnonCustomerAccount"
            }
        }
        
        return AuthRequest(path: path, params: params, isSessionAuthRequest: isSessionAuthRequest)
    }
}

// MARK: - Private Utility Methods

extension OutgoingMessageSerializer {
    
    private func getNextRequestId() -> Int {
        currentRequestId += 1
        return currentRequestId
    }
    
    private func requestWithPathIsCustomerEndpoint(_ path: String) -> Bool {
        return path.hasPrefix("customer/")
    }
    
    private func contextForRequest(withPath path: String) -> [String: Any] {
        var context = ["CompanyId": session?.company.id ?? 0]
        if !requestWithPathIsCustomerEndpoint(path) {
            if targetCustomerToken != nil {
                context = ["IssueId": issueId]
            }
        }
        return context as [String: Any]
    }
}
