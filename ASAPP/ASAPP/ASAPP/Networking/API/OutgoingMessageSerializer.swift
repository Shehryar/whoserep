//
//  OutgoingMessageSerializer.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

struct SocketRequest {
    var requestId: Int
    var path: String
    var params: [String : AnyObject]?
    var context: [String : AnyObject]?
    
    var requestData: NSData?
}

class OutgoingMessageSerializer: NSObject {
    
    // MARK: Pubic Properties
    
    private(set) var credentials: Credentials
    
    var myId: Int = 0
    var issueId: Int = 0
    var sessionInfo: String?
    var targetCustomerToken: String?
    var customerTargetCompanyId: Int = 0
    
    // MARK: Private Properties
    
    private var currentRequestId = 1

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
    
    func createRequestWithData(data: NSData) -> SocketRequest {
        return SocketRequest(requestId: 0, path: "", params: nil, context: nil, requestData: data)
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
                sessionInfoJson = try NSJSONSerialization.JSONObjectWithData(sessionInfo.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as? [String: AnyObject]
            } catch {}
        }
        
        if let sessionInfoJson = sessionInfoJson {
            // Session
    
            path = "auth/AuthenticateWithSession"
            params =  [
                "SessionInfo": sessionInfoJson, // convert to json?
                "App": "ios-sdk"
            ]
        } else if let userToken = credentials.userToken {
            // Customer w/ Token
            if credentials.isCustomer {
                path = "auth/AuthenticateWithCustomerToken"
                params = [
                    "CompanyMarker": "vs-dev",
                    "Identifiers": userToken,
                    "App": "ios-sdk"
                ]
            } else {
                // Non-customer w/ Token
                path = "auth/AuthenticateWithSalesForceToken"
                params = [
                    "Company": "vs-dev",
                    "AuthCallbackData": userToken,
                    "GhostEmailAddress": "",
                    "CountConnectionForIssueTimeout": false,
                    "App": "ios-sdk"
                ]
            }
        } else {
            // Anonymous User
            path = "auth/CreateAnonCustomerAccount"
            params = [
                "CompanyMarker": "vs-dev",
                "RegionCode": "US"
            ]
        }
        
        return (path, params)
    }
    
    func updateWithAuthResponse(response: IncomingMessage) {
        guard let jsonObj = response.body else {
            DebugLogError("Authentication response missing body: \(response)")
            return
        }
        
        guard let sessionInfoDict = jsonObj["SessionInfo"] as? [String: AnyObject] else {
            DebugLogError("Authentication response missing sessionInfo: \(response)")
            return
        }
        
        if let sessionJsonData = try? NSJSONSerialization.dataWithJSONObject(sessionInfoDict, options: []) {
            sessionInfo = String(data: sessionJsonData, encoding: NSUTF8StringEncoding)
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
    private func getNextRequestId() -> Int {
        currentRequestId += 1
        return currentRequestId
    }
    
    private func jsonStringify(dictionary: [String : AnyObject]) -> String {
        guard NSJSONSerialization.isValidJSONObject(dictionary ?? [:]) else {
            DebugLogError("Dictionary is not valid JSON object: \(dictionary)")
            return ""
        }
        
        if let json = try? NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted) {
            if let jsonString = String(data: json, encoding: NSUTF8StringEncoding) {
                return jsonString
            }
            DebugLogError("Unable to create string from json: \(json)")
            return ""
        }
        
        DebugLogError("Unable to serialize dictionary as JSON: \(dictionary)")
        return ""
    }
    
    private func requestWithPathIsCustomerEndpoint(path: String) -> Bool {
        return path.hasPrefix("customer/")
    }
    
    private func contextForRequest(withPath path: String) -> [String : AnyObject] {
        var context = [ "CompanyId" : customerTargetCompanyId ]
        if !requestWithPathIsCustomerEndpoint(path) {
            if targetCustomerToken != nil {
                context = [ "IssueId" : issueId ]
            }
        }
        return context
    }
}
