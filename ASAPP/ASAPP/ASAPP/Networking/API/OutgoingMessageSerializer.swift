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
    let params: [String : AnyObject]?
    let context: [String : AnyObject]?
    let requestData: Data?
    
    let requestUUID: String
    
    required init(requestId: Int, path: String, params: [String : AnyObject]?, context: [String : AnyObject]?, requestData: Data?) {
        let uuid = UUID().uuidString
        
        self.requestUUID = uuid
        self.requestId = requestId
        self.path = path
        self.params = [ "RequestId" : uuid as AnyObject ].with(params)
        self.context = context
        self.requestData = requestData
    }
}

class OutgoingMessageSerializer: NSObject {
    
    // MARK: Pubic Properties
    
    fileprivate(set) var credentials: Credentials
    
    var myId: Int = 0
    var issueId: Int = 0
    var sessionInfo: String?
    var targetCustomerToken: String?
    var customerTargetCompanyId: Int = 0
    
    // MARK: Private Properties
    
    fileprivate var currentRequestId = 1

    // MARK: Init 
    
    init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        self.targetCustomerToken = credentials.targetCustomerToken
        
        super.init()
    }
}

// MARK:- Public Instance Methods

extension OutgoingMessageSerializer {
    func createRequest(withPath path: String, params: [String : AnyObject]?, context: [String : AnyObject]?) -> SocketRequest {
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
    
    func createAuthRequest() -> (path: String, params: [String : AnyObject]) {
        var path: String
        var params: [String : AnyObject]
        
        var sessionInfoJson: [String : AnyObject]?
        if let sessionInfo = sessionInfo {
            do {
                sessionInfoJson = try JSONSerialization.jsonObject(with: sessionInfo.data(using: String.Encoding.utf8)!, options: []) as? [String: AnyObject]
            } catch {}
        }
        
        if let sessionInfoJson = sessionInfoJson {
            // Session
    
            path = "auth/AuthenticateWithSession"
            params =  [
                "SessionInfo": sessionInfoJson as AnyObject, // convert to json?
                "App": "ios-sdk" as AnyObject
            ]
        } else if let userToken = credentials.userToken {
            // Customer w/ Token
            if credentials.isCustomer {
                path = "auth/AuthenticateWithCustomerIdentifier"
                
                params = [
                    "CompanyMarker" : credentials.companyMarker as AnyObject,
                    "CustomerIdentifier" : userToken as AnyObject,
                    "IdentifierType" : "\(credentials.companyMarker)_CUSTOMER_ACCOUNT_ID" as AnyObject,
                    "App" : "ios-sdk" as AnyObject,
                    "RegionCode" : "US" as AnyObject,
                ]
                
                if DEMO_LIVE_CHAT && userToken.isLikelyASAPPPhoneNumber { // userToken == "+13126089137" ||
                    params["IdentifierType"] = "PHONE" as AnyObject
                    params["CustomerIdentifier"] = userToken as AnyObject
                }
            } else {
                // Non-customer w/ Token
                path = "auth/AuthenticateWithSalesForceToken"
                params = [
                    "Company": credentials.companyMarker as AnyObject,
                    "AuthCallbackData": userToken as AnyObject,
                    "GhostEmailAddress": "" as AnyObject,
                    "CountConnectionForIssueTimeout": false as AnyObject,
                    "App": "ios-sdk" as AnyObject
                ]
            }
        } else {
            // Anonymous User
            path = "auth/CreateAnonCustomerAccount"
            params = [
                "CompanyMarker": credentials.companyMarker as AnyObject,
                "RegionCode": "US" as AnyObject
            ]
        }
        
        return (path, params)
    }
    
    func updateWithAuthResponse(_ response: IncomingMessage) {
        guard let jsonObj = response.body else {
            DebugLogError("Authentication response missing body: \(response)")
            return
        }
        
        guard let sessionInfoDict = jsonObj["SessionInfo"] as? [String: AnyObject] else {
            DebugLogError("Authentication response missing sessionInfo: \(response)")
            return
        }
        
        if let sessionJsonData = try? JSONSerialization.data(withJSONObject: sessionInfoDict, options: []) {
            sessionInfo = String(data: sessionJsonData, encoding: String.Encoding.utf8)
        }
        
        if let company = sessionInfoDict["Company"] as? [String: AnyObject] {
            if let companyId = company["CompanyId"] as? Int {
                customerTargetCompanyId = companyId
            }
        }
        
        if credentials.isCustomer {
            if let customer = sessionInfoDict["Customer"] as? [String: AnyObject] {
                if let rawId = customer["CustomerId"] as? Int {
                    myId = rawId
                }
            }
        } else {
            if let customer = sessionInfoDict["Rep"] as? [String: AnyObject] {
                if let rawId = customer["RepId"] as? Int {
                    myId = rawId
                }
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
    
    fileprivate func jsonStringify(_ dictionary: [String : AnyObject]) -> String {
        guard JSONSerialization.isValidJSONObject(dictionary) else {
            DebugLogError("Dictionary is not valid JSON object: \(dictionary)")
            return ""
        }
        
        if let json = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) {
            if let jsonString = String(data: json, encoding: String.Encoding.utf8) {
                return jsonString
            }
            DebugLogError("Unable to create string from json: \(json)")
            return ""
        }
        
        DebugLogError("Unable to serialize dictionary as JSON: \(dictionary)")
        return ""
    }
    
    fileprivate func requestWithPathIsCustomerEndpoint(_ path: String) -> Bool {
        return path.hasPrefix("customer/")
    }
    
    fileprivate func contextForRequest(withPath path: String) -> [String : AnyObject] {
        var context = [ "CompanyId" : customerTargetCompanyId ]
        if !requestWithPathIsCustomerEndpoint(path) {
            if targetCustomerToken != nil {
                context = [ "IssueId" : issueId ]
            }
        }
        return context as [String : AnyObject]
    }
}
