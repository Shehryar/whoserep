//
//  OutgoingMessageSerializer.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class SocketRequest {
    let requestId: Int
    let path: String
    let params: [String : Any]?
    let context: [String : Any]?
    let requestData: Data?
    
    let requestUUID: String
    
    required init(requestId: Int, path: String, params: [String : Any]?, context: [String : Any]?, requestData: Data?) {
        let uuid = UUID().uuidString
        
        self.requestUUID = uuid
        self.requestId = requestId
        self.path = path
        self.params = [ "RequestId" : uuid ].with(params)
        self.context = context
        self.requestData = requestData
    }
    
    // MARK: Print Utilities
    
    var containsSensitiveData: Bool {
        return path.contains("CreditCard")
    }
    
    func getParametersCleanedOfSensitiveData() -> [String : Any] {
        var cleanedParams = [String : Any]()
        cleanedParams.add(params)
        if path.contains("CreditCard") {
            if cleanedParams["Number"] != nil {
                cleanedParams["Number"] = "xxxx"
            }
            if cleanedParams["CVV"] != nil {
                cleanedParams["CVV"] = "xxx"
            }
            
        }
        
        return cleanedParams
    }
    
    func getLoggableDescription() -> String {
        let cleanedParams = getParametersCleanedOfSensitiveData()
        let paramsJSONString = JSONUtil.stringify(cleanedParams, prettyPrinted: true) ?? "{}"
        let contextJSONString = JSONUtil.stringify((context ?? [:]), prettyPrinted: true) ?? "{}"
        
        return "\(path)|\(requestId)|\(contextJSONString)|\(paramsJSONString)"
    }
    
    func logRequest(with requestString: String) {
        let loggableRequestString: String
        if containsSensitiveData {
            loggableRequestString = getLoggableDescription()
        } else {
            loggableRequestString = requestString
        }
        DebugLog.d("Sending request:\n\n\(loggableRequestString)")
    }
}

class OutgoingMessageSerializer: NSObject {
    
    // MARK: Pubic Properties
    
    let config: ASAPPConfig
    let user: ASAPPUser
    
    var myId: Int = 0
    var issueId: Int = 0
    var sessionInfo: String?
    var targetCustomerToken: String?
    var customerTargetCompanyId: Int = 0
    
    // MARK: Private Properties
    
    fileprivate var currentRequestId = 1

    // MARK: Init 
    
    init(config: ASAPPConfig, user: ASAPPUser) {
        self.config = config
        self.user = user
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
        let paramsJSONString = jsonStringify(request.params ?? [:])
        let contextJSONString = jsonStringify(request.context ?? contextForRequest(withPath: request.path))

        return "\(request.path)|\(request.requestId)|\(contextJSONString)|\(paramsJSONString)"
    }
    
    func createAuthRequest() -> (path: String, params: [String : Any]) {
        var path: String
        var params: [String : Any] = [
            "App" : "ios-sdk",
            "CompanyMarker": config.appId,
            "RegionCode" : "US"
        ]
        
        
        var sessionInfoJson: [String : Any]?
        if let sessionInfo = sessionInfo {
            do {
                sessionInfoJson = try JSONSerialization.jsonObject(with: sessionInfo.data(using: String.Encoding.utf8)!, options: []) as? [String: Any]
            } catch {}
        }
        
        //
        // Session
        //
        if let sessionInfoJson = sessionInfoJson {
            DebugLog.d(caller: self, "Authenticating with Session")
            
            path = "auth/AuthenticateWithSession"
            params["SessionInfo"] = sessionInfoJson
        }
 
 
        //
        // User Token
        //
        if !user.isAnonymous {
            DebugLog.d(caller: self, "Authenticating with Customer Identifier")
            
            path = "auth/AuthenticateWithCustomerIdentifier"
            params["IdentifierType"] = config.identifierType
            params["CustomerIdentifier"] = user.userIdentifier
        }
        
        //
        // Anonymous User
        //
        else {
            DebugLog.d(caller: self, "Authenticating with Anonymous User")
            
            path = "auth/CreateAnonCustomerAccount"
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
            sessionInfo = String(data: sessionJsonData, encoding: String.Encoding.utf8)
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
    }
}

// MARK: - Private Utility Methods

extension OutgoingMessageSerializer {
    fileprivate func getNextRequestId() -> Int {
        currentRequestId += 1
        return currentRequestId
    }
    
    fileprivate func jsonStringify(_ dictionary: [String : Any]) -> String {
        guard JSONSerialization.isValidJSONObject(dictionary) else {
            DebugLog.e("Dictionary is not valid JSON object: \(dictionary)")
            return ""
        }
        
        if let json = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) {
            if let jsonString = String(data: json, encoding: String.Encoding.utf8) {
                return jsonString
            }
            DebugLog.e("Unable to create string from json: \(json)")
            return ""
        }
        
        DebugLog.e("Unable to serialize dictionary as JSON: \(dictionary)")
        return ""
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
