//
//  OutgoingMessageSerializer.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation


class OutgoingMessageSerializer: NSObject {
    
    // MARK: Pubic Properties
    
    let config: ASAPPConfig
    let user: ASAPPUser
    fileprivate(set) var userLoginAction: UserLoginAction?
    
    var myId: Int = 0
    var issueId: Int = 0
    var targetCustomerToken: String?
    var customerTargetCompanyId: Int = 0
    
    // MARK: Private Properties
    
    fileprivate var currentRequestId = 1

    // MARK: Init 
    
    init(config: ASAPPConfig, user: ASAPPUser, userLoginAction: UserLoginAction? = nil) {
        self.config = config
        self.user = user
        self.userLoginAction = userLoginAction
        super.init()
    }
}

// MARK:- Public Instance Methods

extension OutgoingMessageSerializer {
    
    func createRequest(withPath path: String, params: [String : Any]?, context: [String : Any]?) -> SocketRequest {
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
    
    func createAuthRequest() -> (path: String, params: [String : Any]) {
        var path: String
        var params: [String : Any] = [
            "App" : "ios-sdk",
            "CompanyMarker": config.appId,
            "RegionCode" : "US"
        ]
        
        var sessionInfoJson: [String : Any]?
        if let sessionInfo = user.sessionInfo {
            do {
                sessionInfoJson = try JSONSerialization.jsonObject(with: sessionInfo.data(using: String.Encoding.utf8)!, options: []) as? [String: Any]
            } catch {}
        }
        
        //
        // Existing session
        //
        if let sessionInfoJson = sessionInfoJson {
            DebugLog.d(caller: self, "Authenticating with Session")
            
            path = "auth/AuthenticateWithSession"
            params["SessionInfo"] = sessionInfoJson
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
        
        return (path, params)
    }
    
    func updateWithAuthResponse(_ response: IncomingMessage) {
        guard let jsonObj = response.body else {
            DebugLog.e("Authentication response missing body: \(response)")
            return
        }
        
        guard let sessionInfoDict = jsonObj["SessionInfo"] as? [String: Any] else {
            DebugLog.e("Authentication response missing sessionInfo: \(response)")
            return
        }
        
        if let sessionJsonData = try? JSONSerialization.data(withJSONObject: sessionInfoDict, options: []) {
            user.sessionInfo = String(data: sessionJsonData, encoding: String.Encoding.utf8)
        }
        
        if let company = sessionInfoDict["Company"] as? [String: Any] {
            if let companyId = company["CompanyId"] as? Int {
                customerTargetCompanyId = companyId
            }
        }
        
        if let customer = sessionInfoDict["Customer"] as? [String: Any] {
            if let rawId = customer["CustomerId"] as? Int {
                myId = rawId
            }
        }
        
        // Conversations are merged on authentication. No need to keep this around
        userLoginAction = nil;
    }
}

// MARK: - Private Utility Methods

extension OutgoingMessageSerializer {
    
    fileprivate func getNextRequestId() -> Int {
        currentRequestId += 1
        return currentRequestId
    }
    
    fileprivate func requestWithPathIsCustomerEndpoint(_ path: String) -> Bool {
        return path.hasPrefix("customer/")
    }
    
    fileprivate func contextForRequest(withPath path: String) -> [String : Any] {
        var context = [ "CompanyId" : customerTargetCompanyId ]
        if !requestWithPathIsCustomerEndpoint(path) {
            if targetCustomerToken != nil {
                context = [ "IssueId" : issueId ]
            }
        }
        return context as [String : Any]
    }
}
